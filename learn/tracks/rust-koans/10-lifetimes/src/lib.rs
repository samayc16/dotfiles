//! Koan 10: lifetimes. This koan starts with compile errors ON PURPOSE.

/// The longer of two strings (the first one on a tie).
pub fn longest(a: &str, b: &str) -> &str {
    todo!()
}

/// The part of `text` before the first `sep` (all of `text` if there is none).
/// The result borrows from `text` only: callers may drop `sep` right away.
pub fn before(text: &str, sep: &str) -> &str {
    todo!()
}

/// A piece of some text and the byte index where it starts.
/// A struct that holds a reference needs a lifetime parameter.
#[derive(Debug, PartialEq)]
pub struct Highlight {
    pub text: &str,
    pub start: usize,
}

/// Every occurrence of `word` in `text`, as highlights that borrow from `text`.
pub fn find_all(text: &str, word: &str) -> Vec<Highlight> {
    todo!()
}

/// Hands out the words of the text it borrows, one at a time.
pub struct Words {
    rest: &str,
}

impl Words {
    pub fn new(input: &str) -> Self {
        Words { rest: input }
    }

    /// The next whitespace-separated word, or None at the end. The word borrows from
    /// the INPUT, not from the parser, so it may outlive the parser.
    pub fn next_word(&mut self) -> Option<&str> {
        todo!()
    }
}

/// String literals are `&'static str`: they live as long as the program.
/// 0 "debug", 1 "info", 2 "warn", anything else "error".
pub fn level_name(level: u8) -> &'static str {
    todo!()
}
