# Apply a function to each element of a vector, and its index via futures

These functions work the same as
[`purrr::imap()`](https://purrr.tidyverse.org/reference/imap.html)
functions, but allow you to map in parallel.

## Usage

``` r
future_imap(
  .x,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_imap_chr(
  .x,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_imap_dbl(
  .x,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_imap_int(
  .x,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_imap_lgl(
  .x,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_imap_raw(
  .x,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_imap_dfr(
  .x,
  .f,
  ...,
  .id = NULL,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_imap_dfc(
  .x,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_iwalk(
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

  - A named function, e.g. `paste`.

  - An anonymous function, e.g. `\(x, idx) x + idx` or
    `function(x, idx) x + idx`.

  - A formula, e.g. `~ .x + .y`. Use `.x` to refer to the current
    element and `.y` to refer to the current index. No longer
    recommended.

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

- .id:

  Either a string or `NULL`. If a string, the output will contain a
  variable with that name, storing either the name (if `.x` is named) or
  the index (if `.x` is unnamed) of the input. If `NULL`, the default,
  no variable will be created.

  Only applies to `_dfr` variant.

## Value

A vector the same length as .x.

## Examples

``` r
plan(multisession, workers = 2)

future_imap_chr(sample(10), ~ paste0(.y, ": ", .x))
#>  [1] "1: 5"  "2: 6"  "3: 7"  "4: 8"  "5: 4"  "6: 1"  "7: 10" "8: 9"  "9: 3" 
#> [10] "10: 2"
```
