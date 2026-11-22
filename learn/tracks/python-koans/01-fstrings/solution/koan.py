def receipt_line(item: str, qty: int, price: float) -> str:
    """'apple         3 x     1.50'"""
    return f"{item:<12}{qty:>3} x {price:>8.2f}"


def percent(ratio: float) -> str:
    """0.256 -> '25.6%'"""
    return f"{ratio:.1%}"


def debug_expr(x: int) -> str:
    """42 -> 'x=42'"""
    return f"{x=}"
