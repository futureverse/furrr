# Alternative to automatic globals detection

``` r
library(furrr)
library(carrier)
```

## Introduction

When writing production code with furrr, you might not want to leave it
up to automatic globals detection to ensure that everything is shipped
off to the worker correctly. While it generally works well, there will
always be edge cases with static code analysis that may cause it to
either fail (very bad) or copy more objects over to the workers than is
required (less bad, but still not great).

As an alternative, you can use the
[carrier](https://CRAN.R-project.org/package=carrier) package by Lionel
Henry to manually isolate all of the dependencies required by your
function. This ensures that the function’s environment contains *only*
what you have requested, and nothing more. Combine this with
`furrr_options(globals = FALSE)` to turn off automatic globals
detection, and you should end up with a production worthy way to use
furrr.

## Crates

The idea behind carrier is to package up a function and all of its
dependencies into a *crate*. A crate is just another function, but with
a specialized function environment that carries around only the
dependencies required for it to run. To create a crate, directly wrap a
call to `function()` with
[`crate()`](https://rdrr.io/pkg/carrier/man/crate.html).

``` r
crt1 <- crate(function(x) {
  stats::var(x)
})

crt1(c(1, 5, 3))
#> [1] 4
```

You can also specify the function to crate using the anonymous function
shorthand with `~`.

``` r
crt1_anon <- crate(~stats::var(.x))

crt1_anon(c(1, 5, 3))
#> [1] 4
```

You must manually namespace all package function calls with `pkg::`, as
the crated function runs in an environment where only the base package
has been loaded.

``` r
crt2 <- crate(function(x) {
  var(x)
})

crt2(c(1, 5, 3))
#> Error in `var()`:
#> ! could not find function "var"
```

Any “outside” dependencies that you require must also be manually
specified when creating the crate, otherwise it won’t be found.

``` r
constant <- 1.67

crt3 <- crate(~ .x + constant)

crt3(2:5)
#> Error in `crt3()`:
#> ! object 'constant' not found
```

You can specify these dependencies by either inlining them into the
crate with `!!`, or by supplying them as name-value pairs to
[`crate()`](https://rdrr.io/pkg/carrier/man/crate.html):

``` r
crt4 <- crate(function(x) {
  x + !!constant
})

crt4(2:5)
#> [1] 3.67 4.67 5.67 6.67
```

``` r
crt5 <- crate(
  constant = constant,
  function(x) {
    x + constant
  }
)

crt5(2:5)
#> [1] 3.67 4.67 5.67 6.67
```

Crates have a nice print method, allowing you to see the size of the
crate and what has been captured:

``` r
crt5
#> <crate> 1.34 kB
#> * function: 672 B
#> * `constant`: 56 B
#> function (x) 
#> {
#>     x + constant
#> }
```

One downside of inlining with `!!` is that it doesn’t show up as a
separate element in the print method:

``` r
crt4
#> <crate> 1.23 kB
#> * function: 672 B
#> function (x) 
#> {
#>     x + 1.67
#> }
```

The last thing to know about crates is that it is generally required
that you crate a new function. By “new”, I mean that the function cannot
have already been created beforehand and assigned a name, because this
prevents [`crate()`](https://rdrr.io/pkg/carrier/man/crate.html) from
assigning it the correct environment.

``` r
fn <- function(x) {
  x
}

crate(fn)
#> Error in `crate()`:
#> ! The function must be defined inside this call
```

## Crates and furrr

Using a crated function with furrr is just like using any other
function, except you won’t need to rely on the automatic globals
detection (unless you have globals in `.x` or `...` that need to be
found, but this is somewhat rare).

As an example, when `crt5()` was created we also captured the `constant`
dependency object in the function’s environment. Since furrr serializes
`.f` alongside its environment, the dependencies come along for free
without the need to auto detect them.

``` r
crt5
#> <crate> 1.34 kB
#> * function: 672 B
#> * `constant`: 56 B
#> function (x) 
#> {
#>     x + constant
#> }
```

``` r
plan(multisession, workers = 2)

opts <- furrr_options(globals = FALSE)

x <- list(1:10, 11:20)

future_map(x, crt5, .options = opts)
#> [[1]]
#>  [1]  2.67  3.67  4.67  5.67  6.67  7.67  8.67  9.67 10.67 11.67
#> 
#> [[2]]
#>  [1] 12.67 13.67 14.67 15.67 16.67 17.67 18.67 19.67 20.67 21.67
```

If you crate a function with extra optional arguments, you can still
pass those through using furrr:

``` r
median_doubled <- crate(function(x, na.rm = FALSE) {
  stats::median(x, na.rm = na.rm) * 2
})
```

``` r
plan(multisession, workers = 2)

opts <- furrr_options(globals = FALSE)

x <- list(c(1, NA, 2), c(4, 5, NA))

future_map_dbl(x, median_doubled, na.rm = TRUE, .options = opts)
#> [1] 3 9
```

Crates are also a great way to avoid accidentally shipping unneeded
dependencies. In the *Common Gotchas* article, we discuss the following
example of accidentally shipping this `big` object to each worker, even
though it isn’t required by the function itself. This function call
should be extremely fast, but is significantly slower than expected
because it has to serialize `big`.

``` r
my_slow_fn <- function() {
  # Massive object - but we don't want it in `.f`
  big <- 1:1e8 + 0L
  
  future_map_int(1:5, ~.x)
}
```

``` r
plan(multisession, workers = 2)

system.time({
  my_slow_fn()
})
#>    user  system elapsed 
#>   0.373   0.287   1.453
```

One way to avoid this is to use carrier to crate the function, isolating
it from the surrounding environment.

``` r
my_crated_fn <- function() {
  # Massive object - but we don't want it in `.f`
  big <- 1:1e8 + 0L
  
  fn <- crate(~.x)
  opts <- furrr_options(globals = FALSE)
  
  future_map_int(1:5, fn, .options = opts)
}
```

``` r
plan(multisession, workers = 2)

system.time({
  my_crated_fn()
})
#>    user  system elapsed 
#>   0.176   0.067   0.461
```
