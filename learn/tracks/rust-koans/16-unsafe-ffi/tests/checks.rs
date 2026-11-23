//! The checks for this koan: each #[test] is one ✓/✗ line in `learn check`.
//! Read-only: `learn check` always runs the original, so editing this copy changes nothing.

use koan::*;

#[test]
fn c_strlen_counts_bytes() {
    assert_eq!(c_strlen("hello"), Some(5));
    assert_eq!(c_strlen("héllo"), Some(6), "UTF-8: é is two bytes");
    assert_eq!(c_strlen(""), Some(0), "the empty string");
}

#[test]
fn c_strlen_rejects_an_interior_nul() {
    assert_eq!(c_strlen("a\0b"), None);
}

#[test]
fn distance_calls_a_safe_c_function() {
    assert_eq!(distance(3, 10), 7);
    assert_eq!(distance(-4, -9), 5);
}

#[test]
fn c_sort_sorts_through_a_callback() {
    let mut v = vec![5, -1, 3, 3, 0, 42, -7];
    c_sort(&mut v);
    assert_eq!(v, vec![-7, -1, 0, 3, 3, 5, 42]);
}

#[test]
fn sum_raw_reads_through_a_pointer() {
    let xs = [1, 2, 3, 4];
    // SAFETY: xs[1..3] is two valid i32s.
    let total = unsafe { sum_raw(xs.as_ptr().add(1), 2) };
    assert_eq!(total, 5, "sum_raw(&xs[1], 2)");
}

#[test]
fn sum_is_a_safe_wrapper() {
    assert_eq!(sum(&[10, 20, 30]), 60);
    assert_eq!(sum(&[]), 0, "an empty slice");
}

#[test]
fn split_mut_gives_two_disjoint_halves() {
    let mut v = [1, 2, 3, 4, 5];
    let (left, right) = split_mut(&mut v, 2);
    left[0] = 10;
    right[0] = 30;
    assert_eq!(left, [10, 2], "left half");
    assert_eq!(right, [30, 4, 5], "right half");
    assert_eq!(v, [10, 2, 30, 4, 5], "both writes landed in v");
}
