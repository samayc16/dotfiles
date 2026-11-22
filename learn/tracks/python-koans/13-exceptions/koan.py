class AppError(Exception):
    pass


class NotFound:  # TODO: subclass AppError, store .key
    pass


def lookup(table: dict[str, int], key: str) -> int:
    return table[key]  # TODO: translate KeyError into NotFound, keeping the cause


def validate_all(items: list[int]) -> None:
    """Raise ExceptionGroup('invalid items', [ValueError, ...]) for every negative item."""
    raise NotImplementedError


def count_value_errors(items: list[int]) -> int:
    """Call validate_all and count the ValueErrors using except*."""
    raise NotImplementedError
