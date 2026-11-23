//! Koan 12: a tiny shop, split into modules. The checks use this crate from the
//! outside, as `koan::…`, so they only see what's `pub` and reachable from here.

pub mod inventory;

/// Pricing rules, in an inline module.
pub mod pricing {
    /// Sales tax in percent: visible to the whole crate, but not outside it.
    pub(crate) const TAX_PERCENT: u64 = 8;

    /// The price in cents with tax added, rounded down.
    pub fn with_tax(cents: u64) -> u64 {
        cents * (100 + TAX_PERCENT) / 100
    }

    pub mod discounts {
        /// 10% off an order of 10 or more items.
        pub fn bulk(cents: u64, quantity: u32) -> u64 {
            if quantity >= 10 { cents * 90 / 100 } else { cents }
        }

        /// The bulk discount first, then tax: reuse the parent module's `with_tax`.
        pub fn checkout(unit_cents: u64, quantity: u32) -> u64 {
            super::with_tax(bulk(unit_cents * quantity as u64, quantity))
        }
    }
}

pub use inventory::Item;
