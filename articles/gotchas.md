# Common gotchas

``` r
library(furrr)
library(purrr)
library(dplyr)
```

## Introduction

This article lists a few common gotchas when working with furrr.

## Non-standard evaluation of arguments

One difference with purrr is that furrr has to evaluate the arguments
passed through `...` in functions such as
[`future_map()`](https://furrr.futureverse.org/reference/future_map.md).
This has to happen before they can be serialized and shipped off to the
worker sessions. It is guaranteed that these arguments are evaluated
only once, but this prevents some “lazy” behavior that is possible with
purrr. For example:

``` r
filter_for_dogs <- function(data, col) {
  filter(data, {{ col }} == "dog")
}

df1 <- tibble(
  pets = c("dog", "cat"),
  names = c("Floofy", "Buttercup")
)

df2 <- tibble(
  pets = c("horse", "dog", "mouse"),
  names = c("Stalone", "Fido", "Cheesy")
)

dfs <- list(df1, df2)
```

[`map()`](https://purrr.tidyverse.org/reference/map.html) delays
evaluation as long as possible, and `pets` is evaluated in a context
where the data frame exists, so it can detect that `pets` is a column in
the data frame.

``` r
map(dfs, filter_for_dogs, col = pets)
#> [[1]]
#> # A tibble: 1 × 2
#>   pets  names 
#>   <chr> <chr> 
#> 1 dog   Floofy
#> 
#> [[2]]
#> # A tibble: 1 × 2
#>   pets  names
#>   <chr> <chr>
#> 1 dog   Fido
```

[`future_map()`](https://furrr.futureverse.org/reference/future_map.md)
has to evaluate each argument early, so `pets` is evaluated in a context
where the data frame doesn’t exist, so we get an error.

``` r
future_map(dfs, filter_for_dogs, col = pets)
#> Error:
#> ! object 'pets' not found
```

One alternative is to pass the column through as a character string, and
to use the `.data` pronoun to retrieve the column.

``` r
filter_for_dogs2 <- function(data, col) {
  filter(data, .data[[col]] == "dog")
}
```

``` r
future_map(dfs, filter_for_dogs2, col = "pets")
#> [[1]]
#> # A tibble: 1 × 2
#>   pets  names 
#>   <chr> <chr> 
#> 1 dog   Floofy
#> 
#> [[2]]
#> # A tibble: 1 × 2
#>   pets  names
#>   <chr> <chr>
#> 1 dog   Fido
```

## Argument evaluation

In both purrr and furrr, there is a difference between passing arguments
through `...` and specifying arguments in the anonymous function
directly. Arguments passed through `...` are evaluated just once. If you
want the argument to be evaluated at each iteration, you’ll need to put
it inside the anonymous function. For example:

``` r
x <- rep(0, 3)

plus <- function(x, y) x + y
```

``` r
set.seed(123)

map_dbl(x, plus, runif(1))
#> [1] 0.2875775 0.2875775 0.2875775

map_dbl(x, ~ plus(.x, runif(1)))
#> [1] 0.7883051 0.4089769 0.8830174
```

This is the case with both furrr and purrr, but is a common question.

Note that in the furrr case, when you evaluate the argument in the
anonymous function it will be evaluated on the worker itself. This means
that to control the reproducibility, you should pass an `options`
argument with a specified seed.

``` r
plan(multisession, workers = 2)

options <- furrr_options(seed = 123)

future_map_dbl(x, plus, runif(1))
#> [1] 0.9404673 0.9404673 0.9404673

future_map_dbl(x, ~ plus(.x, runif(1)), .options = options)
#> [1] 0.1552317 0.4877356 0.5330014

plan(sequential)
```

## Grouped data frames

A common source of frustration is swapping a
[`map()`](https://purrr.tidyverse.org/reference/map.html) for a
[`future_map()`](https://furrr.futureverse.org/reference/future_map.md)
and realizing that your computation is proceeding massively slower than
it was with [`map()`](https://purrr.tidyverse.org/reference/map.html).
One possible reason for this is that you have called
[`future_map()`](https://furrr.futureverse.org/reference/future_map.md)
on a column of a grouped data frame. For example it is possible for the
following data frame to arise naturally if you have nested a grouped
data frame.

``` r
set.seed(123)

df <- tibble(
  g = 1:100,
  x = replicate(100, runif(10), simplify = FALSE)
)

df <- group_by(df, g)

df
#> # A tibble: 100 × 2
#> # Groups:   g [100]
#>        g x         
#>    <int> <list>    
#>  1     1 <dbl [10]>
#>  2     2 <dbl [10]>
#>  3     3 <dbl [10]>
#>  4     4 <dbl [10]>
#>  5     5 <dbl [10]>
#>  6     6 <dbl [10]>
#>  7     7 <dbl [10]>
#>  8     8 <dbl [10]>
#>  9     9 <dbl [10]>
#> 10    10 <dbl [10]>
#> # ℹ 90 more rows
```

If you’d like to map over this and perform some computation on each
element of `x`, you might try and use
[`future_map_dbl()`](https://furrr.futureverse.org/reference/future_map.md),
but you’ll be surprised about how slow it can be.

``` r
plan(multisession, workers = 2)

t1 <- proc.time()

df |>
  mutate(y = future_map_dbl(x, mean))
#> # A tibble: 100 × 3
#> # Groups:   g [100]
#>        g x              y
#>    <int> <list>     <dbl>
#>  1     1 <dbl [10]> 0.578
#>  2     2 <dbl [10]> 0.523
#>  3     3 <dbl [10]> 0.616
#>  4     4 <dbl [10]> 0.538
#>  5     5 <dbl [10]> 0.345
#>  6     6 <dbl [10]> 0.433
#>  7     7 <dbl [10]> 0.554
#>  8     8 <dbl [10]> 0.425
#>  9     9 <dbl [10]> 0.559
#> 10    10 <dbl [10]> 0.415
#> # ℹ 90 more rows

t2 <- proc.time()

plan(sequential)

t2 - t1
#>    user  system elapsed 
#>   1.348   0.028   5.885
```

The issue here is that the grouped nature of the data frame prevents
furrr from doing what it is good at - sharding the `x` column into
equally sized groups and sending them off to the workers to process them
in parallel.

Instead, because this data frame is grouped, and each group corresponds
to 1 row of the data frame, dplyr hands
[`future_map_dbl()`](https://furrr.futureverse.org/reference/future_map.md)
1 element of `x` at a time to operate on. So
[`future_map_dbl()`](https://furrr.futureverse.org/reference/future_map.md)
is actually being called 100 times here!

The easy solution is to just ungroup the data frame before calling
[`future_map_dbl()`](https://furrr.futureverse.org/reference/future_map.md).

``` r
plan(multisession, workers = 2)

t1 <- proc.time()

df |>
  ungroup() |>
  mutate(y = future_map_dbl(x, mean))
#> # A tibble: 100 × 3
#>        g x              y
#>    <int> <list>     <dbl>
#>  1     1 <dbl [10]> 0.578
#>  2     2 <dbl [10]> 0.523
#>  3     3 <dbl [10]> 0.616
#>  4     4 <dbl [10]> 0.538
#>  5     5 <dbl [10]> 0.345
#>  6     6 <dbl [10]> 0.433
#>  7     7 <dbl [10]> 0.554
#>  8     8 <dbl [10]> 0.425
#>  9     9 <dbl [10]> 0.559
#> 10    10 <dbl [10]> 0.415
#> # ℹ 90 more rows

t2 <- proc.time()

plan(sequential)

t2 - t1
#>    user  system elapsed 
#>   0.042   0.000   0.259
```

## Graphics devices

If you use a multicore plan, you shouldn’t try to generate and save
plots with any graphics devices, which includes using ggplot2. This can
cause an X11 fatal error because it can’t be safely run in a forked
environment, which can crash your R session. Instead, you should use
`plan(multisession)` to avoid these issues. See [this
issue](https://github.com/futureverse/furrr/issues/27) for more details.

## Package development

When developing a package that imports and calls functions from furrr,
you’ll likely be using `devtools::load_all()` as part of your
development process. It is likely that unless you install your package,
you might run into issues where functions internal to your package
aren’t being exported to your workers (see [issue
\#95](https://github.com/futureverse/furrr/issues/95)).

Specifically, if you do the following, you will probably have issues:

1.  Your package has not yet been *installed* on your machine, or you
    have an old version installed.

2.  You call `devtools::load_all()`.

3.  You set up a multisession or multicore strategy for furrr.

4.  You call
    [`future_map()`](https://furrr.futureverse.org/reference/future_map.md)
    or any other furrr function from inside your package, and `.f`
    contains a function specific to your package.

In this example, the underlying globals package will likely think that
the function you called from `.f` is part of a package that is installed
on your machine, so it won’t try and export it to the workers. Instead,
it will just try and load up that package on the worker to get access to
the function. Since the package hasn’t been installed on your machine
yet (`load_all()` just *mocks* a fake installation) the workers will
fail to attach it.

The solution is just to install your package with `devtools::install()`
or using the RStudio Build pane, and then to restart R. Make sure that
you re-install whenever you make any additional changes to the package.

## Function environments and large objects

When
[`future_map()`](https://furrr.futureverse.org/reference/future_map.md)
and friends are called from within another function, you have to be
extremely careful about the `.f` function that you pass through. If the
function that
[`future_map()`](https://furrr.futureverse.org/reference/future_map.md)
is called from contains a large object, it is possible for that object
to get captured by the function environment of `.f` and be exported to
the worker, even if you never used it in the function itself.

``` r
my_fast_fn <- function() {
  future_map(1:5, ~.x)
}

my_slow_fn <- function() {
  # Massive object - but we don't want it in `.f`
  big <- 1:1e8 + 0L
  
  future_map(1:5, ~.x)
}
```

``` r
plan(multisession, workers = 2)

system.time(
  my_fast_fn()
)
#>    user  system elapsed 
#>   0.030   0.000   0.245

system.time(
  my_slow_fn()
)
#>    user  system elapsed 
#>   0.350   0.287   1.263

plan(sequential)
```

In the above example, `big` is captured in the function environment of
the anonymous function `~.x` and is exported. Note that the problem
isn’t that `big` is identified as a global by furrr. We can even prove
that it is on the workers using
[`get()`](https://rdrr.io/r/base/get.html) to look for an object called
`"big"` in the current and surrounding environments. I’ll use a smaller
object here, but the concept is the same.

``` r
plan(multisession, workers = 2)

my_slow_fn2 <- function() {
  big <- "can you find me?"
  
  future_map(1:2, ~get("big"))
}

my_slow_fn2()
#> [[1]]
#> [1] "can you find me?"
#> 
#> [[2]]
#> [1] "can you find me?"

plan(sequential)
```

One solution to this is to create `.f` somewhere where it won’t capture
that massive object in its surrounding environment. For example:

``` r
fn <- function(x) {
  x
}

my_not_so_slow_fn <- function() {
  big <- 1:1e8 + 0L
  
  future_map(1:5, fn)
}

plan(multisession, workers = 2)

system.time(
  my_not_so_slow_fn()
)
#>    user  system elapsed 
#>   0.179   0.049   0.445

plan(sequential)
```

Here lexical scoping is used to find `fn`, but you could also pass it in
as an argument to `my_not_so_slow_fn()`. This works naturally in a
package development environment, where `fn()` would just be a helper
function in your package that you can call from anywhere else in the
package without issue.

Again, we can prove that the object doesn’t make it onto the workers:

``` r
plan(multisession, workers = 2)

fn2 <- function(x) {
  # does an object called `"big"` exist anywhere we can find it?
  exists("big")
}

my_not_so_slow_fn2 <- function() {
  big <- "can you find me?"
  
  future_map(1:2, fn2)
}

my_not_so_slow_fn2()
#> [[1]]
#> [1] FALSE
#> 
#> [[2]]
#> [1] FALSE

plan(sequential)
```

Another alternative to help with this issue is to use the carrier
package to *crate* the function. To learn more about this, see the
article entitled *Alternative to automatic globals detection*.
