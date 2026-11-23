//! Koan 14: threads, channels and shared state.

use std::sync::mpsc::{self, Receiver, Sender};
use std::sync::{Arc, Mutex};
use std::thread::{self, JoinHandle};

/// Sums `xs` with `workers` threads (at least one), each summing one chunk.
/// `thread::scope` lets the threads borrow `xs`: they're all joined before it returns.
pub fn parallel_sum(xs: &[u64], workers: usize) -> u64 {
    todo!()
}

/// Runs `f` on every item, one thread per item, and returns the results in input order.
/// The threads share `f` (put it in an Arc) and send `(index, result)` over a channel.
pub fn map_threads<F>(items: Vec<i64>, f: F) -> Vec<i64>
where
    F: Fn(i64) -> i64 + Send + Sync + 'static,
{
    todo!()
}

/// Starts `threads` threads that each add 1 to the counter `per_thread` times,
/// and returns once all of them have finished.
pub fn hammer(counter: &Arc<Mutex<u64>>, threads: usize, per_thread: u64) {
    todo!()
}

/// Starts a worker thread that receives lines and sends back their length in characters.
/// It stops when the line channel closes and returns how many lines it handled.
/// Returns (where to send lines, where lengths arrive, the worker's handle).
pub fn spawn_length_worker() -> (Sender<String>, Receiver<usize>, JoinHandle<usize>) {
    todo!()
}
