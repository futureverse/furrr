# Deprecated furrr options

**\[defunct\]**

As of furrr 0.3.0, `future_options()` is defunct in favor of
[`furrr_options()`](https://furrr.futureverse.org/dev/reference/furrr_options.md).

## Usage

``` r
future_options(globals = TRUE, packages = NULL, seed = FALSE, scheduling = 1)
```

## Arguments

- globals:

  A logical, a character vector, a named list, or `NULL` for controlling
  how globals are handled. For details, see the `Global variables`
  section below.

- packages:

  A character vector, or `NULL`. If supplied, this specifies packages
  that are guaranteed to be attached in the R environment where the
  future is evaluated.

- seed:

  A logical, an integer of length `1` or `7`, a list of `length(.x)`
  with pre-generated random seeds, or `NULL`. For details, see the
  `Reproducible random number generation (RNG)` section below.

- scheduling:

  A single integer, logical, or `Inf`. This argument controls the
  average number of futures ("chunks") per worker.

  - If `0`, then a single future is used to process all elements of
    `.x`.

  - If `1` or `TRUE`, then one future per worker is used.

  - If `2`, then each worker will process two futures (provided there
    are enough elements in `.x`).

  - If `Inf` or `FALSE`, then one future per element of `.x` is used.

  This argument is only used if `chunk_size` is `NULL`.

## Examples

``` r
try(future_options())
#> Error : `future_options()` was deprecated in furrr 0.3.0 and is now defunct.
#> ℹ Please use `furrr_options()` instead.
```
