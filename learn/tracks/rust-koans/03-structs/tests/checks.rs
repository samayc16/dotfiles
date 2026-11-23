//! The checks for this koan: each #[test] is one ✓/✗ line in `learn check`.
//! Read-only: `learn check` always runs the original, so editing this copy changes nothing.

use koan::*;

#[test]
fn constructors_build_rects() {
    assert_eq!(Rect::new(3, 4), Rect { w: 3, h: 4 }, "Rect::new(3, 4)");
    assert_eq!(Rect::square(5), Rect { w: 5, h: 5 }, "Rect::square(5)");
}

#[test]
fn area_reads_through_self() {
    assert_eq!(Rect { w: 3, h: 4 }.area(), 12);
}

#[test]
fn can_hold_compares_both_sides() {
    let big = Rect { w: 10, h: 5 };
    assert!(big.can_hold(&Rect { w: 10, h: 5 }), "a rect holds an equal one");
    assert!(big.can_hold(&Rect { w: 2, h: 3 }), "10x5 holds 2x3");
    assert!(!big.can_hold(&Rect { w: 3, h: 6 }), "10x5 can't hold 3x6");
}

#[test]
fn scale_mutates_in_place() {
    let mut r = Rect { w: 2, h: 3 };
    r.scale(4);
    assert_eq!(r, Rect { w: 8, h: 12 });
}

#[test]
fn thermostat_clamps_on_creation() {
    assert_eq!(Thermostat::new(22).target(), 22, "Thermostat::new(22)");
    assert_eq!(Thermostat::new(99).target(), 30, "Thermostat::new(99)");
    assert_eq!(Thermostat::new(-5).target(), 10, "Thermostat::new(-5)");
}

#[test]
fn adjust_clamps_and_counts() {
    let mut t = Thermostat::new(28);
    t.adjust(5);
    t.adjust(-3);
    assert_eq!(t.target(), 27, "28, then +5 (clamped to 30), then -3");
    assert_eq!(t.changes(), 2, "changes()");
}

#[test]
fn report_consumes_the_thermostat() {
    let mut one = Thermostat::new(20);
    one.adjust(2);
    assert_eq!(one.report(), "22°C after 1 change");
    let mut three = Thermostat::new(20);
    for _ in 0..3 {
        three.adjust(5);
    }
    assert_eq!(three.report(), "30°C after 3 changes");
}
