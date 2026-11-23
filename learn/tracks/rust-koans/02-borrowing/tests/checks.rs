//! The checks for this koan: each #[test] is one ✓/✗ line in `learn check`.
//! Read-only: `learn check` always runs the original, so editing this copy changes nothing.

use koan::*;

#[test]
fn sum_borrows_vecs_arrays_and_slices() {
    let v = vec![1, 2, 3, 4];
    assert_eq!(sum(&v), 10, "sum(&v)");
    assert_eq!(sum(&v[1..3]), 5, "sum(&v[1..3])");
    assert_eq!(sum(&[10, -10, 7]), 7, "sum(&[10, -10, 7])");
    assert_eq!(v.len(), 4, "v is still ours after lending it out");
}

#[test]
fn sum_of_nothing_is_zero() {
    assert_eq!(sum(&[]), 0);
}

#[test]
fn double_all_changes_the_callers_data() {
    let mut v = vec![1, -2, 3];
    double_all(&mut v);
    assert_eq!(v, vec![2, -4, 6], "after double_all(&mut v)");
    double_all(&mut v[..1]);
    assert_eq!(v, vec![4, -4, 6], "after double_all(&mut v[..1])");
}

#[test]
fn first_word_borrows_from_the_input() {
    let text = String::from("hello brave new world");
    let word = first_word(&text);
    assert_eq!(word, "hello");
    assert_eq!(word.as_ptr(), text.as_ptr(), "no copy: the word points into `text`");
}

#[test]
fn first_word_of_one_word_is_all_of_it() {
    assert_eq!(first_word("solo"), "solo");
    assert_eq!(first_word(""), "");
}

#[test]
fn trim_zeros_returns_a_subslice() {
    let data = [0, 0, 5, 0, 7, 0];
    assert_eq!(trim_zeros(&data), &[5, 0, 7], "trim_zeros(&[0, 0, 5, 0, 7, 0])");
    assert_eq!(trim_zeros(&[0, 0]), &[] as &[i64], "all zeros");
    assert_eq!(trim_zeros(&[4]), &[4], "nothing to trim");
}

#[test]
fn log_twice_appends_owned_copies() {
    let mut log = vec![String::from("boot")];
    log_twice(&mut log, "ping");
    assert_eq!(log, ["boot", "ping", "ping"]);
}
