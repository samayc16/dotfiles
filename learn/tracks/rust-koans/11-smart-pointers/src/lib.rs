//! Koan 11: smart pointers.

use std::cell::{BorrowMutError, RefCell};
use std::rc::Rc;

/// A cons list. Without the Box, List would contain a List would contain a List…
/// (infinite size). Box puts the rest of the list on the heap.
#[derive(Debug, PartialEq)]
pub enum List {
    Cons(i32, Box<List>),
    Nil,
}

impl List {
    /// The same elements in the same order: [1, 2] → Cons(1, Cons(2, Nil)).
    pub fn from_slice(xs: &[i32]) -> List {
        todo!()
    }

    /// The sum of the elements.
    pub fn sum(&self) -> i32 {
        todo!()
    }
}

/// Shared AND mutable: many owners (Rc), mutation through a shared reference (RefCell).
pub type Shared<T> = Rc<RefCell<T>>;

/// Someone listening to a shared playlist.
pub struct Listener {
    pub name: String,
    playlist: Shared<Vec<String>>,
}

impl Listener {
    /// Joins an existing playlist: shares it, never copies it.
    pub fn join(name: &str, playlist: &Shared<Vec<String>>) -> Listener {
        todo!()
    }

    /// Appends a song. Note `&self`, not `&mut self`: RefCell makes that possible.
    pub fn add(&self, song: &str) {
        todo!()
    }

    /// How many songs the shared playlist holds.
    pub fn count(&self) -> usize {
        todo!()
    }
}

/// How many owners `x` has right now.
pub fn owners<T>(x: &Rc<T>) -> usize {
    todo!()
}

/// Logs "open <name>" when created and "close <name>" when dropped.
pub struct Guard {
    name: String,
    log: Shared<Vec<String>>,
}

impl Guard {
    pub fn open(name: &str, log: &Shared<Vec<String>>) -> Guard {
        todo!()
    }
}

impl Drop for Guard {
    fn drop(&mut self) {
        // TODO: log "close <name>" (no todo!() here: a panic while dropping can abort the program)
    }
}

/// Doubles the value in place, or returns the error if someone is already borrowing it.
pub fn try_double(cell: &RefCell<i32>) -> Result<(), BorrowMutError> {
    todo!()
}
