# Options to fine tune furrr

`furrr_options()` returns an object that can be supplied as the
`.options` argument for furrr functions, such as
[`future_map()`](https://furrr.futureverse.org/reference/future_map.md).
The options are either used by furrr directly, or are passed on to
[`future::future()`](https://future.futureverse.org/reference/future.html).

## Usage

``` r
furrr_options(
  ...,
  stdout = TRUE,
  conditions = "condition",
  globals = TRUE,
  packages = NULL,
  seed = FALSE,
  scheduling = 1,
  chunk_size = NULL,
  prefix = NULL
)
```

## Arguments

- ...:

  These dots are reserved for future extensibility and must be empty.

- stdout:

  A logical.

  - If `TRUE`, standard output of the underlying futures is relayed as
    soon as possible.

  - If `FALSE`, output is silenced by sinking it to the null device.

- conditions:

  A character string of conditions classes to be relayed. The default is
  to relay all conditions, including messages and warnings. Errors are
  always relayed. To not relay any conditions (besides errors), use
  `conditions = character()`. To selectively ignore specific classes,
  use `conditions = structure("condition", exclude = "message")`.

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

- chunk_size:

  A single integer, `Inf`, or `NULL`. This argument controls the average
  number of elements per future (`"chunk"`). If `Inf`, then all elements
  are processed in a single future. If `NULL`, then `scheduling` is used
  instead to determine how `.x` is chunked.

- prefix:

  A single character string, or `NULL`. If a character string, then each
  future is assigned a label as `{prefix}-{chunk-id}`. If `NULL`, no
  labels are used.

## Global variables

`globals` controls how globals are identified, similar to the `globals`
argument of
[`future::future()`](https://future.futureverse.org/reference/future.html).
Since all function calls use the same set of globals, furrr gathers
globals upfront (once), which is more efficient than if it was done for
each future independently.

- If `TRUE` or `NULL`, then globals are automatically identified and
  gathered.

- If a character vector of names is specified, then those globals are
  gathered.

- If a named list, then those globals are used as is.

- In all cases, `.f` and any `...` arguments are automatically passed as
  globals to each future created, as they are always needed.

## Reproducible random number generation (RNG)

Unless `seed = FALSE`, furrr functions are guaranteed to generate the
exact same sequence of random numbers *given the same initial seed / RNG
state* regardless of the type of futures and scheduling ("chunking")
strategy.

Setting `seed = NULL` is equivalent to `seed = FALSE`, except that the
`future.rng.onMisuse` option is not consulted to potentially monitor the
future for faulty random number usage. See the `seed` argument of
[`future::future()`](https://future.futureverse.org/reference/future.html)
for more details.

RNG reproducibility is achieved by pre-generating the random seeds for
all iterations (over `.x`) by using L'Ecuyer-CMRG RNG streams. In each
iteration, these seeds are set before calling `.f(.x[[i]], ...)`. *Note,
for large `length(.x)` this may introduce a large overhead.*

A fixed `seed` may be given as an integer vector, either as a full
L'Ecuyer-CMRG RNG seed of length `7`, or as a seed of length `1` that
will be used to generate a full L'Ecuyer-CMRG seed.

If `seed = TRUE`, then `.Random.seed` is returned if it holds a
L'Ecuyer-CMRG RNG seed, otherwise one is created randomly.

If `seed = NA`, a L'Ecuyer-CMRG RNG seed is randomly created.

If none of the function calls `.f(.x[[i]], ...)` use random number
generation, then `seed = FALSE` may be used.

In addition to the above, it is possible to specify a pre-generated
sequence of RNG seeds as a list such that `length(seed) == length(.x)`
and where each element is an integer seed that can be assigned to
`.Random.seed`. Use this alternative with caution. *Note that
`as.list(seq_along(.x))` is not a valid set of such `.Random.seed`
values.*

In all cases but `seed = FALSE`, after a furrr function returns, the RNG
state of the calling R process is guaranteed to be "forwarded one step"
from the RNG state before the call. This is true regardless of the
future strategy / scheduling used. This is done in order to guarantee
that an R script calling
[`future_map()`](https://furrr.futureverse.org/reference/future_map.md)
multiple times should be numerically reproducible given the same initial
seed.

Note that you cannot expect identical results between
[`map()`](https://purrr.tidyverse.org/reference/map.html) and
[`future_map()`](https://furrr.futureverse.org/reference/future_map.md)
when using a `.f` that calls functions that generate random numbers,
even when calling [`set.seed()`](https://rdrr.io/r/base/Random.html)
ahead of time. For one thing, the default random number generation
algorithm used by R during sequential processing is Mersenne-Twister,
different from the L'Ecuyer-CMRG seeds used by furrr. But even aligning
the [`RNGkind()`](https://rdrr.io/r/base/Random.html) would not be
enough. [`map()`](https://purrr.tidyverse.org/reference/map.html) itself
would have to change to use the same parallel compatible RNG strategy as
[`future_map()`](https://furrr.futureverse.org/reference/future_map.md)
(pre-generating the seeds, and setting them before each `.f`
invocation). At the end of the day, you have to accept that the
following will produce different sequences of random numbers, but both
are statistically sound:

    set.seed(42)
    purrr::map(1:10, ~ rnorm(1))

    set.seed(42)
    furrr::future_map(1:10, ~ rnorm(1), .options = furrr_options(seed = TRUE))

But importantly, the
[`furrr::future_map()`](https://furrr.futureverse.org/reference/future_map.md)
example will always produce the same sequence of random numbers,
regardless of the
[`plan()`](https://future.futureverse.org/reference/plan.html) you
choose:

    plan(sequential)
    set.seed(42)
    furrr::future_map(1:10, ~ rnorm(1), .options = furrr_options(seed = TRUE))

    plan(multisession, workers = 2)
    set.seed(42)
    furrr::future_map(1:10, ~ rnorm(1), .options = furrr_options(seed = TRUE))

    plan(cluster, workers = workers)
    set.seed(42)
    furrr::future_map(1:10, ~ rnorm(1), .options = furrr_options(seed = TRUE))

## Examples

``` r
furrr_options()
#> <furrr_options>
```
