//! Koan 05: errors are values. A function that can fail returns Result<T, E>, and `?`
//! returns early with the error, converting it through `From`.

use std::error::Error;
use std::fmt;
use std::num::ParseIntError;

/// Everything that can go wrong reading a "key=value" config.
#[derive(Debug, PartialEq)]
pub enum ConfigError {
    /// A line without '=' (holds the 1-based line number).
    Malformed(usize),
    /// A required key isn't there.
    Missing(String),
    /// A value that should be a number isn't.
    BadNumber(ParseIntError),
}

impl fmt::Display for ConfigError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            ConfigError::Malformed(line) => write!(f, "line {line}: expected key=value"),
            ConfigError::Missing(key) => write!(f, "missing key: {key}"),
            ConfigError::BadNumber(err) => write!(f, "bad number: {err}"),
        }
    }
}

/// With Debug + Display in place, this makes ConfigError a real std error
/// (so it fits in a Box<dyn Error>, like any other).
impl Error for ConfigError {}

impl From<ParseIntError> for ConfigError {
    fn from(err: ParseIntError) -> Self {
        ConfigError::BadNumber(err)
    }
}

/// Splits one "key=value" line, trimming spaces around both parts.
/// `line_no` is only used in the error.
pub fn parse_line(line: &str, line_no: usize) -> Result<(&str, &str), ConfigError> {
    let (key, value) = line.split_once('=').ok_or(ConfigError::Malformed(line_no))?;
    Ok((key.trim(), value.trim()))
}

/// Finds `port=<number>` in a multi-line config and parses it as a u16.
/// Blank lines are skipped; every other line must be key=value.
pub fn get_port(config: &str) -> Result<u16, ConfigError> {
    for (i, line) in config.lines().enumerate() {
        if line.trim().is_empty() {
            continue;
        }
        let (key, value) = parse_line(line, i + 1)?;
        if key == "port" {
            return Ok(value.parse()?);
        }
    }
    Err(ConfigError::Missing("port".to_string()))
}

/// Adds up comma-separated numbers: "1, 2, 39" → 42. Any std error converts into
/// Box<dyn Error>, so `?` works on a ParseIntError here with no From impl of your own.
pub fn sum_list(text: &str) -> Result<i64, Box<dyn Error>> {
    let mut total = 0;
    for part in text.split(',') {
        total += part.trim().parse::<i64>()?;
    }
    Ok(total)
}
