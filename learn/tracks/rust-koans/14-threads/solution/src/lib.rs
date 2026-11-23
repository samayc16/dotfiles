//! Koan 14: threads, channels and shared state.

use std::sync::mpsc::{self, Receiver, Sender};
use std::sync::{Arc, Mutex};
use std::thread::{self, JoinHandle};

/// Sums `xs` with `workers` threads (at least one), each summing one chunk.
/// `thread::scope` lets the threads borrow `xs`: they're all joined before it returns.
pub fn parallel_sum(xs: &[u64], workers: usize) -> u64 {
    let chunk = xs.len().div_ceil(workers.max(1)).max(1);
    thread::scope(|s| {
        let handles: Vec<_> = xs.chunks(chunk).map(|part| s.spawn(move || part.iter().sum::<u64>())).collect();
        handles.into_iter().map(|h| h.join().unwrap()).sum()
    })
}

/// Runs `f` on every item, one thread per item, and returns the results in input order.
/// The threads share `f` (put it in an Arc) and send `(index, result)` over a channel.
pub fn map_threads<F>(items: Vec<i64>, f: F) -> Vec<i64>
where
    F: Fn(i64) -> i64 + Send + Sync + 'static,
{
    let f = Arc::new(f);
    let (tx, rx) = mpsc::channel();
    for (i, item) in items.into_iter().enumerate() {
        let tx = tx.clone();
        let f = Arc::clone(&f);
        thread::spawn(move || tx.send((i, f(item))).unwrap());
    }
    drop(tx); // the loop below ends once every worker's Sender is gone
    let mut results: Vec<(usize, i64)> = rx.iter().collect();
    results.sort_unstable_by_key(|&(i, _)| i);
    results.into_iter().map(|(_, value)| value).collect()
}

/// Starts `threads` threads that each add 1 to the counter `per_thread` times,
/// and returns once all of them have finished.
pub fn hammer(counter: &Arc<Mutex<u64>>, threads: usize, per_thread: u64) {
    let handles: Vec<_> = (0..threads)
        .map(|_| {
            let counter = Arc::clone(counter);
            thread::spawn(move || {
                for _ in 0..per_thread {
                    *counter.lock().unwrap() += 1;
                }
            })
        })
        .collect();
    for handle in handles {
        handle.join().unwrap();
    }
}

/// Starts a worker thread that receives lines and sends back their length in characters.
/// It stops when the line channel closes and returns how many lines it handled.
/// Returns (where to send lines, where lengths arrive, the worker's handle).
pub fn spawn_length_worker() -> (Sender<String>, Receiver<usize>, JoinHandle<usize>) {
    let (line_tx, line_rx) = mpsc::channel::<String>();
    let (len_tx, len_rx) = mpsc::channel();
    let worker = thread::spawn(move || {
        let mut handled = 0;
        for line in line_rx {
            if len_tx.send(line.chars().count()).is_err() {
                break;
            }
            handled += 1;
        }
        handled
    });
    (line_tx, len_rx, worker)
}
