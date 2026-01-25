# Map over multiple inputs simultaneously via futures

These functions work the same as
[`purrr::map2()`](https://purrr.tidyverse.org/reference/map2.html) and
its variants, but allow you to map in parallel. Note that "parallel" as
described in purrr is just saying that you are working with multiple
inputs, and parallel in this case means that you can work on multiple
inputs and process them all in parallel as well.

## Usage

``` r
future_map2(
  .x,
  .y,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_map2_chr(
  .x,
  .y,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_map2_dbl(
  .x,
  .y,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_map2_int(
  .x,
  .y,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_map2_lgl(
  .x,
  .y,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_map2_vec(
  .x,
  .y,
  .f,
  ...,
  .ptype = NULL,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_map2_dfr(
  .x,
  .y,
  .f,
  ...,
  .id = NULL,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_map2_dfc(
  .x,
  .y,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_pmap(
  .l,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_pmap_chr(
  .l,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_pmap_dbl(
  .l,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_pmap_int(
  .l,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_pmap_lgl(
  .l,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_pmap_vec(
  .l,
  .f,
  ...,
  .ptype = NULL,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_pmap_dfr(
  .l,
  .f,
  ...,
  .id = NULL,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_pmap_dfc(
  .l,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_walk2(
  .x,
  .y,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_pwalk(
  .l,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)
```

## Arguments

- .x, .y:

  A pair of vectors, usually the same length. If not, a vector of length
  1 will be recycled to the length of the other.

- .f:

  A function, specified in one of the following ways:

  - A named function.

  - An anonymous function, e.g. `\(x, y) x + y` or
    `function(x, y) x + y`.

  - A formula, e.g. `~ .x + .y`. Use `.x` to refer to the current
    element of `x` and `.y` to refer to the current element of `y`. No
    longer recommended.

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

- .l:

  A list of vectors. The length of `.l` determines the number of
  arguments that `.f` will be called with. Arguments will be supply by
  position if unnamed, and by name if named.

  Vectors of length 1 will be recycled to any length; all other elements
  must be have the same length.

  A data frame is an important special case of `.l`. It will cause `.f`
  to be called once for each row.

## Value

An atomic vector, list, or data frame, depending on the suffix. Atomic
vectors and lists will be named if `.x` or the first element of `.l` is
named.

If all input is length 0, the output will be length 0. If any input is
length 1, it will be recycled to the length of the longest.

## Examples

``` r
plan(multisession, workers = 2)

x <- list(1, 10, 100)
y <- list(1, 2, 3)
z <- list(5, 50, 500)

future_map2(x, y, ~ .x + .y)
#> [[1]]
#> [1] 2
#> 
#> [[2]]
#> [1] 12
#> 
#> [[3]]
#> [1] 103
#> 

# Split into pieces, fit model to each piece, then predict
by_cyl <- split(mtcars, mtcars$cyl)
mods <- future_map(by_cyl, ~ lm(mpg ~ wt, data = .))
future_map2(mods, by_cyl, predict)
#> $`4`
#>     Datsun 710      Merc 240D       Merc 230       Fiat 128    Honda Civic 
#>       26.47010       21.55719       21.78307       27.14774       30.45125 
#> Toyota Corolla  Toyota Corona      Fiat X1-9  Porsche 914-2   Lotus Europa 
#>       29.20890       25.65128       28.64420       27.48656       31.02725 
#>     Volvo 142E 
#>       23.87247 
#> 
#> $`6`
#>      Mazda RX4  Mazda RX4 Wag Hornet 4 Drive        Valiant       Merc 280 
#>       21.12497       20.41604       19.47080       18.78968       18.84528 
#>      Merc 280C   Ferrari Dino 
#>       18.84528       20.70795 
#> 
#> $`8`
#>   Hornet Sportabout          Duster 360          Merc 450SE          Merc 450SL 
#>            16.32604            16.04103            14.94481            15.69024 
#>         Merc 450SLC  Cadillac Fleetwood Lincoln Continental   Chrysler Imperial 
#>            15.58061            12.35773            11.97625            12.14945 
#>    Dodge Challenger         AMC Javelin          Camaro Z28    Pontiac Firebird 
#>            16.15065            16.33700            15.44907            15.43811 
#>      Ford Pantera L       Maserati Bora 
#>            16.91800            16.04103 
#> 

future_pmap(list(x, y, z), sum)
#> [[1]]
#> [1] 7
#> 
#> [[2]]
#> [1] 62
#> 
#> [[3]]
#> [1] 603
#> 

# Matching arguments by position
future_pmap(list(x, y, z), function(a, b ,c) a / (b + c))
#> [[1]]
#> [1] 0.1666667
#> 
#> [[2]]
#> [1] 0.1923077
#> 
#> [[3]]
#> [1] 0.1988072
#> 

# Vectorizing a function over multiple arguments
df <- data.frame(
  x = c("apple", "banana", "cherry"),
  pattern = c("p", "n", "h"),
  replacement = c("x", "f", "q"),
  stringsAsFactors = FALSE
)

future_pmap(df, gsub)
#> [[1]]
#> [1] "axxle"
#> 
#> [[2]]
#> [1] "bafafa"
#> 
#> [[3]]
#> [1] "cqerry"
#> 
future_pmap_chr(df, gsub)
#> [1] "axxle"  "bafafa" "cqerry"
```
