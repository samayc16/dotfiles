//! Koan 09: collections.

use std::collections::{BTreeMap, HashMap, HashSet};

/// How often each word appears. Words are split on whitespace, lowercased, and have
/// non-alphanumeric characters trimmed from both ends ("Hello," counts as "hello").
/// Words that end up empty are skipped.
pub fn word_counts(text: &str) -> HashMap<String, usize> {
    let mut counts = HashMap::new();
    for raw in text.split_whitespace() {
        let word = raw.trim_matches(|c: char| !c.is_alphanumeric()).to_lowercase();
        if !word.is_empty() {
            *counts.entry(word).or_insert(0) += 1;
        }
    }
    counts
}

/// The `n` most frequent words with their counts: highest count first, ties alphabetical.
pub fn top_words(counts: &HashMap<String, usize>, n: usize) -> Vec<(String, usize)> {
    let mut pairs: Vec<(String, usize)> = counts.iter().map(|(word, &count)| (word.clone(), count)).collect();
    pairs.sort_by(|a, b| b.1.cmp(&a.1).then_with(|| a.0.cmp(&b.0)));
    pairs.truncate(n);
    pairs
}

/// Words grouped by their length in characters; each group sorted alphabetically.
pub fn by_length(words: &[&str]) -> BTreeMap<usize, Vec<String>> {
    let mut groups: BTreeMap<usize, Vec<String>> = BTreeMap::new();
    for word in words {
        groups.entry(word.chars().count()).or_default().push(word.to_string());
    }
    for group in groups.values_mut() {
        group.sort();
    }
    groups
}

/// Removes repeated values in place, keeping the first occurrence of each.
pub fn dedup_keep_order(xs: &mut Vec<i32>) {
    let mut seen = HashSet::new();
    xs.retain(|&x| seen.insert(x));
}

/// Reverses by character: "añb" (4 bytes, 3 chars) becomes "bña".
pub fn reverse_chars(s: &str) -> String {
    s.chars().rev().collect()
}
