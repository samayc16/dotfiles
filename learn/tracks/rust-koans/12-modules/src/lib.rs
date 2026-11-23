//! Koan 12: a tiny shop, split into modules. The checks use this crate from the
//! outside, as `koan::…`, so they only see what's `pub` and reachable from here.

// TODO: src/inventory.rs isn't part of the crate yet

/// Pricing rules, in an inline module.
mod pricing {
    /// Sales tax in percent: visible to the whole crate, but not outside it.
    pub(crate) const TAX_PERCENT: u64 = 8;

    /// The price in cents with tax added, rounded down.
    fn with_tax(cents: u64) -> u64 {
        todo!()
    }

    pub mod discounts {
        /// 10% off an order of 10 or more items.
        fn bulk(cents: u64, quantity: u32) -> u64 {
            todo!()
        }

        /// The bulk discount first, then tax: reuse the parent module's `with_tax`.
        pub fn checkout(unit_cents: u64, quantity: u32) -> u64 {
            todo!()
        }
    }
}

// TODO: re-export Item, so callers can write `koan::Item`
