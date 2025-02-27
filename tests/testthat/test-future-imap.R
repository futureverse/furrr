furrr_test_that("imap functions work with unnamed input", {
  expect_identical(future_imap(1:2, ~.y), list(1L, 2L))
  expect_identical(future_imap_chr(1:2, ~as.character(.y)), c("1", "2"))
  expect_identical(future_imap_int(1:2, ~.y), c(1L, 2L))
  expect_identical(future_imap_dbl(1:2, ~.y), c(1, 2))
  expect_identical(future_imap_lgl(1:2, ~identical(.y, 1L)), c(TRUE, FALSE))
  expect_identical(future_imap_raw(1:2, ~raw(1)), raw(2))
  expect_identical(
    future_imap_dfr(1:2, ~data.frame(x = .y)),
    data.frame(x = c(1L, 2L))
  )
  expect_identical(
    future_imap_dfc(1:2, ~vctrs::new_data_frame(set_names(list(1), .y))),
    vctrs::new_data_frame(list(`1` = 1, `2` = 1))
  )
})

furrr_test_that("imap functions work with named input", {
  x <- set_names(1:2, c("x", "y"))
  expect_identical(future_imap(x, ~.y), list(x = "x", y = "y"))
  expect_identical(future_imap_chr(x, ~as.character(.y)), c(x = "x", y = "y"))
  expect_identical(
    future_imap_int(x, ~if (.y == "x") 1L else 2L),
    c(x = 1L, y = 2L)
  )
  expect_identical(
    future_imap_dbl(x, ~if (.y == "x") 1 else 2),
    c(x = 1, y = 2)
  )
  expect_identical(
    future_imap_lgl(x, ~if (.y == "x") TRUE else FALSE),
    c(x = TRUE, y = FALSE)
  )
  expect_identical(
    future_imap_raw(x, ~if (.y == "x") as.raw(1) else as.raw(2)),
    set_names(as.raw(c(1L, 2L)), c("x", "y"))
  )
  expect_identical(
    future_imap_dfr(x, ~data.frame(x = .y)),
    data.frame(x = c("x", "y"))
  )
  expect_identical(
    future_imap_dfc(x, ~vctrs::new_data_frame(set_names(list(1), .y))),
    vctrs::new_data_frame(list(x = 1, y = 1))
  )
})
