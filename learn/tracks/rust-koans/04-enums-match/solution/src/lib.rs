//! Koan 04: enums and match.

use std::f64::consts::PI;

/// A shape is exactly one of these, each variant carrying its own data.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum Shape {
    Circle { r: f64 },
    Rect { w: f64, h: f64 },
    /// The three side lengths.
    Triangle(f64, f64, f64),
}

impl Shape {
    /// The area. Triangle (Heron): s = (a + b + c) / 2, area = sqrt(s (s-a) (s-b) (s-c)).
    pub fn area(&self) -> f64 {
        match *self {
            Shape::Circle { r } => PI * r * r,
            Shape::Rect { w, h } => w * h,
            Shape::Triangle(a, b, c) => {
                let s = (a + b + c) / 2.0;
                (s * (s - a) * (s - b) * (s - c)).sqrt()
            }
        }
    }

    /// True for circles only.
    pub fn is_round(&self) -> bool {
        matches!(self, Shape::Circle { .. })
    }
}

/// "negative", "zero", "small" (1..=9) or "large" (10 and up).
pub fn size_word(n: i64) -> &'static str {
    match n {
        i64::MIN..=-1 => "negative",
        0 => "zero",
        1..=9 => "small",
        _ => "large",
    }
}

/// One instruction of a tiny stack machine.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum Op {
    /// Push a number.
    Push(i64),
    /// Pop b, pop a, push a + b.
    Add,
    /// Pop b, pop a, push a * b.
    Mul,
    /// Pop a, push -a.
    Neg,
    /// Push a copy of the top value.
    Dup,
}

/// Runs `program` on an empty stack and returns the top value at the end.
/// `None` if an op needs more values than the stack holds, or if nothing is left.
pub fn run(program: &[Op]) -> Option<i64> {
    let mut stack = Vec::new();
    for op in program {
        match op {
            Op::Push(n) => stack.push(*n),
            Op::Add => {
                let (b, a) = (stack.pop()?, stack.pop()?);
                stack.push(a + b);
            }
            Op::Mul => {
                let (b, a) = (stack.pop()?, stack.pop()?);
                stack.push(a * b);
            }
            Op::Neg => {
                let a = stack.pop()?;
                stack.push(-a);
            }
            Op::Dup => {
                let top = *stack.last()?;
                stack.push(top);
            }
        }
    }
    stack.last().copied()
}

/// "Hi, <name>!" for a name, "Hi, stranger!" for None.
pub fn greet(name: Option<&str>) -> String {
    match name {
        Some(name) => format!("Hi, {name}!"),
        None => "Hi, stranger!".to_string(),
    }
}
