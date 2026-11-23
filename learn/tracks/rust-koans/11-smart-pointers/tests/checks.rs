//! The checks for this koan: each #[test] is one ✓/✗ line in `learn check`.
//! Read-only: `learn check` always runs the original, so editing this copy changes nothing.

use koan::*;
use std::cell::RefCell;
use std::rc::Rc;

fn cons(x: i32, rest: List) -> List {
    List::Cons(x, Box::new(rest))
}

#[test]
fn from_slice_keeps_the_order() {
    assert_eq!(List::from_slice(&[1, 2]), cons(1, cons(2, List::Nil)));
    assert_eq!(List::from_slice(&[]), List::Nil, "an empty slice");
}

#[test]
fn sum_recurses_through_the_boxes() {
    assert_eq!(cons(4, cons(5, cons(6, List::Nil))).sum(), 15);
    assert_eq!(List::Nil.sum(), 0, "Nil");
}

#[test]
fn listeners_share_one_playlist() {
    let playlist = Rc::new(RefCell::new(vec!["intro".to_string()]));
    let ann = Listener::join("ann", &playlist);
    let bob = Listener::join("bob", &playlist);
    ann.add("song a");
    bob.add("song b");
    assert_eq!(ann.count(), 3, "ann sees all three songs");
    assert_eq!(bob.count(), 3, "bob sees all three songs");
    assert_eq!(*playlist.borrow(), ["intro", "song a", "song b"]);
}

#[test]
fn joining_adds_an_owner() {
    let playlist = Rc::new(RefCell::new(Vec::new()));
    assert_eq!(owners(&playlist), 1, "before anyone joins");
    let ann = Listener::join("ann", &playlist);
    {
        let _bob = Listener::join("bob", &playlist);
        assert_eq!(owners(&playlist), 3, "with ann and bob");
    }
    assert_eq!(owners(&playlist), 2, "after bob is dropped");
    drop(ann);
    assert_eq!(owners(&playlist), 1, "after ann is dropped");
}

#[test]
fn guards_close_in_reverse_order() {
    let log = Rc::new(RefCell::new(Vec::new()));
    {
        let _a = Guard::open("a", &log);
        let b = Guard::open("b", &log);
        drop(b);
        let _c = Guard::open("c", &log);
    }
    assert_eq!(*log.borrow(), ["open a", "open b", "close b", "open c", "close c", "close a"]);
}

#[test]
fn refcell_checks_borrows_at_runtime() {
    let cell = RefCell::new(21);
    assert!(try_double(&cell).is_ok(), "nobody else is borrowing yet");
    assert_eq!(*cell.borrow(), 42);
    let reader = cell.borrow();
    assert!(try_double(&cell).is_err(), "a shared borrow is alive: no mutable borrow allowed");
    drop(reader);
    assert_eq!(*cell.borrow(), 42, "unchanged by the refused call");
}
