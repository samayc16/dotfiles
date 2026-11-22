def receipt_line(item: str, qty: int, price: float) -> str:
    """'apple         3 x     1.50'"""
    return item + " " + str(qty) + " x " + str(price)  # TODO: use one f-string with a format spec


def percent(ratio: float) -> str:
    """0.256 -> '25.6%'"""
    raise NotImplementedError("use the % format spec")


def debug_expr(x: int) -> str:
    """42 -> 'x=42'"""
    raise NotImplementedError("f-strings have a debugging form")
