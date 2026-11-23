//! The checks for this koan: each #[test] is one ✓/✗ line in `learn check`.
//! Read-only: `learn check` always runs the original, so editing this copy changes nothing.

use koan::*;

#[test]
fn errors_display_for_humans() {
    assert_eq!(ConfigError::Malformed(3).to_string(), "line 3: expected key=value");
    assert_eq!(ConfigError::Missing("port".into()).to_string(), "missing key: port");
    let parse_error = "http".parse::<u16>().unwrap_err();
    assert_eq!(ConfigError::BadNumber(parse_error).to_string(), "bad number: invalid digit found in string");
}

#[test]
fn parse_line_splits_and_trims() {
    assert_eq!(parse_line(" host = example.org ", 1), Ok(("host", "example.org")));
}

#[test]
fn parse_line_reports_the_line_number() {
    assert_eq!(parse_line("oops", 7), Err(ConfigError::Malformed(7)));
}

#[test]
fn get_port_finds_and_parses_it() {
    assert_eq!(get_port("host=a\n\nport = 8080\n"), Ok(8080));
}

#[test]
fn get_port_propagates_every_kind_of_error() {
    assert_eq!(get_port("host=a"), Err(ConfigError::Missing("port".into())), "no port line");
    assert_eq!(get_port("host=a\njunk\nport=1"), Err(ConfigError::Malformed(2)), "line 2 has no '='");
    let too_big = get_port("port=99999");
    assert!(matches!(too_big, Err(ConfigError::BadNumber(_))), "port=99999 doesn't fit a u16: expected Err(BadNumber(..)), got {too_big:?}");
}

#[test]
fn sum_list_adds_or_fails() {
    assert_eq!(sum_list("1, 2, 39").ok(), Some(42), "sum_list(\"1, 2, 39\")");
    let err = sum_list("1, two").map_err(|e| e.to_string());
    assert_eq!(err, Err("invalid digit found in string".to_string()), "sum_list(\"1, two\")");
}

#[test]
fn a_config_error_fits_in_a_box_dyn_error() {
    let boxed: Box<dyn std::error::Error> = Box::new(ConfigError::Missing("x".into()));
    assert_eq!(boxed.to_string(), "missing key: x");
}
