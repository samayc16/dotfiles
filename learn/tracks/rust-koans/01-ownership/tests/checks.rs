//! The checks for this koan: each #[test] is one ✓/✗ line in `learn check`.
//! Read-only: `learn check` always runs the original, so editing this copy changes nothing.

use koan::*;

fn t(seat: u32) -> Ticket {
    Ticket { seat }
}

#[test]
fn stash_moves_the_ticket_into_the_wallet() {
    let wallet = vec![t(1)];
    let wallet = stash(wallet, t(42)); // ownership goes in, and comes back out
    assert_eq!(wallet, vec![t(1), t(42)]);
}

#[test]
fn take_last_moves_one_ticket_out() {
    let (wallet, last) = take_last(vec![t(7), t(9)]);
    assert_eq!(last, Some(t(9)), "the ticket that was taken");
    assert_eq!(wallet, vec![t(7)], "what's left in the wallet");
}

#[test]
fn take_last_of_an_empty_wallet_is_none() {
    let (wallet, last) = take_last(Vec::new());
    assert_eq!(last, None);
    assert!(wallet.is_empty(), "the wallet should still be empty");
}

#[test]
fn split_rows_keeps_order() {
    let (front, back) = split_rows(vec![t(150), t(3), t(99), t(100), t(12)]);
    assert_eq!(front, vec![t(3), t(99), t(12)], "front row");
    assert_eq!(back, vec![t(150), t(100)], "back rows");
}

#[test]
fn nudge_works_on_a_copy() {
    let p = Point { x: 2, y: 5 };
    let moved = nudge(p);
    assert_eq!(moved, Point { x: 3, y: 6 }, "nudge(Point {{ x: 2, y: 5 }})");
    assert_eq!(p, Point { x: 2, y: 5 }, "p is still usable and unchanged: Point is Copy");
}

#[test]
fn photocopy_makes_an_independent_string() {
    let (original, copy) = photocopy(String::from("meet at 8"));
    assert_eq!(original, "meet at 8", "the original");
    assert_eq!(copy, "meet at 8 (copy)", "the copy");
}
