def squares_of_evens(nums: list[int]) -> list[int]:
    return [n * n for n in nums if n % 2 == 0]


def word_lengths(words: list[str]) -> dict[str, int]:
    return {w: len(w) for w in words}


def unique_initials(words: list[str]) -> set[str]:
    """Lower-cased first letters, skipping empty strings."""
    return {w[0].lower() for w in words if w}


def flatten(matrix: list[list[int]]) -> list[int]:
    return [x for row in matrix for x in row]


def transpose(matrix: list[list[int]]) -> list[list[int]]:
    return [list(column) for column in zip(*matrix)]
