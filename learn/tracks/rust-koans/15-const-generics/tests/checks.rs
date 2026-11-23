//! The checks for this koan: each #[test] is one ✓/✗ line in `learn check`.
//! Read-only: `learn check` always runs the original, so editing this copy changes nothing.

use koan::*;

#[test]
fn stack_capacity_is_in_the_type() {
    let stack: Stack<u8, 3> = Stack::new();
    assert_eq!(stack.capacity(), 3, "capacity()");
    assert!(stack.is_empty(), "a new stack is empty");
    assert_eq!(stack.len(), 0, "len()");
}

#[test]
fn stack_pushes_and_pops_last_in_first_out() {
    let mut stack: Stack<char, 4> = Stack::new();
    for c in ['a', 'b', 'c'] {
        assert_eq!(stack.push(c), Ok(()), "push({c:?})");
    }
    assert_eq!(stack.len(), 3, "len() after three pushes");
    assert_eq!(stack.pop(), Some('c'));
    assert_eq!(stack.pop(), Some('b'));
    assert_eq!(stack.len(), 1, "len() after two pops");
}

#[test]
fn a_full_stack_hands_the_value_back() {
    let mut stack: Stack<i32, 2> = Stack::new();
    assert_eq!(stack.push(1), Ok(()));
    assert_eq!(stack.push(2), Ok(()));
    assert_eq!(stack.push(3), Err(3), "push onto a full stack");
    assert_eq!(stack.len(), 2, "len() after the refused push");
}

#[test]
fn popping_an_empty_stack_is_none() {
    let mut stack: Stack<i32, 1> = Stack::new();
    assert_eq!(stack.pop(), None);
    assert_eq!(stack.len(), 0, "len() is still 0");
}

#[test]
fn chunk_sums_uses_the_const_parameter() {
    let xs = [1, 2, 3, 4, 5, 6, 7];
    assert_eq!(chunk_sums::<3>(&xs), vec![6, 15], "chunk_sums::<3>");
    assert_eq!(chunk_sums::<2>(&xs), vec![3, 7, 11], "chunk_sums::<2>");
}

#[test]
fn transpose_swaps_the_shape() {
    let m = [[1, 2, 3], [4, 5, 6]];
    let t: [[i32; 2]; 3] = transpose(m);
    assert_eq!(t, [[1, 4], [2, 5], [3, 6]]);
}

#[test]
fn first_n_takes_n_from_the_type() {
    let header: Option<[u8; 4]> = first_n(b"\x7fELF and more");
    assert_eq!(header, Some(*b"\x7fELF"));
    assert_eq!(first_n::<8>(b"short"), None, "only 5 bytes");
}
