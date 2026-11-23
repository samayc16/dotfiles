//! The checks for this koan: each #[test] is one ✓/✗ line in `learn check`.
//! Read-only: `learn check` always runs the original, so editing this copy changes nothing.

use koan::*;

fn replace(from: &str, to: &str) -> Replace {
    Replace { from: from.to_string(), to: to.to_string() }
}

#[test]
fn upper_uppercases() {
    assert_eq!(Upper.apply("hi there"), "HI THERE");
}

#[test]
fn repeat_repeats() {
    assert_eq!(Repeat(3).apply("ab"), "ababab");
    assert_eq!(Repeat(0).apply("ab"), "", "zero times");
}

#[test]
fn replace_replaces_every_match() {
    assert_eq!(replace("cat", "dog").apply("cat, catalog"), "dog, dogalog");
}

#[test]
fn pipeline_runs_steps_in_order() {
    let pipeline = Pipeline::new()
        .then(Box::new(replace("o", "0")))
        .then(Box::new(Upper))
        .then(Box::new(Repeat(2)));
    assert_eq!(pipeline.step_count(), 3, "step_count()");
    assert_eq!(pipeline.run("foo "), "F00 F00 ");
}

#[test]
fn an_empty_pipeline_changes_nothing() {
    assert_eq!(Pipeline::new().run("same"), "same");
}

#[test]
fn parse_step_builds_the_right_kind() {
    let upper = parse_step("upper").expect("\"upper\" should parse");
    assert_eq!(upper.apply("x"), "X");
    let repeat = parse_step("repeat 3").expect("\"repeat 3\" should parse");
    assert_eq!(repeat.apply("ab"), "ababab");
    let swap = parse_step("replace a e").expect("\"replace a e\" should parse");
    assert_eq!(swap.apply("cat"), "cet");
}

#[test]
fn parse_step_rejects_nonsense() {
    assert!(parse_step("shout").is_none(), "an unknown step");
    assert!(parse_step("repeat x").is_none(), "repeat needs a number");
    assert!(parse_step("replace a").is_none(), "replace needs two words");
}

#[test]
fn total_len_takes_borrowed_trait_objects() {
    let steps: [&dyn Transform; 2] = [&Upper, &Repeat(3)];
    assert_eq!(total_len(&steps, "abc"), 12, "3 (upper) + 9 (repeat 3)");
}
