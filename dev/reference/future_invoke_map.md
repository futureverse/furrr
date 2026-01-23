# Invoke functions via futures

**\[deprecated\]**

These functions work the same as
[`purrr::invoke_map()`](https://purrr.tidyverse.org/reference/invoke.html)
functions, but allow you to invoke in parallel.

## Usage

``` r
future_invoke_map(
  .f,
  .x = list(NULL),
  ...,
  .env = NULL,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_invoke_map_chr(
  .f,
  .x = list(NULL),
  ...,
  .env = NULL,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_invoke_map_dbl(
  .f,
  .x = list(NULL),
  ...,
  .env = NULL,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_invoke_map_int(
  .f,
  .x = list(NULL),
  ...,
  .env = NULL,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_invoke_map_lgl(
  .f,
  .x = list(NULL),
  ...,
  .env = NULL,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_invoke_map_dfr(
  .f,
  .x = list(NULL),
  ...,
  .env = NULL,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_invoke_map_dfc(
  .f,
  .x = list(NULL),
  ...,
  .env = NULL,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)
```

## Arguments

- .f:

  A list of functions.

- .x:

  A list of argument-lists the same length as `.f` (or length 1). The
  default argument, `list(NULL)`, will be recycled to the same length as
  `.f`, and will call each function with no arguments (apart from any
  supplied in `...`).

- ...:

  Additional arguments passed to each function.

- .env:

  Environment in which
  [`do.call()`](https://rdrr.io/r/base/do.call.html) should evaluate a
  constructed expression. This only matters if you pass as `.f` the name
  of a function rather than its value, or as `.x` symbols of objects
  rather than their values.

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

## Examples

``` r
plan(multisession, workers = 2)

df <- dplyr::tibble(
  f = c("runif", "rpois", "rnorm"),
  params = list(
    list(n = 10),
    list(n = 5, lambda = 10),
    list(n = 10, mean = -3, sd = 10)
  )
)

future_invoke_map(df$f, df$params, .options = furrr_options(seed = 123))
#> Warning: `invoke()` was deprecated in purrr 1.0.0.
#> ℹ Please use `exec()` instead.
#> Warning: `invoke()` was deprecated in purrr 1.0.0.
#> ℹ Please use `exec()` instead.
#> [[1]]
#>  [1] 0.15523168 0.13489836 0.77349355 0.06467378 0.72312291 0.34779719
#>  [7] 0.76720626 0.90894692 0.94261388 0.47246904
#> 
#> [[2]]
#> [1]  9 10  9  9  8
#> 
#> [[3]]
#>  [1]  -2.171833 -18.032800 -10.719393  15.365090   9.164918  -4.410979
#>  [7] -10.297802 -15.180494   1.718361  -4.452757
#> 
```
