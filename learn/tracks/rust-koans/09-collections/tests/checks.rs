//! The checks for this koan: each #[test] is one ✓/✗ line in `learn check`.
//! Read-only: `learn check` always runs the original, so editing this copy changes nothing.

use koan::*;
use std::collections::{BTreeMap, HashMap};

fn strings(words: &[&str]) -> Vec<String> {
    words.iter().map(|w| w.to_string()).collect()
}

#[test]
fn word_counts_normalises_words() {
    let counts = word_counts("The cat. the CAT, the hat!");
    assert_eq!(counts.get("the"), Some(&3), "\"the\"");
    assert_eq!(counts.get("cat"), Some(&2), "\"cat\"");
    assert_eq!(counts.get("hat"), Some(&1), "\"hat\"");
    assert_eq!(counts.len(), 3, "distinct words");
}

#[test]
fn word_counts_skips_bare_punctuation() {
    assert_eq!(word_counts("-- hi --"), HashMap::from([("hi".to_string(), 1)]));
}

#[test]
fn top_words_sorts_by_count_then_word() {
    let counts = HashMap::from([("b".to_string(), 3), ("a".to_string(), 2), ("d".to_string(), 1), ("c".to_string(), 1)]);
    let expected = vec![("b".to_string(), 3), ("a".to_string(), 2), ("c".to_string(), 1)];
    assert_eq!(top_words(&counts, 3), expected);
    assert_eq!(top_words(&counts, 10).len(), 4, "n larger than the map");
}

#[test]
fn by_length_groups_and_sorts() {
    let groups = by_length(&["pear", "fig", "kiwi", "apple", "yam", "plum"]);
    let expected = BTreeMap::from([
        (3, strings(&["fig", "yam"])),
        (4, strings(&["kiwi", "pear", "plum"])),
        (5, strings(&["apple"])),
    ]);
    assert_eq!(groups, expected);
}

#[test]
fn by_length_counts_characters_not_bytes() {
    let groups = by_length(&["café"]);
    assert_eq!(groups.keys().collect::<Vec<_>>(), [&4], "\"café\" is 4 characters (5 bytes)");
}

#[test]
fn dedup_keeps_first_occurrences() {
    let mut v = vec![3, 1, 3, 2, 1, 4];
    dedup_keep_order(&mut v);
    assert_eq!(v, vec![3, 1, 2, 4]);
}

#[test]
fn reverse_chars_respects_utf8() {
    assert_eq!(reverse_chars("añb"), "bña");
    assert_eq!(reverse_chars("🦀 ok"), "ko 🦀");
}
