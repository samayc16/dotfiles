from harness import run
from koan import apply_all, make_multiplier, sort_by_age_then_name, top_n_by

PEOPLE = [{"name": "zoe", "age": 30}, {"name": "al", "age": 25}, {"name": "bo", "age": 30}]


def test_sort_by_age_then_name():
    names = [p["name"] for p in sort_by_age_then_name(PEOPLE)]
    assert names == ["al", "bo", "zoe"], f"got {names}"


def test_original_list_untouched():
    before = [p["name"] for p in PEOPLE]
    sort_by_age_then_name(PEOPLE)
    assert [p["name"] for p in PEOPLE] == before, "return a new list, don't sort in place"


def test_make_multiplier():
    triple = make_multiplier(3)
    assert triple(7) == 21


def test_apply_all():
    assert apply_all([abs, lambda v: v + 1, make_multiplier(2)], -4) == [4, -3, -8]


def test_top_n_by():
    words = ["a", "abcd", "ab", "abc"]
    assert top_n_by(words, 2, key=len) == ["abcd", "abc"]


run(globals())
