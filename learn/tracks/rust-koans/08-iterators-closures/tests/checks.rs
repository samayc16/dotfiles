//! The checks for this koan: each #[test] is one ✓/✗ line in `learn check`.
//! Read-only: `learn check` always runs the original, so editing this copy changes nothing.

use koan::*;

#[test]
fn even_squares_filters_then_maps() {
    assert_eq!(even_squares(&[1, 2, 3, 4, 6]), vec![4, 16, 36]);
    assert!(even_squares(&[]).is_empty(), "nothing in, nothing out");
}

#[test]
fn count_longer_captures_min() {
    assert_eq!(count_longer("a quick brown fox jumps", 3), 3);
}

#[test]
fn dot_zips_two_slices() {
    assert_eq!(dot(&[1, 2, 3], &[4, 5, 6]), 32);
    assert_eq!(dot(&[1, 2, 3], &[10]), 10, "stops at the shorter slice");
}

#[test]
fn counter_remembers_between_calls() {
    let mut next = counter(5);
    assert_eq!((next(), next(), next()), (5, 10, 15));
    let mut other = counter(2);
    assert_eq!(other(), 2, "each counter has its own state");
}

#[test]
fn twice_applies_a_function_two_times() {
    let add3 = twice(|x| x + 3);
    assert_eq!(add3(10), 16, "twice(x + 3) at 10");
    let offset = 100;
    let shift = twice(move |x| x * 2 + offset);
    assert_eq!(shift(1), 304, "twice(x * 2 + 100) at 1");
}

#[test]
fn fib_is_an_iterator() {
    let first: Vec<u64> = Fib::new().take(8).collect();
    assert_eq!(first, vec![0, 1, 1, 2, 3, 5, 8, 13]);
    assert_eq!(Fib::new().nth(10), Some(55), "every Iterator method comes for free");
}

#[test]
fn even_fib_sum_chains_adapters() {
    assert_eq!(even_fib_sum(100), 44, "0 + 2 + 8 + 34");
    assert_eq!(even_fib_sum(4_000_000), 4_613_732);
}
