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
        Self { w, h }
    }

    /// A square with the given side.
    pub fn square(side: u32) -> Self {
        Self::new(side, side)
    }

    pub fn area(&self) -> u32 {
        self.w * self.h
    }

    /// True if `other` fits inside `self` without rotating it.
    pub fn can_hold(&self, other: &Rect) -> bool {
        other.w <= self.w && other.h <= self.h
    }

    /// Multiplies both sides by `k`, in place.
    pub fn scale(&mut self, k: u32) {
        self.w *= k;
        self.h *= k;
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
        Self { target: target.clamp(Self::MIN, Self::MAX), changes: 0 }
    }

    pub fn target(&self) -> i32 {
        self.target
    }

    pub fn changes(&self) -> u32 {
        self.changes
    }

    /// Moves the target by `delta` (clamped) and counts the change, even if clamping
    /// made it a no-op.
    pub fn adjust(&mut self, delta: i32) {
        self.target = (self.target + delta).clamp(Self::MIN, Self::MAX);
        self.changes += 1;
    }

    /// Consumes the thermostat: "22°C after 1 change", "25°C after 3 changes".
    pub fn report(self) -> String {
        let noun = if self.changes == 1 { "change" } else { "changes" };
        format!("{}°C after {} {}", self.target, self.changes, noun)
    }
}
