//! BOSS: a calculator with variables, in four stages:
//!   tokenize   "x = 2 * (y + 1.5)"  →  [Ident("x"), Assign, Num(2.0), Op('*'), LParen, …]
//!   parse      tokens               →  an Expr tree
//!   eval       Expr + variables     →  f64, or a CalcError
//!   run        a line, including `name = expr` assignments
//!
//! Grammar, loosest first:
//!   expr  := term (('+' | '-') term)*
//!   term  := unary (('*' | '/') unary)*
//!   unary := '-' unary | atom
//!   atom  := number | identifier | '(' expr ')'

use std::collections::HashMap;
use std::fmt;
use std::iter::Peekable;
use std::str::CharIndices;

/// A token borrows identifier names from the source text: tokenizing allocates nothing.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum Token<'a> {
    Num(f64),
    Ident(&'a str),
    /// One of + - * /
    Op(char),
    LParen,
    RParen,
    /// =
    Assign,
}

#[derive(Debug, Clone, PartialEq)]
pub enum Expr {
    Num(f64),
    Var(String),
    Neg(Box<Expr>),
    Bin(Box<Expr>, char, Box<Expr>),
}

#[derive(Debug, Clone, PartialEq)]
pub enum CalcError {
    BadChar(char),
    BadNumber(String),
    UnexpectedEnd,
    /// A token where it doesn't belong, as its Debug text (e.g. "RParen").
    Unexpected(String),
    UnknownVar(String),
    DivByZero,
}

impl fmt::Display for CalcError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            CalcError::BadChar(c) => write!(f, "unexpected character {c:?}"),
            CalcError::BadNumber(text) => write!(f, "{text:?} is not a number"),
            CalcError::UnexpectedEnd => write!(f, "the expression ends too early"),
            CalcError::Unexpected(token) => write!(f, "unexpected {token}"),
            CalcError::UnknownVar(name) => write!(f, "unknown variable {name}"),
            CalcError::DivByZero => write!(f, "division by zero"),
        }
    }
}

impl std::error::Error for CalcError {}

/// Consumes chars while `keep(c)` holds; returns the byte index where it stopped.
fn scan(chars: &mut Peekable<CharIndices<'_>>, src_len: usize, keep: impl Fn(char) -> bool) -> usize {
    while let Some(&(i, c)) = chars.peek() {
        if !keep(c) {
            return i;
        }
        chars.next();
    }
    src_len
}

/// Splits `src` into tokens (see the README for the rules).
pub fn tokenize(src: &str) -> Result<Vec<Token<'_>>, CalcError> {
    todo!()
}

/// Recursive descent over a token slice: one method per grammar rule.
pub struct Parser<'a> {
    tokens: &'a [Token<'a>],
    pos: usize,
}

impl<'a> Parser<'a> {
    pub fn new(tokens: &'a [Token<'a>]) -> Self {
        Parser { tokens, pos: 0 }
    }

    fn peek(&self) -> Option<Token<'a>> {
        self.tokens.get(self.pos).copied()
    }

    fn next(&mut self) -> Option<Token<'a>> {
        let token = self.peek();
        self.pos += 1;
        token
    }

    /// The whole token list as one expression; leftover tokens are an error.
    pub fn parse_all(mut self) -> Result<Expr, CalcError> {
        let expr = self.expr()?;
        match self.peek() {
            None => Ok(expr),
            Some(token) => Err(CalcError::Unexpected(format!("{token:?}"))),
        }
    }

    /// expr := term (('+' | '-') term)*
    fn expr(&mut self) -> Result<Expr, CalcError> {
        todo!()
    }

    /// term := unary (('*' | '/') unary)*
    fn term(&mut self) -> Result<Expr, CalcError> {
        todo!()
    }

    /// unary := '-' unary | atom
    fn unary(&mut self) -> Result<Expr, CalcError> {
        todo!()
    }

    /// atom := number | identifier | '(' expr ')'
    fn atom(&mut self) -> Result<Expr, CalcError> {
        todo!()
    }
}

/// tokenize + parse.
pub fn parse(src: &str) -> Result<Expr, CalcError> {
    let tokens = tokenize(src)?;
    Parser::new(&tokens).parse_all()
}

impl Expr {
    pub fn eval(&self, vars: &HashMap<String, f64>) -> Result<f64, CalcError> {
        todo!()
    }
}

/// Fully parenthesised: Bin → "(left op right)", Neg → "-inner", numbers as f64 prints them.
impl fmt::Display for Expr {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        todo!()
    }
}

/// Keeps variables between lines: run("x = 1 + 2") stores and returns 3.0.
#[derive(Debug, Default)]
pub struct Calculator {
    vars: HashMap<String, f64>,
}

impl Calculator {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn get(&self, name: &str) -> Option<f64> {
        self.vars.get(name).copied()
    }

    /// Evaluates one line. `name = expr` also stores the value; a failing line changes nothing.
    pub fn run(&mut self, line: &str) -> Result<f64, CalcError> {
        todo!()
    }
}
