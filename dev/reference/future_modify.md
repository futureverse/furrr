# Modify elements selectively via futures

These functions work the same as
[`purrr::modify()`](https://purrr.tidyverse.org/reference/modify.html)
functions, but allow you to modify in parallel.

## Usage

``` r
future_modify(
  .x,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_modify_at(
  .x,
  .at,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)

future_modify_if(
  .x,
  .p,
  .f,
  ...,
  .else = NULL,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
)
```

## Arguments

- .x:

  A vector.

- .f:

  A function specified in the same way as the corresponding map
  function.

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

- .at:

  A logical, integer, or character vector giving the elements to select.
  Alternatively, a function that takes a vector of names, and returns a
  logical, integer, or character vector of elements to select.

  **\[deprecated\]**: if the tidyselect package is installed, you can
  use `vars()` and tidyselect helpers to select elements.

- .p:

  A single predicate function, a formula describing such a predicate
  function, or a logical vector of the same length as `.x`.
  Alternatively, if the elements of `.x` are themselves lists of
  objects, a string indicating the name of a logical element in the
  inner lists. Only those elements where `.p` evaluates to `TRUE` will
  be modified.

- .else:

  A function applied to elements of `.x` for which `.p` returns `FALSE`.

## Value

An object the same class as `.x`

## Details

From purrr:

Since the transformation can alter the structure of the input; it's your
responsibility to ensure that the transformation produces a valid
output. For example, if you're modifying a data frame, `.f` must
preserve the length of the input.

## Examples

``` r
library(magrittr)
plan(multisession, workers = 2)

# Convert each col to character, in parallel
future_modify(mtcars, as.character)
#>                      mpg cyl  disp  hp drat    wt  qsec vs am gear carb
#> Mazda RX4             21   6   160 110  3.9  2.62 16.46  0  1    4    4
#> Mazda RX4 Wag         21   6   160 110  3.9 2.875 17.02  0  1    4    4
#> Datsun 710          22.8   4   108  93 3.85  2.32 18.61  1  1    4    1
#> Hornet 4 Drive      21.4   6   258 110 3.08 3.215 19.44  1  0    3    1
#> Hornet Sportabout   18.7   8   360 175 3.15  3.44 17.02  0  0    3    2
#> Valiant             18.1   6   225 105 2.76  3.46 20.22  1  0    3    1
#> Duster 360          14.3   8   360 245 3.21  3.57 15.84  0  0    3    4
#> Merc 240D           24.4   4 146.7  62 3.69  3.19    20  1  0    4    2
#> Merc 230            22.8   4 140.8  95 3.92  3.15  22.9  1  0    4    2
#> Merc 280            19.2   6 167.6 123 3.92  3.44  18.3  1  0    4    4
#> Merc 280C           17.8   6 167.6 123 3.92  3.44  18.9  1  0    4    4
#> Merc 450SE          16.4   8 275.8 180 3.07  4.07  17.4  0  0    3    3
#> Merc 450SL          17.3   8 275.8 180 3.07  3.73  17.6  0  0    3    3
#> Merc 450SLC         15.2   8 275.8 180 3.07  3.78    18  0  0    3    3
#> Cadillac Fleetwood  10.4   8   472 205 2.93  5.25 17.98  0  0    3    4
#> Lincoln Continental 10.4   8   460 215    3 5.424 17.82  0  0    3    4
#> Chrysler Imperial   14.7   8   440 230 3.23 5.345 17.42  0  0    3    4
#> Fiat 128            32.4   4  78.7  66 4.08   2.2 19.47  1  1    4    1
#> Honda Civic         30.4   4  75.7  52 4.93 1.615 18.52  1  1    4    2
#> Toyota Corolla      33.9   4  71.1  65 4.22 1.835  19.9  1  1    4    1
#> Toyota Corona       21.5   4 120.1  97  3.7 2.465 20.01  1  0    3    1
#> Dodge Challenger    15.5   8   318 150 2.76  3.52 16.87  0  0    3    2
#> AMC Javelin         15.2   8   304 150 3.15 3.435  17.3  0  0    3    2
#> Camaro Z28          13.3   8   350 245 3.73  3.84 15.41  0  0    3    4
#> Pontiac Firebird    19.2   8   400 175 3.08 3.845 17.05  0  0    3    2
#> Fiat X1-9           27.3   4    79  66 4.08 1.935  18.9  1  1    4    1
#> Porsche 914-2         26   4 120.3  91 4.43  2.14  16.7  0  1    5    2
#> Lotus Europa        30.4   4  95.1 113 3.77 1.513  16.9  1  1    5    2
#> Ford Pantera L      15.8   8   351 264 4.22  3.17  14.5  0  1    5    4
#> Ferrari Dino        19.7   6   145 175 3.62  2.77  15.5  0  1    5    6
#> Maserati Bora         15   8   301 335 3.54  3.57  14.6  0  1    5    8
#> Volvo 142E          21.4   4   121 109 4.11  2.78  18.6  1  1    4    2

iris %>%
 future_modify_if(is.factor, as.character) %>%
 str()
#> 'data.frame':    150 obs. of  5 variables:
#>  $ Sepal.Length: num  5.1 4.9 4.7 4.6 5 5.4 4.6 5 4.4 4.9 ...
#>  $ Sepal.Width : num  3.5 3 3.2 3.1 3.6 3.9 3.4 3.4 2.9 3.1 ...
#>  $ Petal.Length: num  1.4 1.4 1.3 1.5 1.4 1.7 1.4 1.5 1.4 1.5 ...
#>  $ Petal.Width : num  0.2 0.2 0.2 0.2 0.2 0.4 0.3 0.2 0.2 0.1 ...
#>  $ Species     : chr  "setosa" "setosa" "setosa" "setosa" ...

mtcars %>%
  future_modify_at(c(1, 4, 5), as.character) %>%
  str()
#> 'data.frame':    32 obs. of  11 variables:
#>  $ mpg : chr  "21" "21" "22.8" "21.4" ...
#>  $ cyl : num  6 6 4 6 8 6 8 4 4 6 ...
#>  $ disp: num  160 160 108 258 360 ...
#>  $ hp  : chr  "110" "110" "93" "110" ...
#>  $ drat: chr  "3.9" "3.9" "3.85" "3.08" ...
#>  $ wt  : num  2.62 2.88 2.32 3.21 3.44 ...
#>  $ qsec: num  16.5 17 18.6 19.4 17 ...
#>  $ vs  : num  0 0 1 1 0 1 0 1 1 1 ...
#>  $ am  : num  1 1 1 0 0 0 0 0 0 0 ...
#>  $ gear: num  4 4 4 3 3 3 3 4 4 4 ...
#>  $ carb: num  4 4 1 1 2 1 4 2 2 4 ...
```
