import asyncio
from collections.abc import Awaitable


async def fetch(name: str, delay: float) -> str:
    await asyncio.sleep(delay)
    return name.upper()


async def fetch_all(names: list[str], delay: float) -> list[str]:
    return [await fetch(n, delay) for n in names]  # TODO: this runs them one by one


async def fetch_grouped(names: list[str], delay: float) -> list[str]:
    raise NotImplementedError("use asyncio.TaskGroup")


async def with_timeout[T](awaitable: Awaitable[T], seconds: float) -> T | None:
    raise NotImplementedError("asyncio.timeout + except TimeoutError")
