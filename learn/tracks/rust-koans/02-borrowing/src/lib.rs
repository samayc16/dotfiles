//! Koan 02: borrowing. A reference lets a function use a value without owning it.
//! The rule: at any moment, EITHER any number of `&T` OR exactly one `&mut T`.

/// The sum of the numbers. Borrows a slice, so it works on a whole Vec (`&v`),
/// an array (`&[1, 2]`) or part of one (`&v[1..]`).
pub fn sum(xs: &[i64]) -> i64 {
    todo!()
}

/// Doubles every number in place: the caller sees the change.
pub fn double_all(xs: &mut [i64]) {
    todo!()
}

/// The text before the first space (all of `s` if there is none). The result borrows
/// from `s`: it points into the same bytes.
pub fn first_word(s: &str) -> &str {
    todo!()
}

/// `xs` without its leading and trailing zeros, as a sub-slice of `xs`.
pub fn trim_zeros(xs: &[i64]) -> &[i64] {
    todo!()
}

/// Appends two owned copies of `line` to `log`.
pub fn log_twice(log: &mut Vec<String>, line: &str) {
    todo!()
}
