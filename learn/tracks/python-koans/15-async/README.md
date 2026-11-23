# 15 · async/await: gather, TaskGroup, timeouts

## Why it matters
async/await lets one thread juggle thousands of waiting operations (network, subprocesses). Knowing gather, TaskGroup and timeouts covers most real-world async code.

## New syntax
| Syntax | Meaning | Example (not the answer) |
|---|---|---|
| `async def f()` | coroutine function: calling it returns a coroutine; nothing runs until it's awaited | `async def ping() -> str:` |
| `await x` | run `x` and wait for its result, letting other tasks run meanwhile | `await asyncio.sleep(0.1)` |
| `asyncio.run(main())` | start the event loop (the harness does this for async tests) | |
| `await asyncio.gather(*coros)` | run many concurrently; results come back in argument order | `await asyncio.gather(ping(), ping())` → `['pong', 'pong']` |
| `async with asyncio.TaskGroup() as tg:` | structured concurrency (3.11+): leaving the block waits for every task; one failure cancels the rest | see below |
| `tg.create_task(coro)`, `task.result()` | schedule a coroutine now; read its value once it has finished | |
| `async with asyncio.timeout(s):` | cancel the block after `s` seconds and raise `TimeoutError` (3.11+) | see below |
| `Awaitable[T]` | anything you can `await` that produces a `T` | |

```python
async def slow_add(a: int, b: int) -> int:
    await asyncio.sleep(0.2)
    return a + b

async def main() -> None:
    async with asyncio.TaskGroup() as tg:
        t1 = tg.create_task(slow_add(1, 2))
        t2 = tg.create_task(slow_add(3, 4))
    print(t1.result(), t2.result())       # 3 7 after ~0.2 s total, not 0.4 s
    try:
        async with asyncio.timeout(0.05):
            await slow_add(5, 6)
    except TimeoutError:
        print("too slow")

asyncio.run(main())
```

## Your task
- `fetch_all` runs every fetch CONCURRENTLY (the check times it)
- `fetch_grouped` does the same with a TaskGroup
- `with_timeout` returns None if the coroutine takes too long

Edit `koan.py` until every check passes.

## Run it
- `learn check` in a terminal, or `<leader>lc` in nvim
- Stuck? `learn hint` / `<leader>lh` (costs ★★)

## Nvim tips
- `K` on any name shows its docs (try it on `dataclass`, `field`, `replace`)
- `grd` jumps to a definition, `<C-o>` jumps back
- `<leader>rr` runs the file; `<leader>db` sets a breakpoint, `<leader>dc` starts the debugger
- `<leader>f` formats with ruff
