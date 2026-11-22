from harness import run
from koan import count_calls, retry


def test_count_calls():
    @count_calls
    def greet(name: str) -> str:
        """Say hi."""
        return f"hi {name}"

    greet("a"), greet("b")
    assert greet.calls == 2
    assert greet.__name__ == "greet" and greet.__doc__ == "Say hi.", "use functools.wraps"


def test_retry_eventually_succeeds():
    attempts = []

    @retry(times=3)
    def flaky() -> str:
        attempts.append(1)
        if len(attempts) < 3:
            raise ConnectionError("try again")
        return "ok"

    assert flaky() == "ok" and len(attempts) == 3


def test_retry_gives_up():
    @retry(times=2)
    def always_fails() -> None:
        raise ValueError("nope")

    try:
        always_fails()
    except ValueError:
        return
    raise AssertionError("after the last attempt the original exception should propagate")


run(globals())
