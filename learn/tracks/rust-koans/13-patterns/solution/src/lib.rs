//! Koan 13: pattern matching power tools.

/// "x,y" → Ok((x, y)), with spaces allowed around the numbers.
/// Errors: "no comma in \"3;4\"" or "not two numbers: \"3,x\"" (the input in Debug quotes).
pub fn parse_point(s: &str) -> Result<(i32, i32), String> {
    let Some((x, y)) = s.split_once(',') else {
        return Err(format!("no comma in {s:?}"));
    };
    let (Ok(x), Ok(y)) = (x.trim().parse(), y.trim().parse()) else {
        return Err(format!("not two numbers: {s:?}"));
    };
    Ok((x, y))
}

/// "empty", "one: 7", "two: 1 and 2", or "many: 1 … 9" (the first and the last).
pub fn shape(xs: &[i32]) -> String {
    match xs {
        [] => "empty".to_string(),
        [x] => format!("one: {x}"),
        [a, b] => format!("two: {a} and {b}"),
        [first, .., last] => format!("many: {first} … {last}"),
    }
}

#[derive(Debug, Clone)]
pub struct User {
    pub name: String,
    pub email: Option<String>,
    pub admin: bool,
}

/// The email of an admin whose address ends in "@corp.example"; None otherwise.
pub fn admin_contact(user: &User) -> Option<&str> {
    if user.admin
        && let Some(email) = &user.email
        && email.ends_with("@corp.example")
    {
        Some(email)
    } else {
        None
    }
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
    match *event {
        Event::Key { code, shift: true } => code.to_ascii_uppercase().to_string(),
        Event::Key { code, .. } => code.to_string(),
        Event::Click { x: 0, y: 0 } => "click in corner".to_string(),
        Event::Click { x, y } => format!("click at {x},{y}"),
        Event::Scroll(n @ 1..) => format!("scroll up {n}"),
        Event::Scroll(0) => "still".to_string(),
        Event::Scroll(n) => format!("scroll down {}", -n),
    }
}
