//! The shop's stock. This file is the module `crate::inventory`, but only once
//! src/lib.rs declares it.

/// A line of stock. `name` should be public; `count` stays private, so it can only
/// change through the methods (it can never go negative, for one).
#[derive(Debug)]
pub struct Item {
    name: String,
    count: u32,
}

impl Item {
    fn new(name: &str, count: u32) -> Item {
        todo!()
    }

    pub fn count(&self) -> u32 {
        todo!()
    }

    /// Takes `n` items out of stock if there are enough. Returns whether it did.
    pub fn take(&mut self, n: u32) -> bool {
        todo!()
    }
}
