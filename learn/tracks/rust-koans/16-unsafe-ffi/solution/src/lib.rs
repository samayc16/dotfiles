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
    let c = CString::new(s).ok()?;
    // SAFETY: `c` is a valid NUL-terminated string that lives until the end of this function.
    Some(unsafe { strlen(c.as_ptr()) })
}

/// |a - b|, using C's abs (declared `safe` above, so no unsafe block needed).
pub fn distance(a: i32, b: i32) -> i32 {
    abs(a - b)
}

/// qsort's comparator: C calls it with pointers to two elements of the array.
unsafe extern "C" fn compare_i32(a: *const c_void, b: *const c_void) -> c_int {
    // SAFETY: qsort only hands us pointers to elements of the slice c_sort gave it: i32s.
    let (a, b) = unsafe { (*a.cast::<i32>(), *b.cast::<i32>()) };
    a.cmp(&b) as c_int
}

/// Sorts with C's qsort, passing `compare_i32` as the callback.
pub fn c_sort(xs: &mut [i32]) {
    // SAFETY: base, count and size describe exactly `xs`, and compare_i32 reads i32s.
    unsafe { qsort(xs.as_mut_ptr().cast(), xs.len(), size_of::<i32>(), compare_i32) }
}

/// Sums `len` i32s starting at `ptr`.
///
/// # Safety
/// `ptr` must point to `len` initialised, readable i32s.
pub unsafe fn sum_raw(ptr: *const i32, len: usize) -> i32 {
    let mut total = 0;
    for i in 0..len {
        // SAFETY: the caller promised `len` readable i32s starting at `ptr`.
        total += unsafe { *ptr.add(i) };
    }
    total
}

/// The safe wrapper: a slice guarantees exactly what sum_raw needs.
pub fn sum(xs: &[i32]) -> i32 {
    // SAFETY: a slice's pointer and length always describe initialised elements.
    unsafe { sum_raw(xs.as_ptr(), xs.len()) }
}

/// Splits `xs` at `mid` into two non-overlapping mutable halves (panics if mid > len).
/// The borrow checker can't see that the halves don't overlap; you can.
pub fn split_mut(xs: &mut [i32], mid: usize) -> (&mut [i32], &mut [i32]) {
    let len = xs.len();
    assert!(mid <= len, "mid {mid} is past the end ({len})");
    let ptr = xs.as_mut_ptr();
    // SAFETY: [0, mid) and [mid, len) are both in bounds and don't overlap.
    unsafe { (slice::from_raw_parts_mut(ptr, mid), slice::from_raw_parts_mut(ptr.add(mid), len - mid)) }
}
