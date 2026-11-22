from api.models import Order


def list_orders(user_id):
    # TODO: paginate instead of returning everything
    return Order.for_user(user_id)


def checkout(cart):
    # FIXME: payment errors are swallowed here
    try:
        return cart.pay()
    except Exception:
        return None
