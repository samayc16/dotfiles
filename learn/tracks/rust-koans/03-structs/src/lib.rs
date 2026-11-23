//! Koan 03: structs and impl blocks.

/// A rectangle measured in whole pixels.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Rect {
    pub w: u32,
    pub h: u32,
}

impl Rect {
    /// A constructor is just an associated function (no `self`): `Rect::new(3, 4)`.
    pub fn new(w: u32, h: u32) -> Self {
        todo!()
    }

    /// A square with the given side.
    pub fn square(side: u32) -> Self {
        todo!()
    }

    pub fn area(&self) -> u32 {
        todo!()
    }

    /// True if `other` fits inside `self` without rotating it.
    pub fn can_hold(&self, other: &Rect) -> bool {
        todo!()
    }

    /// Multiplies both sides by `k`, in place.
    pub fn scale(&mut self, k: u32) {
        todo!()
    }
}

/// A thermostat whose target always stays within MIN..=MAX °C. The fields are PRIVATE:
/// code outside this module can only use the methods, so nobody can break that rule.
#[derive(Debug)]
pub struct Thermostat {
    target: i32,
    changes: u32,
}

impl Thermostat {
    pub const MIN: i32 = 10;
    pub const MAX: i32 = 30;

    /// Starts at `target`, clamped into MIN..=MAX, with no changes yet.
    pub fn new(target: i32) -> Self {
        todo!()
    }

    pub fn target(&self) -> i32 {
        todo!()
    }

    pub fn changes(&self) -> u32 {
        todo!()
    }

    /// Moves the target by `delta` (clamped) and counts the change, even if clamping
    /// made it a no-op.
    pub fn adjust(&mut self, delta: i32) {
        todo!()
    }

    /// Consumes the thermostat: "22°C after 1 change", "25°C after 3 changes".
    pub fn report(self) -> String {
        todo!()
    }
}
