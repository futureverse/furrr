# Apply a function to each element of a vector conditionally via futures

These functions work exactly the same as
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

  A character vector of names, positive numeric vector of positions to
  include, or a negative numeric vector of positions to exlude. Only
  those elements corresponding to `.at` will be modified. If the
  `tidyselect` package is installed, you can use `vars()` and the
  `tidyselect` helpers to select elements.

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
