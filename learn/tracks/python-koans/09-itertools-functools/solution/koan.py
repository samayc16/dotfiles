import operator
from functools import cache, partial, reduce
from itertools import accumulate, groupby, pairwise


def group_by_first_letter(words: list[str]) -> dict[str, list[str]]:
    return {k: list(g) for k, g in groupby(sorted(words), key=lambda w: w[0])}


def neighbour_diffs(nums: list[int]) -> list[int]:
    return [b - a for a, b in pairwise(nums)]


def prefix_sums(nums: list[int]) -> list[int]:
    return list(accumulate(nums))


def product(nums: list[int]) -> int:
    return reduce(operator.mul, nums, 1)


@cache
def fib_memo(n: int) -> int:
    return n if n < 2 else fib_memo(n - 1) + fib_memo(n - 2)


square = partial(pow, exp=2)
