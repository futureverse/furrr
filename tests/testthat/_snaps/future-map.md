# future_map_vec() works / strategy - sequential / cores - 1

    Code
      future_map_vec(1:2, ~NULL)
    Condition
      Error in `future_map_vec()`:
      ! `<output>[[1]]` must be a vector, not `NULL`.
      i Read our FAQ about scalar types (`?vctrs::faq_error_scalar_type`) to learn more.

---

    Code
      future_map_vec(1:2, ~ 1:2)
    Condition
      Error in `future_map_vec()`:
      ! `<output>[[1]]` must have size 1, not size 2.

---

    Code
      future_map_vec(1:2, ~ if (.x == 1L) 1 else "x")
    Condition
      Error in `future_map_vec()`:
      ! Can't combine `<output>[[1]]` <double> and `<output>[[2]]` <character>.

# future_map_vec() works / strategy - multisession / cores - 1

    Code
      future_map_vec(1:2, ~NULL)
    Condition
      Error in `future_map_vec()`:
      ! `<output>[[1]]` must be a vector, not `NULL`.
      i Read our FAQ about scalar types (`?vctrs::faq_error_scalar_type`) to learn more.

---

    Code
      future_map_vec(1:2, ~ 1:2)
    Condition
      Error in `future_map_vec()`:
      ! `<output>[[1]]` must have size 1, not size 2.

---

    Code
      future_map_vec(1:2, ~ if (.x == 1L) 1 else "x")
    Condition
      Error in `future_map_vec()`:
      ! Can't combine `<output>[[1]]` <double> and `<output>[[2]]` <character>.

# future_map_vec() works / strategy - multisession / cores - 2

    Code
      future_map_vec(1:2, ~NULL)
    Condition
      Error in `future_map_vec()`:
      ! `<output>[[1]]` must be a vector, not `NULL`.
      i Read our FAQ about scalar types (`?vctrs::faq_error_scalar_type`) to learn more.

---

    Code
      future_map_vec(1:2, ~ 1:2)
    Condition
      Error in `future_map_vec()`:
      ! `<output>[[1]]` must have size 1, not size 2.

---

    Code
      future_map_vec(1:2, ~ if (.x == 1L) 1 else "x")
    Condition
      Error in `future_map_vec()`:
      ! Can't combine `<output>[[1]]` <double> and `<output>[[2]]` <character>.

# future_map_vec() works / strategy - multicore / cores - 1

    Code
      future_map_vec(1:2, ~NULL)
    Condition
      Error in `future_map_vec()`:
      ! `<output>[[1]]` must be a vector, not `NULL`.
      i Read our FAQ about scalar types (`?vctrs::faq_error_scalar_type`) to learn more.

---

    Code
      future_map_vec(1:2, ~ 1:2)
    Condition
      Error in `future_map_vec()`:
      ! `<output>[[1]]` must have size 1, not size 2.

---

    Code
      future_map_vec(1:2, ~ if (.x == 1L) 1 else "x")
    Condition
      Error in `future_map_vec()`:
      ! Can't combine `<output>[[1]]` <double> and `<output>[[2]]` <character>.

# future_map_vec() works / strategy - multicore / cores - 2

    Code
      future_map_vec(1:2, ~NULL)
    Condition
      Error in `future_map_vec()`:
      ! `<output>[[1]]` must be a vector, not `NULL`.
      i Read our FAQ about scalar types (`?vctrs::faq_error_scalar_type`) to learn more.

---

    Code
      future_map_vec(1:2, ~ 1:2)
    Condition
      Error in `future_map_vec()`:
      ! `<output>[[1]]` must have size 1, not size 2.

---

    Code
      future_map_vec(1:2, ~ if (.x == 1L) 1 else "x")
    Condition
      Error in `future_map_vec()`:
      ! Can't combine `<output>[[1]]` <double> and `<output>[[2]]` <character>.

# errors don't report purrr's indices (#250) / strategy - sequential / cores - 1

    Code
      future_map(x, fail_on_five)
    Condition
      Error in `...furrr_fn()`:
      ! Failure!

# errors don't report purrr's indices (#250) / strategy - multisession / cores - 1

    Code
      future_map(x, fail_on_five)
    Condition
      Error in `...furrr_fn()`:
      ! Failure!

# errors don't report purrr's indices (#250) / strategy - multisession / cores - 2

    Code
      future_map(x, fail_on_five)
    Condition
      Error in `...furrr_fn()`:
      ! Failure!

# errors don't report purrr's indices (#250) / strategy - multicore / cores - 1

    Code
      future_map(x, fail_on_five)
    Condition
      Error in `...furrr_fn()`:
      ! Failure!

# errors don't report purrr's indices (#250) / strategy - multicore / cores - 2

    Code
      future_map(x, fail_on_five)
    Condition
      Error in `...furrr_fn()`:
      ! Failure!

