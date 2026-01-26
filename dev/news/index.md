# Changelog

## furrr (development version)

### Breaking changes

- All deprecated `future_invoke_map_*()` variants have been removed.

- All `*_raw()` variants from purrr have been removed, such as
  `future_map_raw()`. purrr 1.0.0 has deprecated these, they have
  limited use, and as far as we can tell no packages were using them
  ([\#298](https://github.com/futureverse/furrr/issues/298)).

- `future_options()` has been removed. It has been defunct since furrr
  0.3.0 (May 2022).

### Features / Fixes

- New
  [`future_map_vec()`](https://furrr.futureverse.org/dev/reference/future_map.md),
  [`future_map2_vec()`](https://furrr.futureverse.org/dev/reference/future_map2.md),
  [`future_pmap_vec()`](https://furrr.futureverse.org/dev/reference/future_map2.md),
  and
  [`future_imap_vec()`](https://furrr.futureverse.org/dev/reference/future_imap.md)
  to align with purrr
  ([\#261](https://github.com/futureverse/furrr/issues/261)).

- furrr now looks up the purrr mapping function on the worker itself,
  rather than sending over its own copy of the function. This avoids
  possible issues when you have, say, purrr 1.0.0 locally but purrr
  0.3.5 on the worker, where the internals of the purrr function may
  have changed between the two versions
  ([\#253](https://github.com/futureverse/furrr/issues/253)).

- Fixed a rare issue where the deprecated `.progress` bar may cause an
  integer overflow with extremely long inputs
  ([\#288](https://github.com/futureverse/furrr/issues/288)).

- Detangled furrr’s documentation from purrr’s to avoid some
  documentation inheritance issues
  ([\#286](https://github.com/futureverse/furrr/issues/286)).

- Fixed an issue where generating random seeds could sporadically fail
  ([\#271](https://github.com/futureverse/furrr/issues/271),
  [@HenrikBengtsson](https://github.com/HenrikBengtsson)).

- Updated documentation examples and vignettes to use the base R pipe
  ([\#285](https://github.com/futureverse/furrr/issues/285),
  [@HenrikBengtsson](https://github.com/HenrikBengtsson)).

### Version requirements

- furrr now requires R \>=4.1.0, which is in line with the tidyverse
  ([\#285](https://github.com/futureverse/furrr/issues/285)).

- lifecycle \>=1.0.5, rlang \>=1.1.7, purrr \>=1.2.1, vctrs \>=0.7.0,
  globals \>=0.18.0, and future \>=1.69.0 are now required.

## furrr 0.3.1

CRAN release: 2022-08-15

- Redocumented the package with roxygen2 7.2.1 to fix invalid HTML5
  issues ([\#242](https://github.com/futureverse/furrr/issues/242)).

## furrr 0.3.0

CRAN release: 2022-05-04

### Breaking changes

- `future_options()` is now defunct and will be removed in the next
  minor release of furrr. Please use
  [`furrr_options()`](https://furrr.futureverse.org/dev/reference/furrr_options.md)
  instead ([\#137](https://github.com/futureverse/furrr/issues/137)).

- The `lazy` argument of
  [`furrr_options()`](https://furrr.futureverse.org/dev/reference/furrr_options.md)
  has been completely removed. This argument had no effect, as futures
  are always resolved before the corresponding furrr function returns
  ([\#222](https://github.com/futureverse/furrr/issues/222)).

### Features / Fixes

- [`future_walk()`](https://furrr.futureverse.org/dev/reference/future_map.md)
  and the other walk functions now avoid sending the results of calling
  `.f` back to the main process
  ([\#205](https://github.com/futureverse/furrr/issues/205)).

- The `conditions` argument of
  [`furrr_options()`](https://furrr.futureverse.org/dev/reference/furrr_options.md)
  now supports selectively ignoring conditions through an `exclude`
  attribute. See
  [`?furrr_options`](https://furrr.futureverse.org/dev/reference/furrr_options.md)
  for more information
  ([\#181](https://github.com/futureverse/furrr/issues/181)).

- Standard output is now dropped from future results before they are
  returned to the main process
  ([\#216](https://github.com/futureverse/furrr/issues/216)).

- Condition objects are now dropped from future results before they are
  returned to the main process
  ([\#216](https://github.com/futureverse/furrr/issues/216)).

- Unskipped a test now that the upstream bug in future is fixed
  ([\#218](https://github.com/futureverse/furrr/issues/218),
  HenrikBengtsson/future.apply#10).

- Removed ellipsis in favor of the equivalent functions in rlang
  ([\#219](https://github.com/futureverse/furrr/issues/219)).

- Removed a multisession test related to whether or not an attempt was
  made to load furrr on the workers
  ([\#217](https://github.com/futureverse/furrr/issues/217)).

- Updated snapshot tests related to how testthat prints condition
  details ([\#213](https://github.com/futureverse/furrr/issues/213)).

### Version requirements

- furrr now requires R \>=3.4.0, which is in line with the tidyverse.

- lifecycle \>=1.0.1, rlang \>=1.0.2, purrr \>=0.3.4, vctrs \>=0.4.1,
  globals \>=0.14.0, and future \>=1.25.0 are now required
  ([\#214](https://github.com/futureverse/furrr/issues/214)).

## furrr 0.2.3

CRAN release: 2021-06-25

- Preemptively updated tests related to upcoming changes in testthat
  ([\#196](https://github.com/futureverse/furrr/issues/196)).

- Updated snapshot tests failing on CI related to changes in lifecycle
  1.0.0 ([\#193](https://github.com/futureverse/furrr/issues/193)).

## furrr 0.2.2

CRAN release: 2021-01-29

- Updated a test to fix an issue with upcoming lifecycle 1.0.0.

## furrr 0.2.1

CRAN release: 2020-10-21

- Updated documentation examples to explicitly set the seed on the
  workers when random numbers are generated
  ([\#175](https://github.com/futureverse/furrr/issues/175)).

- Removed an internal call to `future:::supportsMulticore()` since it is
  no longer internal
  ([\#174](https://github.com/futureverse/furrr/issues/174)).

## furrr 0.2.0

CRAN release: 2020-10-12

### Breaking changes:

- All furrr functions now enforce tidyverse recycling rules (for
  example, between `.x` and `.y` in
  [`future_map2()`](https://furrr.futureverse.org/dev/reference/future_map2.md)).
  Previously this was mostly the case, except with size zero input.
  Recycling between input of size 0 and input of size \>1 no longer
  recycles to size 0, and is instead an error. purrr will begin to do
  this as well in the next major release
  ([\#134](https://github.com/futureverse/furrr/issues/134)).

- `future_options()` has been deprecated in favor of
  [`furrr_options()`](https://furrr.futureverse.org/dev/reference/furrr_options.md).
  Calling `future_options()` will still work, but will trigger a once
  per session warning and will eventually be removed. This change was
  made to free up this function name in case the future package ever
  wants to use it.

- In a future version of furrr, the `.progress` argument will be
  deprecated and removed in favor of the
  [progressr](https://CRAN.R-project.org/package=progressr) package. The
  progress bar has not yet been removed in furrr 0.2.0, however I would
  encourage you to please start using progressr if possible. It uses a
  much more robust idea, and has been integrated with future in such a
  way that it can relay near real-time progress updates from sequential,
  multisession, and even cluster futures (meaning that remote
  connections can return live updates). Multicore support will come at
  some point as well. That said, be aware that it is a relatively new
  package and the API is still stabilizing. As more people use it, its
  place in the future ecosystem will become clearer, and tighter
  integration with furrr will likely be possible.

### Features / Fixes:

- [New pkgdown
  article](https://furrr.futureverse.org/articles/articles/progress.html)
  on using furrr with
  [progressr](https://CRAN.R-project.org/package=progressr) for
  generating progress updates.

- [New pkgdown
  article](https://furrr.futureverse.org/articles/articles/carrier.html)
  discussing an alternative strategy to automatic globals detection
  using the [carrier](https://CRAN.R-project.org/package=carrier)
  package.

- [New pkgdown
  article](https://furrr.futureverse.org/articles/articles/chunking.html)
  discussing how furrr “chunks” input to send if off to workers.

- [New pkgdown
  article](https://furrr.futureverse.org/articles/articles/gotchas.html)
  on common gotchas when using furrr.

- [New pkgdown
  article](https://furrr.futureverse.org/articles/articles/remote-connections.html)
  detailing how to use furrr with remote AWS EC2 connections.

- [`future_walk()`](https://furrr.futureverse.org/dev/reference/future_map.md)
  and friends have been added to mirror
  [`purrr::walk()`](https://purrr.tidyverse.org/reference/map.html).

- [`furrr_options()`](https://furrr.futureverse.org/dev/reference/furrr_options.md)
  now has a variety of new arguments for fine tuning furrr. These are
  based on advancements made in both future and future.apply. The most
  important is `chunk_size`, which can be used as an alternative to
  `scheduling` to determine how to break up `.x` into chunks to send off
  to the workers. See
  [`?furrr_options`](https://furrr.futureverse.org/dev/reference/furrr_options.md)
  for full details.

- [`future_pmap()`](https://furrr.futureverse.org/dev/reference/future_map2.md)
  and its variants now propagate the names of the first element of `.l`
  onto the output
  ([\#116](https://github.com/futureverse/furrr/issues/116)).

- [`future_pmap()`](https://furrr.futureverse.org/dev/reference/future_map2.md)
  and its variants now work with empty
  [`list()`](https://rdrr.io/r/base/list.html) input
  ([\#135](https://github.com/futureverse/furrr/issues/135)).

- [`future_modify()`](https://furrr.futureverse.org/dev/reference/future_modify.md),
  [`future_modify_if()`](https://furrr.futureverse.org/dev/reference/future_modify.md)
  and
  [`future_modify_at()`](https://furrr.futureverse.org/dev/reference/future_modify.md)
  have been brought up to date with the changes in purrr 0.3.0 to their
  non-parallel equivalents. Specifically, they now wrap `[[<-` and
  return the same type as the input when the input is an atomic vector
  ([\#119](https://github.com/futureverse/furrr/issues/119)).

- [`future_map_if()`](https://furrr.futureverse.org/dev/reference/future_map_if.md)
  and
  [`future_modify_if()`](https://furrr.futureverse.org/dev/reference/future_modify.md)
  gained the `.else` argument that was added to purrr’s
  [`map_if()`](https://purrr.tidyverse.org/reference/map_if.html) and
  [`modify_if()`](https://purrr.tidyverse.org/reference/modify.html) in
  purrr 0.3.0
  ([\#132](https://github.com/futureverse/furrr/issues/132)).

- All `*_raw()` variants from purrr have been added, such as
  `future_map_raw()`
  ([\#122](https://github.com/futureverse/furrr/issues/122)).

- All furrr functions gained a new argument, `.env_globals`, which
  determines the environment in which globals for `.x` and `...` are
  looked up. It defaults to the caller environment, which is different
  than what was previously used, but should be more correct in some edge
  cases. Most of the time, you should not have to touch this argument.
  Additionally, globals for `.f` are now looked up in the function
  environment of `.f` (HenrikBengtsson/future.apply#62,
  [\#153](https://github.com/futureverse/furrr/issues/153)).

- The future specific global option `future.globals.maxSize` now scales
  with the number of elements of `.x` that get exported to each worker.
  This helps prevent some false positives about exporting objects that
  are too large, and is the same approach taken in future.apply
  ([\#113](https://github.com/futureverse/furrr/issues/113)).

- `.x` is now searched for globals. Only globals found in the slice of
  `.x` that corresponds to worker X are exported to worker X. This is
  relevant if `.x` is, say, a list of functions where each has their own
  set of globals
  ([\#16](https://github.com/futureverse/furrr/issues/16)).

- The progress bar furrr creates now outputs to stderr rather than
  stdout.

- The progress bar is now only enabled for multisession, multicore, and
  multiprocess strategies. It has never worked for sequential futures or
  cluster futures using remote connections, but `.progress` is now
  forced to false in those cases.

- `future_invoke_map()` and its variants have been marked as retired to
  match
  [`purrr::invoke_map()`](https://purrr.tidyverse.org/reference/invoke.html).

- The internals of furrr have been overhauled to unify the
  implementations of
  [`future_map()`](https://furrr.futureverse.org/dev/reference/future_map.md),
  [`future_map2()`](https://furrr.futureverse.org/dev/reference/future_map2.md),
  [`future_pmap()`](https://furrr.futureverse.org/dev/reference/future_map2.md)
  and all of their variants. This should make furrr much easier to
  maintain going forward
  ([\#44](https://github.com/futureverse/furrr/issues/44)).

- A MIT license is now used.

### Version requirements:

- rlang \>= 0.3.0 is now required to ensure that the rlang `~` is
  serializable. The hacks in furrr that tried to work around this have
  been removed
  ([\#123](https://github.com/futureverse/furrr/issues/123)).

- future \>= 1.19.1 is now required to be able to use
  [`future::value()`](https://future.futureverse.org/reference/value.html)
  instead of the soon to be deprecated `future::values()` and to access
  a few bug fixes
  ([\#108](https://github.com/futureverse/furrr/issues/108)).

- purrr \>= 0.3.0 is now required to gain access to various new features
  and breaking changes. For example,
  [`map_if()`](https://purrr.tidyverse.org/reference/map_if.html) gained
  an `.else` argument, which has been added to
  [`future_map_if()`](https://furrr.futureverse.org/dev/reference/future_map_if.md).

- globals \>= 0.13.1 is now required because of substantial new speed
  boosts there related to searching for global variables, and to gain
  access to a few bug fixes.

## furrr 0.1.0

CRAN release: 2018-05-16

Features:

- `future_pmap_*()` functions have been added to mirror
  [`pmap()`](https://purrr.tidyverse.org/reference/pmap.html).

- The `future.*` arguments to each function have been replaced with an
  overarching `.options` argument. Use `future_options()` to create a
  set of options suitable to be passed to `.options`. This change
  streamlines the interface greatly, and simplifies documentation
  ([\#8](https://github.com/futureverse/furrr/issues/8),
  [@hadley](https://github.com/hadley)).

- `future_invoke_map_*()` functions have been added to mirror
  [`invoke_map()`](https://purrr.tidyverse.org/reference/invoke.html).

- More documentation and examples have been added.

- Added the ability to use a progress bar with `.progress = TRUE` for
  multicore, multiprocess, and multisession
  [`plan()`](https://future.futureverse.org/reference/plan.html)s.

Bug Fixes:

- Fixed a bug with using `~` inside a
  [`mutate()`](https://dplyr.tidyverse.org/reference/mutate.html) +
  [`map()`](https://purrr.tidyverse.org/reference/map.html) combination.

- Added a missed
  [`future_imap_int()`](https://furrr.futureverse.org/dev/reference/future_imap.md).

## furrr 0.0.0

- Original GitHub release of `furrr` on 2018-04-13.
