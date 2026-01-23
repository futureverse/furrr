#' @rdname future_map2
#' @export
future_pmap <- function(
  .l,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
) {
  furrr_pmap_template(
    l = .l,
    fn = .f,
    dots = list(...),
    options = .options,
    progress = .progress,
    type = "list",
    purrr_fn_name = "pmap",
    env_globals = .env_globals
  )
}

#' @rdname future_map2
#' @export
future_pmap_chr <- function(
  .l,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
) {
  furrr_pmap_template(
    l = .l,
    fn = .f,
    dots = list(...),
    options = .options,
    progress = .progress,
    type = "character",
    purrr_fn_name = "pmap_chr",
    env_globals = .env_globals
  )
}

#' @rdname future_map2
#' @export
future_pmap_dbl <- function(
  .l,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
) {
  furrr_pmap_template(
    l = .l,
    fn = .f,
    dots = list(...),
    options = .options,
    progress = .progress,
    type = "double",
    purrr_fn_name = "pmap_dbl",
    env_globals = .env_globals
  )
}

#' @rdname future_map2
#' @export
future_pmap_int <- function(
  .l,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
) {
  furrr_pmap_template(
    l = .l,
    fn = .f,
    dots = list(...),
    options = .options,
    progress = .progress,
    type = "integer",
    purrr_fn_name = "pmap_int",
    env_globals = .env_globals
  )
}

#' @rdname future_map2
#' @export
future_pmap_lgl <- function(
  .l,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
) {
  furrr_pmap_template(
    l = .l,
    fn = .f,
    dots = list(...),
    options = .options,
    progress = .progress,
    type = "logical",
    purrr_fn_name = "pmap_lgl",
    env_globals = .env_globals
  )
}

#' @rdname future_map2
#' @export
future_pmap_dfr <- function(
  .l,
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

  res <- future_pmap(
    .l = .l,
    .f = .f,
    ...,
    .options = .options,
    .env_globals = .env_globals,
    .progress = .progress
  )

  dplyr::bind_rows(res, .id = .id)
}

#' @rdname future_map2
#' @export
future_pmap_dfc <- function(
  .l,
  .f,
  ...,
  .options = furrr_options(),
  .env_globals = parent.frame(),
  .progress = FALSE
) {
  if (!rlang::is_installed("dplyr")) {
    rlang::abort("`future_map_dfc()` requires dplyr")
  }

  res <- future_pmap(
    .l = .l,
    .f = .f,
    ...,
    .options = .options,
    .env_globals = .env_globals,
    .progress = .progress
  )

  dplyr::bind_cols(res)
}
