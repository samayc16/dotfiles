import operator
from functools import cache, partial, reduce
from itertools import accumulate, groupby, pairwise


def group_by_first_letter(words: list[str]) -> dict[str, list[str]]:
    raise NotImplementedError


def neighbour_diffs(nums: list[int]) -> list[int]:
    raise NotImplementedError


def prefix_sums(nums: list[int]) -> list[int]:
    raise NotImplementedError


def product(nums: list[int]) -> int:
    raise NotImplementedError


def fib_memo(n: int) -> int:  # TODO: memoize me
    return n if n < 2 else fib_memo(n - 1) + fib_memo(n - 2)


square = None  # TODO: partial(pow, ...)
