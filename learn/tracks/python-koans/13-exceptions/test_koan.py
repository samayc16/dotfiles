from harness import run
from koan import AppError, NotFound, count_value_errors, lookup, validate_all


def test_hierarchy():
    assert issubclass(NotFound, AppError) and issubclass(AppError, Exception)
    err = NotFound("cfg")
    assert err.key == "cfg" and "cfg" in str(err)


def test_lookup_chains_the_cause():
    try:
        lookup({"a": 1}, "b")
    except NotFound as err:
        assert isinstance(err.__cause__, KeyError), "use `raise NotFound(key) from err`"
        return
    raise AssertionError("lookup should raise NotFound")


def test_validate_all_reports_everything():
    try:
        validate_all([1, -2, 3, -4])
    except ExceptionGroup as group:
        assert len(group.exceptions) == 2 and all(isinstance(e, ValueError) for e in group.exceptions)
        return
    raise AssertionError("expected an ExceptionGroup")


def test_validate_all_quiet_when_valid():
    validate_all([1, 2, 3])


def test_except_star():
    assert count_value_errors([-1, -2, -3]) == 3 and count_value_errors([5]) == 0


run(globals())
