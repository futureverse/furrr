#' Apply a function to each element of a vector via futures
#'
#' These functions work the same as [purrr::map()] and its variants, but
#' allow you to map in parallel.
#'
#' @param .x A list or atomic vector.
#'
#' @param .f A function, specified in one of the following ways:
#'
#'   * A named function, e.g. `mean`.
#'   * An anonymous function, e.g. `\(x) x + 1` or `function(x) x + 1`.
#'   * A formula, e.g. `~ .x + 1`. Use `.x` to refer to the first
#'     argument. No longer recommended.
#'   * A string, integer, or list, e.g. `"idx"`, `1`, or `list("idx", 1)` which
#'     are shorthand for `\(x) pluck(x, "idx")`, `\(x) pluck(x, 1)`, and
#'     `\(x) pluck(x, "idx", 1)` respectively. Optionally supply `.default` to
#'     set a default value if the indexed element is `NULL` or does not exist.
#'
#' @param ... Additional arguments passed on to the mapped function.
#'
#'   We now generally recommend against using `...` to pass additional
#'   (constant) arguments to `.f`. Instead use a shorthand anonymous function:
#'
#'   ```R
#'   # Instead of
#'   x |> future_map(f, 1, 2, collapse = ",")
#'   # do:
#'   x |> future_map(\(x) f(x, 1, 2, collapse = ","))
#'   ```
#'
#'   This makes it easier to understand which arguments belong to which
#'   function and will tend to yield better error messages.
#'
#' @param .id Either a string or `NULL`. If a string, the output will contain
#'   a variable with that name, storing either the name (if `.x` is named) or
#'   the index (if `.x` is unnamed) of the input. If `NULL`, the default, no
#'   variable will be created.
#'
#'   Only applies to `_dfr` variant.
#'
#' @param .env_globals The environment to look for globals required by `.x` and
#'   `...`. Globals required by `.f` are looked up in the function environment
#'   of `.f`.
#'
#' @param .options The `future` specific options to use with the workers. This
#'   must be the result from a call to [furrr_options()].
#'
#' @param .progress A single logical. Should a progress bar be displayed?
#'   Only works with multisession, multicore, and multiprocess futures. Note
#'   that if a multicore/multisession future falls back to sequential, then
#'   a progress bar will not be displayed.
#'
#'   __Warning:__ The `.progress` argument will be deprecated and removed
#'   in a future version of furrr in favor of using the more robust
#'   [progressr](https://CRAN.R-project.org/package=progressr)
#'   package.
#'
#' @param .ptype If `NULL`, the default, the output type is the common type of
#'   the elements of the result. Otherwise, supply a "prototype" giving the
#'   desired type of output.
#'
#' @return All functions return a vector the same length as `.x`.
#'
#' - [future_map()] returns a list
#'
#' - [future_map_lgl()] a logical vector
#'
#' - [future_map_int()] an integer vector
#'
#' - [future_map_dbl()] a double vector
#'
#' - [future_map_chr()] a character vector
#'
#' The output of `.f` will be automatically typed upwards, e.g. logical ->
#' integer -> double -> character.
#'
#' @export
#' @examples
#' \donttest{plan(multisession, workers = 2)}
#'
#' 1:10 |>
#'   future_map(rnorm, n = 10, .options = furrr_options(seed = 123)) |>
#'   future_map_dbl(mean)
#'
#' # If each element of the output is a data frame, use
#' # `future_map_dfr()` to row-bind them together:
#' mtcars |>
#'   split(mtcars$cyl) |>
#'   future_map(~ lm(mpg ~ wt, data = .x)) |>
#'   future_map_dfr(~ as.data.frame(t(as.matrix(coef(.)))))
#'
#'
#' # You can be explicit about what gets exported to the workers.
#' # To see this, use multisession (not multicore as the forked workers
#' # still have access to this environment)
#' \donttest{plan(multisession)}
#' x <- 1
#' y <- 2
#'
#' # This will fail, y is not exported (no black magic occurs)
#' try(future_map(1, ~y, .options = furrr_options(globals = "x")))
#'
#' # y is exported
#' future_map(1, ~y, .options = furrr_options(globals = "y"))
#'
#' \dontshow{
#' # Close open connections for R CMD Check
#' if (!inherits(plan(), "sequential")) plan(sequential)
#' }
future_map <- function(
  .x,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
) {
  furrr_map_template(
    x = .x,
    fn = .f,
    dots = list(...),
    options = .options,
    progress = .progress,
    type = "list",
    purrr_fn_name = "map",
    env_globals = .env_globals
  )
}

#' @rdname future_map
#' @export
future_map_chr <- function(
  .x,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
) {
  furrr_map_template(
    x = .x,
    fn = .f,
    dots = list(...),
    options = .options,
    progress = .progress,
    type = "character",
    purrr_fn_name = "map_chr",
    env_globals = .env_globals
  )
}

#' @rdname future_map
#' @export
future_map_dbl <- function(
  .x,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
) {
  furrr_map_template(
    x = .x,
    fn = .f,
    dots = list(...),
    options = .options,
    progress = .progress,
    type = "double",
    purrr_fn_name = "map_dbl",
    env_globals = .env_globals
  )
}

#' @rdname future_map
#' @export
future_map_int <- function(
  .x,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
) {
  furrr_map_template(
    x = .x,
    fn = .f,
    dots = list(...),
    options = .options,
    progress = .progress,
    type = "integer",
    purrr_fn_name = "map_int",
    env_globals = .env_globals
  )
}

#' @rdname future_map
#' @export
future_map_lgl <- function(
  .x,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
) {
  furrr_map_template(
    x = .x,
    fn = .f,
    dots = list(...),
    options = .options,
    progress = .progress,
    type = "logical",
    purrr_fn_name = "map_lgl",
    env_globals = .env_globals
  )
}

#' @rdname future_map
#' @export
future_map_vec <- function(
  .x,
  .f,
  ...,
  .ptype = NULL,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
) {
  out <- future_map(
    .x = .x,
    .f = .f,
    ...,
    .options = .options,
    .env_globals = .env_globals,
    .progress = .progress
  )

  simplify_impl(
    out,
    ptype = .ptype,
    error_arg = "<output>",
    error_call = current_env()
  )
}

#' @rdname future_map
#' @export
future_map_dfr <- function(
  .x,
  .f,
  ...,
  .id = NULL,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
) {
  if (!rlang::is_installed("dplyr")) {
    rlang::abort("`future_map_dfr()` requires dplyr")
  }

  res <- future_map(
    .x = .x,
    .f = .f,
    ...,
    .options = .options,
    .env_globals = .env_globals,
    .progress = .progress
  )

  dplyr::bind_rows(res, .id = .id)
}

#' @rdname future_map
#' @export
future_map_dfc <- function(
  .x,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
) {
  if (!rlang::is_installed("dplyr")) {
    rlang::abort("`future_map_dfc()` requires dplyr")
  }

  res <- future_map(
    .x = .x,
    .f = .f,
    ...,
    .options = .options,
    .env_globals = .env_globals,
    .progress = .progress
  )

  dplyr::bind_cols(res)
}

# ------------------------------------------------------------------------------

#' Apply a function to each element of a vector conditionally via futures
#'
#' These functions work the same as [purrr::map_if()] and
#' [purrr::map_at()], but allow you to run them in parallel.
#'
#' @inheritParams future_map
#'
#' @param .p A single predicate function, a formula describing such a
#'   predicate function, or a logical vector of the same length as `.x`.
#'   Alternatively, if the elements of `.x` are themselves lists of
#'   objects, a string indicating the name of a logical element in the
#'   inner lists. Only those elements where `.p` evaluates to
#'   `TRUE` will be modified.
#'
#' @param .else A function applied to elements of `.x` for which `.p`
#' returns `FALSE`.
#'
#' @param .at A logical, integer, or character vector giving the elements
#'   to select. Alternatively, a function that takes a vector of names,
#'   and returns a logical, integer, or character vector of elements to select.
#'
#'   `r lifecycle::badge("deprecated")`: if the tidyselect package is
#'   installed, you can use `vars()` and tidyselect helpers to select
#'   elements.
#'
#' @return Both functions return a list the same length as `.x` with the
#' elements conditionally transformed.
#'
#' @export
#' @examples
#' \donttest{plan(multisession, workers = 2)}
#'
#' # Modify the even elements
#' future_map_if(1:5, ~.x %% 2 == 0L, ~ -1)
#'
#' future_map_at(1:5, c(1, 5), ~ -1)
#' \dontshow{
#' # Close open connections for R CMD Check
#' if (!inherits(plan(), "sequential")) plan(sequential)
#' }
future_map_if <- function(
  .x,
  .p,
  .f,
  ...,
  .else = NULL,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
) {
  sel <- probe(.x, .p)
  out <- vector("list", length = length(.x))

  out[sel] <- future_map(
    .x = .x[sel],
    .f = .f,
    ...,
    .options = .options,
    .env_globals = .env_globals,
    .progress = .progress
  )

  if (is_null(.else)) {
    out[!sel] <- .x[!sel]
  } else {
    out[!sel] <- future_map(
      .x = .x[!sel],
      .f = .else,
      ...,
      .options = .options,
      .env_globals = .env_globals,
      .progress = FALSE
    )
  }

  set_names(out, names(.x))
}

#' @rdname future_map_if
#' @export
future_map_at <- function(
  .x,
  .at,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
) {
  sel <- inv_which(.x, .at)
  out <- vector("list", length = length(.x))

  out[sel] <- future_map(
    .x = .x[sel],
    .f = .f,
    ...,
    .options = .options,
    .env_globals = .env_globals,
    .progress = .progress
  )

  out[!sel] <- .x[!sel]

  set_names(out, names(.x))
}
