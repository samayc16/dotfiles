//! Koan 01: ownership. Every value has exactly one owner. Assigning or passing a
//! non-Copy value MOVES it: the old name can't be used any more.

/// A concert ticket. Deliberately neither `Clone` nor `Copy`: each one exists exactly once.
#[derive(Debug, PartialEq)]
pub struct Ticket {
    pub seat: u32,
}

/// Takes ownership of `wallet` and `ticket`, puts the ticket in, and hands the wallet back.
pub fn stash(mut wallet: Vec<Ticket>, ticket: Ticket) -> Vec<Ticket> {
    wallet.push(ticket);
    wallet
}

/// Moves the last ticket out of the wallet. Returns the rest of the wallet and the ticket.
pub fn take_last(mut wallet: Vec<Ticket>) -> (Vec<Ticket>, Option<Ticket>) {
    let last = wallet.pop();
    (wallet, last)
}

/// Consumes `tickets`: seats below 100 go to the front row (first Vec), the rest to the
/// back (second Vec), each keeping their order.
pub fn split_rows(tickets: Vec<Ticket>) -> (Vec<Ticket>, Vec<Ticket>) {
    let mut front = Vec::new();
    let mut back = Vec::new();
    for ticket in tickets {
        if ticket.seat < 100 {
            front.push(ticket);
        } else {
            back.push(ticket);
        }
    }
    (front, back)
}

/// Plain old data: `Copy`, so passing a Point copies its bits, like a C struct.
#[derive(Debug, Clone, Copy, PartialEq)]
pub struct Point {
    pub x: i32,
    pub y: i32,
}

/// Returns `p` moved one step right and one step down. The caller's point is untouched:
/// `nudge` got its own copy.
pub fn nudge(p: Point) -> Point {
    Point { x: p.x + 1, y: p.y + 1 }
}

/// Returns the original note and an independent copy with " (copy)" appended.
/// A String owns heap memory, so copying one is an explicit `.clone()`.
pub fn photocopy(note: String) -> (String, String) {
    let mut copy = note.clone();
    copy.push_str(" (copy)");
    (note, copy)
}
