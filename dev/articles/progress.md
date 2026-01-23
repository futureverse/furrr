# Progress notifications with progressr

``` r
library(furrr)
library(progressr)
library(dplyr)
```

## Introduction

Everyone loves progress bars. This is even more true when running long
computations in parallel, where you’d really like to have some
approximation of when your job is going to finish. furrr currently has
its own progress bar through the usage of `.progress = TRUE`, but in the
future this will be deprecated in favor of generic and robust progress
updates through the
[progressr](https://CRAN.R-project.org/package=progressr) package.

If you’ve never heard of progressr, I’d encourage you to read its
[introduction
vignette](https://CRAN.R-project.org/package=progressr/vignettes/progressr-intro.html).
One of the neat things about it is that it isn’t limited to just
progress bars. progressr is really a framework for progress *updates*,
which can then be relayed to the user using a progress bar, a beeping
noise from their computer, or even through email or slack notifications.
It works for sequential, multisession, and cluster futures, which means
that it even works with remote connections. It currently doesn’t work
with multicore, but that is likely to change.

Before we begin, please be aware that progressr is still a new
experimental package. I doubt there will be many breaking changes in it,
but new patterns for signaling progress updates will likely emerge after
enough people start using it. If you’ve used furrr’s `.progress`
argument, then the solutions presented below might feel a bit clunkier
than that. As progressr gets more usage, hopefully a simpler unified way
of presenting progress information will emerge that can be used in all
of the map-reduce future packages (furrr, future.apply, and doFuture).

How progressr is used varies slightly depending on whether you are a
package developer or an interactive user. There are two main functions
that are used:
[`progressor()`](https://progressr.futureverse.org/reference/progressor.html),
which makes an object that can signal progress updates, and
[`with_progress()`](https://progressr.futureverse.org/reference/with_progress.html),
which listens for these progress signals. Generally,
[`progressor()`](https://progressr.futureverse.org/reference/progressor.html)
will be used by a package developer inside of a function that they would
like to produce progress updates. When the user calls that function,
they won’t get any progress notifications unless they wrap the function
call in
[`with_progress()`](https://progressr.futureverse.org/reference/with_progress.html).
Additionally, the user has complete control over how these progress
updates are displayed through the use of a *progress handler*. In
progressr, these all start with `handler_*()` and tell progressr how to
display the progress update. This separation of developer API and user
API is important, and can be summarized as:

- Developer:
  - `p <- progressor()` for making progress signalers
  - `p()` for signaling a unit of progress
- User:
  - [`with_progress()`](https://progressr.futureverse.org/reference/with_progress.html)
    for listening for progress signals
  - `handler_*()` for displaying those caught progress signals

## Package developers

If you are a package developer using furrr with progressr, the function
from your package that calls
[`future_map()`](https://furrr.futureverse.org/dev/reference/future_map.md)
should first use `p <- progressor()` to create a progress object, and
then call `p()` from within `.f` to signal a progress update after each
iteration of the map. For example, the following function iterates over
a list, `x`, calling [`sum()`](https://rdrr.io/r/base/sum.html) on each
element of the list. At each iteration, we send a progress update. I’ve
also introduced a bit of a delay because this otherwise would run
extremely fast.

``` r
my_pkg_fn <- function(x) {
  p <- progressor(steps = length(x))
  
  future_map(x, ~{
    p()
    Sys.sleep(.2)
    sum(.x)
  })
}
```

From the user’s side, simply calling `my_pkg_fun()` won’t display
anything:

``` r
plan(multisession, workers = 2)

set.seed(123)

x <- replicate(n = 10, runif(20), simplify = FALSE)
```

``` r
# No notifications
result <- my_pkg_fn(x)
```

However, once the user wraps this in
[`with_progress()`](https://progressr.futureverse.org/reference/with_progress.html),
notifications are displayed. The default is to use
[`handler_txtprogressbar()`](https://progressr.futureverse.org/reference/handler_txtprogressbar.html),
which creates a progress bar with
[`utils::txtProgressBar()`](https://rdrr.io/r/utils/txtProgressBar.html).

``` r
with_progress({
  result <- my_pkg_fn(x)
})
#> |===============================                                     |  30%
```

As mentioned before, the *user* controls how to display progress
updates. You can change to a different handler locally by providing it
as an argument to `with_progress(handlers = )`, or you can use
[`handlers()`](https://progressr.futureverse.org/reference/handlers.html)
to set them globally. You can even use multiple handlers. For example,
`handlers(handler_progress, handler_beepr)` can be used to generate a
progress bar with the progress package and generate beeps with the beepr
package.

## Interactive usage

When writing data analysis scripts that use furrr and progressr, the
separation between developer and user APIs is not quite as clear since
you’ll need to generate the progress objects with
[`progressor()`](https://progressr.futureverse.org/reference/progressor.html),
create the function that signals progress by calling `p()`, and call
[`with_progress()`](https://progressr.futureverse.org/reference/with_progress.html).
It is easiest to show this with an example:

``` r
plan(multisession, workers = 2)

with_progress({
  p <- progressor(steps = length(x))
  
  result <- future_map(x, ~{
    p()
    Sys.sleep(.2)
    sum(.x)
  })
})
#> |=====================                                               |  20%
```

Currently,
[`with_progress()`](https://progressr.futureverse.org/reference/with_progress.html)
doesn’t return the value of the `expr`ession that it evaluates, so you
have to assign the result to `result <-`. This is likely to change.

Rather than writing an anonymous function, you might want to wrap the
logic of `.f` up into a real function. The easiest way to do this right
now is to have an extra argument for `p` that you can pass through.

``` r
plan(multisession, workers = 2)

fn <- function(x, p) {
  p()
  Sys.sleep(.2)
  sum(x)
}

with_progress({
  p <- progressor(steps = length(x))
  result <- future_map(x, fn, p = p)
})
```

The important thing here is that `p <- progressor()` is called from
inside
[`with_progress()`](https://progressr.futureverse.org/reference/with_progress.html).
You generally can’t create the progressor object outside of the
[`with_progress()`](https://progressr.futureverse.org/reference/with_progress.html)
call. For example, this doesn’t work:

``` r
p <- progressor(steps = length(x))

with_progress({
  result <- future_map(x, fn, p = p)
})
#> Error in error("length(timestamp) == 0L") : 
#>   .validate_internal_state(‘handler(type=update) ... end’): length(timestamp) #> == 0L
#> Error in error("length(timestamp) == 0L") : 
#>   .validate_internal_state(‘reporter_args() ... begin’): length(timestamp) == #> 0L
```

### With dplyr

Because
[`with_progress()`](https://progressr.futureverse.org/reference/with_progress.html)
doesn’t return the value of `expr` right now, current usage of
progressr, furrr, and dplyr is far from perfect. The only way to use
them together currently is to wrap an entire dplyr pipeline in
[`with_progress()`](https://progressr.futureverse.org/reference/with_progress.html).

``` r
cars <- mtcars |>
  group_by(carb) |>
  group_nest()

model_fn <- function(data, p) {
  Sys.sleep(.5)
  mod <- lm(mpg ~ cyl + disp, data = data)
  out <- mod$coef
  
  p()
  
  out
}
```

You can create the progressor, `p`, at the top of the expression, and
then call
[`future_map()`](https://furrr.futureverse.org/dev/reference/future_map.md)
in [`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html):

``` r
plan(multisession, workers = 2)

with_progress({
  p <- progressor(steps = nrow(cars))
  
  cars2 <- cars |>
    mutate(mod = future_map(data, model_fn, p = p))
})
#> |================================================                    |  67%
```

Or you can wrap `model_fn()` in another function that creates `p` and
calls
[`future_map()`](https://furrr.futureverse.org/dev/reference/future_map.md)
all at once:

``` r
plan(multisession, workers = 2)

model_mapper <- function(data) {
  p <- progressor(steps = length(data))
  future_map(data, model_fn, p = p)
}

with_progress({
  cars2 <- cars |>
    mutate(mod = model_mapper(data))
})
#> |================================================                    |  67%
```

An additional constraint (for now), is that
[`with_progress()`](https://progressr.futureverse.org/reference/with_progress.html)
will only respect progress updates from the first progressor object that
signals one. This means that the first call to `model_mapper()` will
signal updates, but the second won’t.

``` r
with_progress({
  cars2 <- cars |>
    mutate(
      mod1 = model_mapper(data),
      mod2 = model_mapper(data)
    )
})
#> |================================================                    |  67%

# ^ Note, we don't get a second progress bar
```

However, if you know that you are going to do something like this then
you can use the first approach and create a progressor object that is
twice the number of rows in the data frame, and pass it to both calls to
[`future_map()`](https://furrr.futureverse.org/dev/reference/future_map.md).
The state is maintained between
[`future_map()`](https://furrr.futureverse.org/dev/reference/future_map.md)
calls so you end up with one long progress bar.

``` r
plan(multisession, workers = 2)

with_progress({
  p <- progressor(steps = nrow(cars) * 2)
  
  cars2 <- cars |>
    mutate(
      mod1 = future_map(data, model_fn, p = p),
      mod2 = future_map(data, model_fn, p = p)
    )
})
#> |===================================                                 |  50%
```

## Conclusion

progressr represents an exciting move towards a unified framework for
progress notifications in R, but it is still early in its development
cycle and needs more usage and feedback to settle on the best API. In
the future, the plan is for furrr to become more tightly integrated with
progressr so that this is much easier.
