//! The checks for this koan: each #[test] is one ✓/✗ line in `learn check`.
//! Read-only: `learn check` always runs the original, so editing this copy changes nothing.

use koan::*;

fn close(got: f64, want: f64) -> bool {
    (got - want).abs() < 1e-9
}

#[test]
fn circle_and_rect_areas() {
    let circle = Shape::Circle { r: 2.0 }.area();
    assert!(close(circle, 12.566370614359172), "Circle {{ r: 2.0 }}.area(): expected ≈12.566, got {circle}");
    let rect = Shape::Rect { w: 3.0, h: 1.5 }.area();
    assert!(close(rect, 4.5), "Rect {{ w: 3.0, h: 1.5 }}.area(): expected 4.5, got {rect}");
}

#[test]
fn triangle_area_by_heron() {
    let tri = Shape::Triangle(3.0, 4.0, 5.0).area();
    assert!(close(tri, 6.0), "Triangle(3.0, 4.0, 5.0).area(): expected 6, got {tri}");
}

#[test]
fn only_circles_are_round() {
    assert!(Shape::Circle { r: 1.0 }.is_round(), "a circle");
    assert!(!Shape::Rect { w: 1.0, h: 1.0 }.is_round(), "a rect");
    assert!(!Shape::Triangle(1.0, 1.0, 1.0).is_round(), "a triangle");
}

#[test]
fn size_word_matches_ranges() {
    assert_eq!(size_word(-40), "negative", "size_word(-40)");
    assert_eq!(size_word(0), "zero", "size_word(0)");
    assert_eq!(size_word(1), "small", "size_word(1)");
    assert_eq!(size_word(9), "small", "size_word(9)");
    assert_eq!(size_word(10), "large", "size_word(10)");
}

#[test]
fn run_evaluates_a_program() {
    use Op::*;
    assert_eq!(run(&[Push(2), Push(3), Add, Dup, Mul]), Some(25), "(2 + 3) squared");
    assert_eq!(run(&[Push(4), Neg, Push(10), Add]), Some(6), "-4 + 10");
}

#[test]
fn run_detects_underflow() {
    use Op::*;
    assert_eq!(run(&[Push(1), Add]), None, "Add with one value on the stack");
    assert_eq!(run(&[Dup]), None, "Dup on an empty stack");
    assert_eq!(run(&[]), None, "nothing left at the end");
}

#[test]
fn greet_handles_both_cases() {
    assert_eq!(greet(Some("Ada")), "Hi, Ada!");
    assert_eq!(greet(None), "Hi, stranger!");
}
