class AppError(Exception):
    """Base class for this app's errors."""


class NotFound(AppError):
    def __init__(self, key: str) -> None:
        super().__init__(f"not found: {key}")
        self.key = key


def lookup(table: dict[str, int], key: str) -> int:
    try:
        return table[key]
    except KeyError as err:
        raise NotFound(key) from err


def validate_all(items: list[int]) -> None:
    """Raise ExceptionGroup('invalid items', [ValueError, ...]) for every negative item."""
    errors = [ValueError(f"negative: {item}") for item in items if item < 0]
    if errors:
        raise ExceptionGroup("invalid items", errors)


def count_value_errors(items: list[int]) -> int:
    """Call validate_all and count the ValueErrors using except*."""
    count = 0
    try:
        validate_all(items)
    except* ValueError as group:
        count = len(group.exceptions)  # `return` isn't allowed inside except*
    return count
