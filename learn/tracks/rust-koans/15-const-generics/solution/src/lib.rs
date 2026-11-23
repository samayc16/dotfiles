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
        Stack { items: [None; N], len: 0 }
    }

    /// Pushes `value`, or hands it back as `Err(value)` if the stack is full.
    pub fn push(&mut self, value: T) -> Result<(), T> {
        if self.len == N {
            return Err(value);
        }
        self.items[self.len] = Some(value);
        self.len += 1;
        Ok(())
    }

    pub fn pop(&mut self) -> Option<T> {
        self.len = self.len.checked_sub(1)?;
        self.items[self.len].take()
    }

    pub fn len(&self) -> usize {
        self.len
    }

    pub fn is_empty(&self) -> bool {
        self.len == 0
    }

    pub fn capacity(&self) -> usize {
        N
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
    let (chunks, _rest) = xs.as_chunks::<N>();
    chunks.iter().map(|chunk| chunk.iter().sum()).collect()
}

/// An R×C matrix becomes C×R; the shapes are checked by the compiler.
pub fn transpose<const R: usize, const C: usize>(m: [[i32; C]; R]) -> [[i32; R]; C] {
    let mut out = [[0; R]; C];
    for (r, row) in m.iter().enumerate() {
        for (c, &value) in row.iter().enumerate() {
            out[c][r] = value;
        }
    }
    out
}

/// The first N bytes as an array, or None if there aren't N of them.
pub fn first_n<const N: usize>(bytes: &[u8]) -> Option<[u8; N]> {
    bytes.get(..N)?.try_into().ok()
}
