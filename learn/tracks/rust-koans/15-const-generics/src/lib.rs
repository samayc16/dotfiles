//! Koan 15: const generics.

/// A fixed-capacity stack that never allocates: the capacity N is part of the type,
/// so `Stack<i32, 4>` and `Stack<i32, 8>` are different types.
#[derive(Debug)]
pub struct Stack<T, const N: usize> {
    items: [Option<T>; N],
    len: usize,
}

impl<T: Copy, const N: usize> Stack<T, N> {
    pub fn new() -> Self {
        todo!()
    }

    /// Pushes `value`, or hands it back as `Err(value)` if the stack is full.
    pub fn push(&mut self, value: T) -> Result<(), T> {
        todo!()
    }

    pub fn pop(&mut self) -> Option<T> {
        todo!()
    }

    pub fn len(&self) -> usize {
        todo!()
    }

    pub fn is_empty(&self) -> bool {
        todo!()
    }

    pub fn capacity(&self) -> usize {
        todo!()
    }
}

impl<T: Copy, const N: usize> Default for Stack<T, N> {
    fn default() -> Self {
        Self::new()
    }
}

/// The sum of each complete group of N numbers; a shorter tail is ignored.
pub fn chunk_sums<const N: usize>(xs: &[i32]) -> Vec<i32> {
    const { assert!(N > 0, "chunk_sums::<0> makes no sense") }; // checked at compile time
    todo!()
}

/// An R×C matrix becomes C×R; the shapes are checked by the compiler.
pub fn transpose<const R: usize, const C: usize>(m: [[i32; C]; R]) -> [[i32; R]; C] {
    todo!()
}

/// The first N bytes as an array, or None if there aren't N of them.
pub fn first_n<const N: usize>(bytes: &[u8]) -> Option<[u8; N]> {
    todo!()
}
