from harness import run
from koan import Item, Version


def test_item_fields_and_repr():
    item = Item("pen", 1.5)
    assert item.name == "pen" and item.price == 1.5 and item.tags == []
    assert repr(item) == "Item(name='pen', price=1.5, tags=[])", repr(item)


def test_items_compare_by_value():
    assert Item("pen", 1.5) == Item("pen", 1.5)


def test_tags_not_shared_between_instances():
    a, b = Item("a", 1), Item("b", 2)
    a.tags.append("x")
    assert b.tags == [], "use field(default_factory=list)"


def test_negative_price_rejected():
    try:
        Item("bad", -1)
    except ValueError:
        return
    raise AssertionError("Item('bad', -1) should raise ValueError")


def test_version_parse_and_order():
    versions = [Version.parse(v) for v in ["1.10.0", "1.2.3", "0.9.9"]]
    assert sorted(versions) == [Version(0, 9, 9), Version(1, 2, 3), Version(1, 10, 0)]


run(globals())
