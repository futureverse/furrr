# Apply a function to each element of a vector via futures

These functions work exactly the same as
[`purrr::map()`](https://purrr.tidyverse.org/reference/map.html) and its
variants, but allow you to map in parallel.

## Usage

``` r
future_map(
  .x,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_map_chr(
  .x,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_map_dbl(
  .x,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_map_int(
  .x,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_map_lgl(
  .x,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_map_raw(
  .x,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_map_dfr(
  .x,
  .f,
  ...,
  .id = NULL,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_map_dfc(
  .x,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_walk(
  .x,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)
```

## Arguments

- .x:

  A list or atomic vector.

- .f:

  A function, formula, or vector (not necessarily atomic).

  If a **function**, it is used as is.

  If a **formula**, e.g. `~ .x + 2`, it is converted to a function.
  There are three ways to refer to the arguments:

  - For a single argument function, use `.`

  - For a two argument function, use `.x` and `.y`

  - For more arguments, use `..1`, `..2`, `..3` etc

  This syntax allows you to create very compact anonymous functions.

  If **character vector**, **numeric vector**, or **list**, it is
  converted to an extractor function. Character vectors index by name
  and numeric vectors index by position; use a list to index by position
  and name at different levels. If a component is not present, the value
  of `.default` will be returned.

- ...:

  Additional arguments passed on to the mapped function.

- .options:

  The `future` specific options to use with the workers. This must be
  the result from a call to
  [`furrr_options()`](https://furrr.futureverse.org/dev/reference/furrr_options.md).

- .env_globals:

  The environment to look for globals required by `.x` and `...`.
  Globals required by `.f` are looked up in the function environment of
  `.f`.

- .progress:

  A single logical. Should a progress bar be displayed? Only works with
  multisession, multicore, and multiprocess futures. Note that if a
  multicore/multisession future falls back to sequential, then a
  progress bar will not be displayed.

  **Warning:** The `.progress` argument will be deprecated and removed
  in a future version of furrr in favor of using the more robust
  [progressr](https://CRAN.R-project.org/package=progressr) package.

- .id:

  Either a string or `NULL`. If a string, the output will contain a
  variable with that name, storing either the name (if `.x` is named) or
  the index (if `.x` is unnamed) of the input. If `NULL`, the default,
  no variable will be created.

  Only applies to `_dfr` variant.

## Value

All functions return a vector the same length as `.x`.

- `future_map()` returns a list

- `future_map_lgl()` a logical vector

- `future_map_int()` an integer vector

- `future_map_dbl()` a double vector

- `future_map_chr()` a character vector

The output of `.f` will be automatically typed upwards, e.g. logical -\>
integer -\> double -\> character.

## Examples

``` r
library(magrittr)
plan(multisession, workers = 2)

1:10 %>%
  future_map(rnorm, n = 10, .options = furrr_options(seed = 123)) %>%
  future_map_dbl(mean)
#>  [1] 1.180279 2.140442 2.909823 3.692207 5.058100 6.653926 7.065630 7.960713
#>  [9] 9.105674 9.766827

# If each element of the output is a data frame, use
# `future_map_dfr()` to row-bind them together:
mtcars %>%
  split(.$cyl) %>%
  future_map(~ lm(mpg ~ wt, data = .x)) %>%
  future_map_dfr(~ as.data.frame(t(as.matrix(coef(.)))))
#>   (Intercept)        wt
#> 1    39.57120 -5.647025
#> 2    28.40884 -2.780106
#> 3    23.86803 -2.192438


# You can be explicit about what gets exported to the workers.
# To see this, use multisession (not multicore as the forked workers
# still have access to this environment)
plan(multisession)
x <- 1
y <- 2

# This will fail, y is not exported (no black magic occurs)
try(future_map(1, ~y, .options = furrr_options(globals = "x")))
#> [[1]]
#> [1] 2
#> 

# y is exported
future_map(1, ~y, .options = furrr_options(globals = "y"))
#> [[1]]
#> [1] 2
#> 
```
