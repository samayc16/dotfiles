//! Koan 08: iterators and closures.

/// Squares of the even numbers, in order.
pub fn even_squares(xs: &[i32]) -> Vec<i32> {
    todo!()
}

/// How many words are longer than `min` bytes.
pub fn count_longer(text: &str, min: usize) -> usize {
    todo!()
}

/// The dot product, stopping at the end of the shorter slice.
pub fn dot(a: &[i64], b: &[i64]) -> i64 {
    todo!()
}

/// A closure with its own state: each call returns the next multiple of `step`.
pub fn counter(step: u32) -> impl FnMut() -> u32 {
    move || todo!()
}

/// A function that applies `f` twice: twice(f)(x) == f(f(x)).
pub fn twice<F: Fn(i32) -> i32>(f: F) -> impl Fn(i32) -> i32 {
    move |_x| todo!()
}

/// The Fibonacci numbers 0, 1, 1, 2, 3, 5, … as an endless iterator.
pub struct Fib {
    a: u64,
    b: u64,
}

impl Fib {
    pub fn new() -> Self {
        Fib { a: 0, b: 1 }
    }
}

impl Default for Fib {
    fn default() -> Self {
        Self::new()
    }
}

impl Iterator for Fib {
    type Item = u64;

    fn next(&mut self) -> Option<u64> {
        todo!()
    }
}

/// The sum of the even Fibonacci numbers below `limit`, using `Fib` and adapters.
pub fn even_fib_sum(limit: u64) -> u64 {
    todo!()
}
