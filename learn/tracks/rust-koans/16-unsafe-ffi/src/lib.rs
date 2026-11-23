//! Koan 16: unsafe and FFI.

use std::ffi::{CString, c_char, c_int, c_void};
use std::slice;

// Functions from the C standard library, which every Rust program links. Declaring them is a
// promise the compiler can't check, so the block is `unsafe extern` (2024 edition), and
// calling them is unsafe unless the item is marked `safe`.
unsafe extern "C" {
    fn strlen(s: *const c_char) -> usize;
    safe fn abs(x: c_int) -> c_int;
    fn qsort(
        base: *mut c_void,
        count: usize,
        size: usize,
        compare: unsafe extern "C" fn(*const c_void, *const c_void) -> c_int,
    );
}

/// The length of `s` as C's strlen sees it, or None if `s` contains a NUL byte
/// (a C string can't). CString adds the terminating NUL.
pub fn c_strlen(s: &str) -> Option<usize> {
    todo!()
}

/// |a - b|, using C's abs (declared `safe` above, so no unsafe block needed).
pub fn distance(a: i32, b: i32) -> i32 {
    todo!()
}

/// qsort's comparator: C calls it with pointers to two elements of the array.
unsafe extern "C" fn compare_i32(a: *const c_void, b: *const c_void) -> c_int {
    0 // TODO: read both as i32s and compare them (and never panic in here: C can't unwind)
}

/// Sorts with C's qsort, passing `compare_i32` as the callback.
pub fn c_sort(xs: &mut [i32]) {
    todo!()
}

/// Sums `len` i32s starting at `ptr`.
///
/// # Safety
/// `ptr` must point to `len` initialised, readable i32s.
pub unsafe fn sum_raw(ptr: *const i32, len: usize) -> i32 {
    todo!()
}

/// The safe wrapper: a slice guarantees exactly what sum_raw needs.
pub fn sum(xs: &[i32]) -> i32 {
    todo!()
}

/// Splits `xs` at `mid` into two non-overlapping mutable halves (panics if mid > len).
/// The borrow checker can't see that the halves don't overlap; you can.
pub fn split_mut(xs: &mut [i32], mid: usize) -> (&mut [i32], &mut [i32]) {
    let len = xs.len();
    assert!(mid <= len, "mid {mid} is past the end ({len})");
    todo!()
}
