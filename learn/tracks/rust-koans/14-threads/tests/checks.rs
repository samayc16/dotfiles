//! The checks for this koan: each #[test] is one ✓/✗ line in `learn check`.
//! Read-only: `learn check` always runs the original, so editing this copy changes nothing.

use koan::*;
use std::collections::HashSet;
use std::sync::{Arc, Mutex};
use std::thread;

#[test]
fn parallel_sum_matches_a_plain_sum() {
    let xs: Vec<u64> = (1..=1000).collect();
    for workers in [1, 3, 8, 2000] {
        assert_eq!(parallel_sum(&xs, workers), 500_500, "with {workers} workers");
    }
    assert_eq!(parallel_sum(&[], 4), 0, "an empty slice");
    assert_eq!(parallel_sum(&[5], 0), 5, "zero workers still means one");
}

#[test]
fn map_threads_keeps_input_order() {
    assert_eq!(map_threads(vec![3, 1, 2], |x| x * x), vec![9, 1, 4]);
    assert_eq!(map_threads(Vec::new(), |x| x), Vec::<i64>::new(), "no items");
}

#[test]
fn map_threads_runs_f_on_other_threads() {
    let seen = Arc::new(Mutex::new(HashSet::new()));
    let record = Arc::clone(&seen);
    let out = map_threads(vec![1, 2, 3, 4], move |x| {
        record.lock().unwrap().insert(thread::current().id());
        x * 10
    });
    assert_eq!(out, vec![10, 20, 30, 40], "results in input order");
    let ids = seen.lock().unwrap();
    assert_eq!(ids.len(), 4, "distinct threads that ran f (one per item)");
    assert!(!ids.contains(&thread::current().id()), "f must not run on the calling thread");
}

#[test]
fn hammer_counts_every_increment() {
    let counter = Arc::new(Mutex::new(5));
    hammer(&counter, 8, 1000);
    assert_eq!(*counter.lock().unwrap(), 8005, "5 + 8 threads × 1000");
    assert_eq!(Arc::strong_count(&counter), 1, "every thread finished and dropped its Arc");
}

#[test]
fn a_worker_thread_answers_over_channels() {
    let (lines, lengths, worker) = spawn_length_worker();
    for text in ["one", "three", "héllo"] {
        lines.send(text.to_string()).unwrap();
    }
    drop(lines); // closing the channel lets the worker's loop end
    let got: Vec<usize> = lengths.iter().collect();
    assert_eq!(got, vec![3, 5, 5], "lengths in characters");
    assert_eq!(worker.join().unwrap(), 3, "lines the worker handled");
}
