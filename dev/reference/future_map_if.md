# Apply a function to each element of a vector conditionally via futures

These functions work the same as
[`purrr::map_if()`](https://purrr.tidyverse.org/reference/map_if.html)
and
[`purrr::map_at()`](https://purrr.tidyverse.org/reference/map_if.html),
but allow you to run them in parallel.

## Usage

``` r
future_map_if(
  .x,
  .p,
  .f,
  ...,
  .else = NULL,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_map_at(
  .x,
  .at,
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

- .p:

  A single predicate function, a formula describing such a predicate
  function, or a logical vector of the same length as `.x`.
  Alternatively, if the elements of `.x` are themselves lists of
  objects, a string indicating the name of a logical element in the
  inner lists. Only those elements where `.p` evaluates to `TRUE` will
  be modified.

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

- .else:

  A function applied to elements of `.x` for which `.p` returns `FALSE`.

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

- .at:

  A logical, integer, or character vector giving the elements to select.
  Alternatively, a function that takes a vector of names, and returns a
  logical, integer, or character vector of elements to select.

  **\[deprecated\]**: if the tidyselect package is installed, you can
  use `vars()` and tidyselect helpers to select elements.

## Value

Both functions return a list the same length as `.x` with the elements
conditionally transformed.

## Examples

``` r
plan(multisession, workers = 2)

# Modify the even elements
future_map_if(1:5, ~.x %% 2 == 0L, ~ -1)
#> [[1]]
#> [1] 1
#> 
#> [[2]]
#> [1] -1
#> 
#> [[3]]
#> [1] 3
#> 
#> [[4]]
#> [1] -1
#> 
#> [[5]]
#> [1] 5
#> 

future_map_at(1:5, c(1, 5), ~ -1)
#> [[1]]
#> [1] -1
#> 
#> [[2]]
#> [1] 2
#> 
#> [[3]]
#> [1] 3
#> 
#> [[4]]
#> [1] 4
#> 
#> [[5]]
#> [1] -1
#> 
```
