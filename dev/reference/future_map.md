# Apply a function to each element of a vector via futures

These functions work the same as
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

future_map_vec(
  .x,
  .f,
  ...,
  .ptype = NULL,
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

  A function, specified in one of the following ways:

  - A named function, e.g. `mean`.

  - An anonymous function, e.g. `\(x) x + 1` or `function(x) x + 1`.

  - A formula, e.g. `~ .x + 1`. Use `.x` to refer to the first argument.
    No longer recommended.

  - A string, integer, or list, e.g. `"idx"`, `1`, or `list("idx", 1)`
    which are shorthand for `\(x) pluck(x, "idx")`, `\(x) pluck(x, 1)`,
    and `\(x) pluck(x, "idx", 1)` respectively. Optionally supply
    `.default` to set a default value if the indexed element is `NULL`
    or does not exist.

- ...:

  Additional arguments passed on to the mapped function.

  We now generally recommend against using `...` to pass additional
  (constant) arguments to `.f`. Instead use a shorthand anonymous
  function:

      # Instead of
      x |> future_map(f, 1, 2, collapse = ",")
      # do:
      x |> future_map(\(x) f(x, 1, 2, collapse = ","))

  This makes it easier to understand which arguments belong to which
  function and will tend to yield better error messages.

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

- .ptype:

  If `NULL`, the default, the output type is the common type of the
  elements of the result. Otherwise, supply a "prototype" giving the
  desired type of output.

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
plan(multisession, workers = 2)

1:10 |>
  future_map(rnorm, n = 10, .options = furrr_options(seed = 123)) |>
  future_map_dbl(mean)
#>  [1] 1.180279 2.140442 2.909823 3.692207 5.058100 6.653926 7.065630 7.960713
#>  [9] 9.105674 9.766827

# If each element of the output is a data frame, use
# `future_map_dfr()` to row-bind them together:
mtcars |>
  split(mtcars$cyl) |>
  future_map(~ lm(mpg ~ wt, data = .x)) |>
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
