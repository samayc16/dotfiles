//! The checks for this koan: each #[test] is one ✓/✗ line in `learn check`.
//! Read-only: `learn check` always runs the original, so editing this copy changes nothing.

use koan::*;

#[test]
fn dog_uses_the_default_describe() {
    assert_eq!(Dog.name(), "a dog");
    assert_eq!(Dog.describe(), "This is a dog.");
}

#[test]
fn robot_overrides_describe() {
    let robot = Robot { id: 7 };
    assert_eq!(robot.name(), "robot #7");
    assert_eq!(robot.describe(), "BEEP. I AM ROBOT #7.");
}

#[test]
fn introduce_all_is_generic() {
    assert_eq!(introduce_all(&[Dog, Dog]), ["This is a dog.", "This is a dog."], "two dogs");
    assert_eq!(introduce_all(&[Robot { id: 1 }]), ["BEEP. I AM ROBOT #1."], "one robot");
}

#[test]
fn largest_works_for_any_ordered_type() {
    assert_eq!(largest(&[3, 9, 2]), Some(9), "largest(&[3, 9, 2])");
    assert_eq!(largest(&[0.5, -1.0]), Some(0.5), "largest(&[0.5, -1.0])");
    assert_eq!(largest(&['q', 'z', 'a']), Some('z'), "largest(&['q', 'z', 'a'])");
    assert_eq!(largest::<u8>(&[]), None, "an empty slice");
}

#[test]
fn money_adds_and_prints() {
    let total = Money { cents: 1050 } + Money { cents: 155 };
    assert_eq!(total, Money { cents: 1205 }, "$10.50 + $1.55");
    assert_eq!(total.to_string(), "$12.05");
    assert_eq!(Money { cents: 7 }.to_string(), "$0.07");
}

#[test]
fn sum_all_works_for_anything_addable() {
    assert_eq!(sum_all(&[1, 2, 3], 0), 6, "integers");
    assert_eq!(sum_all(&[0.5, 0.25], 0.0), 0.75, "floats");
    let cents = sum_all(&[Money { cents: 99 }, Money { cents: 1 }], Money { cents: 0 });
    assert_eq!(cents, Money { cents: 100 }, "your Money, through your Add impl");
}

#[test]
fn largest_works_on_money_too() {
    let prices = [Money { cents: 5 }, Money { cents: 120 }, Money { cents: 30 }];
    assert_eq!(largest(&prices), Some(Money { cents: 120 }));
}
