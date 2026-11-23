//! Koan 13: pattern matching power tools.

/// "x,y" → Ok((x, y)), with spaces allowed around the numbers.
/// Errors: "no comma in \"3;4\"" or "not two numbers: \"3,x\"" (the input in Debug quotes).
pub fn parse_point(s: &str) -> Result<(i32, i32), String> {
    todo!()
}

/// "empty", "one: 7", "two: 1 and 2", or "many: 1 … 9" (the first and the last).
pub fn shape(xs: &[i32]) -> String {
    todo!()
}

#[derive(Debug, Clone)]
pub struct User {
    pub name: String,
    pub email: Option<String>,
    pub admin: bool,
}

/// The email of an admin whose address ends in "@corp.example"; None otherwise.
pub fn admin_contact(user: &User) -> Option<&str> {
    todo!()
}

#[derive(Debug, Clone, Copy, PartialEq)]
pub enum Event {
    Key { code: char, shift: bool },
    Click { x: i32, y: i32 },
    /// Positive scrolls up, negative scrolls down.
    Scroll(i32),
}

/// "A" (shift+a) or "a"; "click in corner" at (0, 0), else "click at x,y";
/// "scroll up 3", "scroll down 2", or "still" for 0.
pub fn describe(event: &Event) -> String {
    todo!()
}
