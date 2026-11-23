//! The checks for this koan: each #[test] is one ✓/✗ line in `learn check`.
//! Read-only: `learn check` always runs the original, so editing this copy changes nothing.

use koan::*;

fn user(email: Option<&str>, admin: bool) -> User {
    User { name: "x".to_string(), email: email.map(str::to_string), admin }
}

#[test]
fn parse_point_happy_path() {
    assert_eq!(parse_point("3,4"), Ok((3, 4)));
    assert_eq!(parse_point(" -1 , 20 "), Ok((-1, 20)));
}

#[test]
fn parse_point_bails_out_with_a_reason() {
    assert_eq!(parse_point("3;4"), Err("no comma in \"3;4\"".to_string()));
    assert_eq!(parse_point("3,x"), Err("not two numbers: \"3,x\"".to_string()));
    assert_eq!(parse_point(""), Err("no comma in \"\"".to_string()));
}

#[test]
fn shape_matches_slice_patterns() {
    assert_eq!(shape(&[]), "empty");
    assert_eq!(shape(&[7]), "one: 7");
    assert_eq!(shape(&[1, 2]), "two: 1 and 2");
    assert_eq!(shape(&[1, 5, 5, 9]), "many: 1 … 9");
}

#[test]
fn admin_contact_needs_every_condition() {
    assert_eq!(admin_contact(&user(Some("ada@corp.example"), true)), Some("ada@corp.example"), "an admin with a corp address");
    assert_eq!(admin_contact(&user(Some("bob@corp.example"), false)), None, "not an admin");
    assert_eq!(admin_contact(&user(None, true)), None, "no email");
    assert_eq!(admin_contact(&user(Some("eve@home.example"), true)), None, "not a corp address");
}

#[test]
fn describe_keys() {
    assert_eq!(describe(&Event::Key { code: 'a', shift: true }), "A");
    assert_eq!(describe(&Event::Key { code: 'a', shift: false }), "a");
}

#[test]
fn describe_clicks() {
    assert_eq!(describe(&Event::Click { x: 0, y: 0 }), "click in corner");
    assert_eq!(describe(&Event::Click { x: 3, y: 4 }), "click at 3,4");
    assert_eq!(describe(&Event::Click { x: 0, y: 5 }), "click at 0,5");
}

#[test]
fn describe_scrolls() {
    assert_eq!(describe(&Event::Scroll(3)), "scroll up 3");
    assert_eq!(describe(&Event::Scroll(-2)), "scroll down 2");
    assert_eq!(describe(&Event::Scroll(0)), "still");
}
