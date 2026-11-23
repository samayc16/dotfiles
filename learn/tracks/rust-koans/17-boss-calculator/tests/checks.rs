//! The checks for this koan: each #[test] is one ✓/✗ line in `learn check`.
//! Read-only: `learn check` always runs the original, so editing this copy changes nothing.

use koan::*;
use std::collections::HashMap;

fn num(n: f64) -> Box<Expr> {
    Box::new(Expr::Num(n))
}

fn var(name: &str) -> Box<Expr> {
    Box::new(Expr::Var(name.to_string()))
}

fn shown(src: &str) -> Result<String, CalcError> {
    parse(src).map(|e| e.to_string())
}

#[test]
fn tokenize_numbers_names_and_operators() {
    use Token::*;
    let expected = vec![Ident("x1"), Assign, Num(2.5), Op('*'), LParen, Ident("y"), Op('+'), Num(10.0), RParen];
    assert_eq!(tokenize("x1 = 2.5*(y+10)"), Ok(expected));
    assert_eq!(tokenize("  "), Ok(vec![]), "only whitespace");
}

#[test]
fn tokenize_rejects_bad_input() {
    assert_eq!(tokenize("2 $ 3"), Err(CalcError::BadChar('$')));
    assert_eq!(tokenize("1.2.3"), Err(CalcError::BadNumber("1.2.3".to_string())));
}

#[test]
fn identifiers_borrow_from_the_source() {
    let src = String::from("total");
    let tokens = tokenize(&src).expect("\"total\" should tokenize");
    let Some(Token::Ident(name)) = tokens.first().copied() else {
        panic!("expected [Ident(\"total\")], got {tokens:?}");
    };
    assert_eq!(name.as_ptr(), src.as_ptr(), "the name points into the source: no copy");
}

#[test]
fn display_is_fully_parenthesised() {
    let tree = Expr::Bin(num(2.0), '*', Box::new(Expr::Neg(var("x"))));
    assert_eq!(tree.to_string(), "(2 * -x)");
    assert_eq!(Expr::Num(1.5).to_string(), "1.5");
}

#[test]
fn eval_walks_the_tree() {
    let tree = Expr::Bin(num(2.0), '*', Box::new(Expr::Neg(var("x"))));
    let vars = HashMap::from([("x".to_string(), 4.0)]);
    assert_eq!(tree.eval(&vars), Ok(-8.0), "2 * -x with x = 4");
}

#[test]
fn eval_reports_unknown_variables_and_division_by_zero() {
    let vars = HashMap::new();
    assert_eq!(Expr::Var("ghost".into()).eval(&vars), Err(CalcError::UnknownVar("ghost".into())));
    assert_eq!(Expr::Bin(num(1.0), '/', num(0.0)).eval(&vars), Err(CalcError::DivByZero));
}

#[test]
fn parse_respects_precedence() {
    assert_eq!(shown("1 + 2 * 3"), Ok("(1 + (2 * 3))".to_string()));
    assert_eq!(shown("(1 + 2) * 3"), Ok("((1 + 2) * 3)".to_string()));
}

#[test]
fn parse_is_left_associative() {
    assert_eq!(shown("8 - 3 - 2"), Ok("((8 - 3) - 2)".to_string()));
    assert_eq!(shown("8 / 4 / 2"), Ok("((8 / 4) / 2)".to_string()));
}

#[test]
fn parse_handles_negation() {
    assert_eq!(shown("-(1 + x) * 2"), Ok("(-(1 + x) * 2)".to_string()));
    assert_eq!(shown("2 - -1"), Ok("(2 - -1)".to_string()));
}

#[test]
fn parse_reports_errors() {
    assert_eq!(parse("1 +"), Err(CalcError::UnexpectedEnd), "1 +");
    assert_eq!(parse("(1 + 2"), Err(CalcError::UnexpectedEnd), "(1 + 2");
    assert_eq!(parse("1 2"), Err(CalcError::Unexpected("Num(2.0)".into())), "1 2");
    assert_eq!(parse(")"), Err(CalcError::Unexpected("RParen".into())), ")");
}

#[test]
fn calculator_remembers_assignments() {
    let mut calc = Calculator::new();
    assert_eq!(calc.run("x = 1 + 2"), Ok(3.0));
    assert_eq!(calc.run("y = x * x"), Ok(9.0));
    assert_eq!(calc.run("y - x / 3"), Ok(8.0));
    assert_eq!(calc.get("y"), Some(9.0), "get(\"y\")");
}

#[test]
fn a_failing_line_changes_nothing() {
    let mut calc = Calculator::new();
    assert_eq!(calc.run("a = 5"), Ok(5.0));
    assert_eq!(calc.run("a = 1 / 0"), Err(CalcError::DivByZero));
    assert_eq!(calc.get("a"), Some(5.0), "a after the failed assignment");
    assert_eq!(calc.run("b + 1"), Err(CalcError::UnknownVar("b".into())));
}
