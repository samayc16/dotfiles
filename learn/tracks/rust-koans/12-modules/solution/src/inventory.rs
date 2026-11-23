//! The shop's stock. This file is the module `crate::inventory`, but only once
//! src/lib.rs declares it.

/// A line of stock. `name` should be public; `count` stays private, so it can only
/// change through the methods (it can never go negative, for one).
#[derive(Debug)]
pub struct Item {
    pub name: String,
    count: u32,
}

impl Item {
    pub fn new(name: &str, count: u32) -> Item {
        Item { name: name.to_string(), count }
    }

    pub fn count(&self) -> u32 {
        self.count
    }

    /// Takes `n` items out of stock if there are enough. Returns whether it did.
    pub fn take(&mut self, n: u32) -> bool {
        if n > self.count {
            return false;
        }
        self.count -= n;
        true
    }
}
