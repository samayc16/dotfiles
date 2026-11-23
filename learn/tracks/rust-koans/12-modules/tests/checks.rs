//! The checks for this koan: each #[test] is one ✓/✗ line in `learn check`.
//! Read-only: `learn check` always runs the original, so editing this copy changes nothing.

use koan::Item;
use koan::inventory::Item as InventoryItem;
use koan::pricing::{discounts, with_tax};

#[test]
fn item_is_reexported_at_the_root() {
    let item = Item::new("bolt", 5);
    assert_eq!(item.name, "bolt");
    assert_eq!(item.count(), 5);
}

#[test]
fn both_paths_name_the_same_type() {
    let item: InventoryItem = Item::new("nut", 1);
    assert_eq!(item.count(), 1);
}

#[test]
fn take_only_what_is_there() {
    let mut item = Item::new("gear", 3);
    assert!(item.take(2), "take(2) with 3 in stock");
    assert!(!item.take(2), "take(2) with 1 left");
    assert_eq!(item.count(), 1, "count after the refused take");
}

#[test]
fn with_tax_adds_eight_percent() {
    assert_eq!(with_tax(1000), 1080, "with_tax(1000)");
    assert_eq!(with_tax(99), 106, "with_tax(99), rounded down");
}

#[test]
fn bulk_discount_starts_at_ten() {
    assert_eq!(discounts::bulk(1000, 9), 1000, "9 items");
    assert_eq!(discounts::bulk(1000, 10), 900, "10 items");
}

#[test]
fn checkout_combines_discount_and_tax() {
    assert_eq!(discounts::checkout(100, 2), 216, "2 × 100 + tax");
    assert_eq!(discounts::checkout(250, 12), 2916, "12 × 250, -10%, + tax");
}
