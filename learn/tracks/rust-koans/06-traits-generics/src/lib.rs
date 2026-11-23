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
        todo!()
    }
}

impl Describe for Robot {
    /// "robot #<id>"
    fn name(&self) -> String {
        todo!()
    }
    // TODO: override describe() here: "BEEP. I AM ROBOT #<id>."
}

/// The `describe()` of every item. Works for ANY type that implements Describe.
pub fn introduce_all<T: Describe>(items: &[T]) -> Vec<String> {
    todo!()
}

/// The largest element, or None for an empty slice.
pub fn largest<T>(xs: &[T]) -> Option<T> {
    todo!()
}

/// Money in cents (never negative here).
#[derive(Debug, Clone, Copy, PartialEq, PartialOrd)]
pub struct Money {
    pub cents: i64,
}

impl Add for Money {
    type Output = Money;

    fn add(self, other: Money) -> Money {
        todo!()
    }
}

/// "$12.05"
impl fmt::Display for Money {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        todo!()
    }
}

/// `zero + xs[0] + xs[1] + …` for any type that can be added and copied.
pub fn sum_all<T>(xs: &[T], zero: T) -> T {
    todo!()
}
