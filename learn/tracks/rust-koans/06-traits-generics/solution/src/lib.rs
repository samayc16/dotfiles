//! Koan 06: traits and generics.

use std::fmt;
use std::ops::Add;

/// Anything that can introduce itself. `describe` has a default body built on `name`.
pub trait Describe {
    fn name(&self) -> String;

    fn describe(&self) -> String {
        format!("This is {}.", self.name())
    }
}

pub struct Dog;

pub struct Robot {
    pub id: u32,
}

impl Describe for Dog {
    /// "a dog"
    fn name(&self) -> String {
        "a dog".to_string()
    }
}

impl Describe for Robot {
    /// "robot #<id>"
    fn name(&self) -> String {
        format!("robot #{}", self.id)
    }

    fn describe(&self) -> String {
        format!("BEEP. I AM {}.", self.name().to_uppercase())
    }
}

/// The `describe()` of every item. Works for ANY type that implements Describe.
pub fn introduce_all<T: Describe>(items: &[T]) -> Vec<String> {
    let mut lines = Vec::new();
    for item in items {
        lines.push(item.describe());
    }
    lines
}

/// The largest element, or None for an empty slice.
pub fn largest<T: PartialOrd + Copy>(xs: &[T]) -> Option<T> {
    let mut best = *xs.first()?;
    for &x in xs {
        if x > best {
            best = x;
        }
    }
    Some(best)
}

/// Money in cents (never negative here).
#[derive(Debug, Clone, Copy, PartialEq, PartialOrd)]
pub struct Money {
    pub cents: i64,
}

impl Add for Money {
    type Output = Money;

    fn add(self, other: Money) -> Money {
        Money { cents: self.cents + other.cents }
    }
}

/// "$12.05"
impl fmt::Display for Money {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "${}.{:02}", self.cents / 100, self.cents % 100)
    }
}

/// `zero + xs[0] + xs[1] + …` for any type that can be added and copied.
pub fn sum_all<T: Add<Output = T> + Copy>(xs: &[T], zero: T) -> T {
    let mut total = zero;
    for &x in xs {
        total = total + x;
    }
    total
}
