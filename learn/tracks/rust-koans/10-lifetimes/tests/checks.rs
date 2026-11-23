//! The checks for this koan: each #[test] is one ✓/✗ line in `learn check`.
//! Read-only: `learn check` always runs the original, so editing this copy changes nothing.

use koan::*;

#[test]
fn longest_picks_the_longer() {
    assert_eq!(longest("apple", "fig"), "apple");
    assert_eq!(longest("ab", "xyz"), "xyz");
    assert_eq!(longest("tie", "abc"), "tie", "the first one wins a tie");
}

#[test]
fn before_borrows_only_from_text() {
    let text = String::from("key=value=more");
    let head;
    {
        let sep = String::from("=");
        head = before(&text, &sep);
    } // `sep` is gone here; `head` must not depend on it
    assert_eq!(head, "key");
    assert_eq!(before("plain", "::"), "plain", "no separator");
}

#[test]
fn find_all_returns_borrowed_highlights() {
    let text = String::from("the cat sat on the mat");
    let hits;
    {
        let word = String::from("at");
        hits = find_all(&text, &word);
    } // `word` is gone; the highlights borrow from `text` only
    let expected = vec![
        Highlight { text: "at", start: 5 },
        Highlight { text: "at", start: 9 },
        Highlight { text: "at", start: 20 },
    ];
    assert_eq!(hits, expected);
}

#[test]
fn words_hands_out_pieces_of_the_input() {
    let mut words = Words::new("  one two\tthree  ");
    assert_eq!(words.next_word(), Some("one"));
    assert_eq!(words.next_word(), Some("two"));
    assert_eq!(words.next_word(), Some("three"));
    assert_eq!(words.next_word(), None, "after the last word");
}

#[test]
fn words_outlive_the_parser() {
    let text = String::from("alpha beta");
    let first;
    {
        let mut words = Words::new(&text);
        first = words.next_word();
    } // the parser is gone; the word still points into `text`
    assert_eq!(first, Some("alpha"));
}

#[test]
fn level_names_are_static() {
    let name: &'static str = level_name(2);
    assert_eq!(name, "warn");
    assert_eq!(level_name(0), "debug");
    assert_eq!(level_name(9), "error");
}
