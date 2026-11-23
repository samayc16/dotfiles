//! Koan 08: iterators and closures.

/// Squares of the even numbers, in order.
pub fn even_squares(xs: &[i32]) -> Vec<i32> {
    xs.iter().filter(|&&x| x % 2 == 0).map(|&x| x * x).collect()
}

/// How many words are longer than `min` bytes.
pub fn count_longer(text: &str, min: usize) -> usize {
    text.split_whitespace().filter(|word| word.len() > min).count()
}

/// The dot product, stopping at the end of the shorter slice.
pub fn dot(a: &[i64], b: &[i64]) -> i64 {
    a.iter().zip(b).map(|(x, y)| x * y).sum()
}

/// A closure with its own state: each call returns the next multiple of `step`.
pub fn counter(step: u32) -> impl FnMut() -> u32 {
    let mut n = 0;
    move || {
        n += step;
        n
    }
}

/// A function that applies `f` twice: twice(f)(x) == f(f(x)).
pub fn twice<F: Fn(i32) -> i32>(f: F) -> impl Fn(i32) -> i32 {
    move |x| f(f(x))
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
        let current = self.a;
        (self.a, self.b) = (self.b, self.a + self.b);
        Some(current)
    }
}

/// The sum of the even Fibonacci numbers below `limit`, using `Fib` and adapters.
pub fn even_fib_sum(limit: u64) -> u64 {
    Fib::new().take_while(|&x| x < limit).filter(|x| x % 2 == 0).sum()
}
