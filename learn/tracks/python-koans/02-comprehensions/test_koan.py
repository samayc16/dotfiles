from harness import run
from koan import flatten, squares_of_evens, transpose, unique_initials, word_lengths


def test_squares_of_evens():
    assert squares_of_evens([1, 2, 3, 4]) == [4, 16]


def test_word_lengths():
    assert word_lengths(["vim", "awk"]) == {"vim": 3, "awk": 3}


def test_unique_initials():
    assert unique_initials(["Grep", "go", "", "sed"]) == {"g", "s"}


def test_flatten():
    assert flatten([[1, 2], [3], []]) == [1, 2, 3]


def test_transpose():
    assert transpose([[1, 2, 3], [4, 5, 6]]) == [[1, 4], [2, 5], [3, 6]]


run(globals())
