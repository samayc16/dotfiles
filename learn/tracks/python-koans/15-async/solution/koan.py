import asyncio
from collections.abc import Awaitable


async def fetch(name: str, delay: float) -> str:
    await asyncio.sleep(delay)
    return name.upper()


async def fetch_all(names: list[str], delay: float) -> list[str]:
    return list(await asyncio.gather(*(fetch(n, delay) for n in names)))


async def fetch_grouped(names: list[str], delay: float) -> list[str]:
    async with asyncio.TaskGroup() as group:
        tasks = [group.create_task(fetch(n, delay)) for n in names]
    return [task.result() for task in tasks]


async def with_timeout[T](awaitable: Awaitable[T], seconds: float) -> T | None:
    try:
        async with asyncio.timeout(seconds):
            return await awaitable
    except TimeoutError:
        return None
