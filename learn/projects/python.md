# Reading quests: Python

Projects live in `~/learn/projects/python/`. Both have a `pyrightconfig.json` pointing at the
learn venv (`~/learn/.venv`, where stamina's dependencies are installed) so basedpyright resolves imports.

Keys: `gO` symbols · `grd` definition (works into the standard library too) · `grr` references ·
`K` hover with inferred types · `<leader>rr` run the file · `<leader>db` breakpoint, `<leader>dc` debug.

## micrograd: an autograd engine + neural net in ~150 lines (`cd ~/learn/projects/python/micrograd && nvim micrograd/engine.py`)

- [ ] **Operator overloading.** `gO` in `engine.py`: `__add__`, `__mul__`, `__pow__`, `__radd__`…
      Why does `2 + Value(3)` need `__radd__`?
- [ ] **Closures as the graph.** Each op defines a nested `_backward()` that captures `self`, `other` and `out`.
      Put the cursor in one and `[x`: what does it close over, and when does it run?
- [ ] **Topological sort.** In `backward`, read `build_topo`. Why must gradients flow in reverse topological order?
- [ ] **The net.** In `nn.py`, follow `MLP` → `Layer` → `Neuron` with `grd`. Where do the weights live?
- [ ] **Prove it (debugger quest).** Make `scratch.py` next to the package:
      `from micrograd.engine import Value; a = Value(2.0); b = a * a + a; b.backward(); print(a.grad)`.
      `<leader>db` on the `backward()` line, `<leader>dc` to start, `<leader>di` to step into it. Predict `a.grad` first (it's 5).

## stamina: a modern, fully typed retry library (`cd ~/learn/projects/python/stamina && nvim src/stamina/_core.py`)

- [ ] **Decorators with arguments.** `gO` → `retry`. It returns a decorator: find where it wraps the function and
      how it handles both `def` and `async def` (search `iscoroutinefunction`).
- [ ] **Dataclasses in the wild.** Find the `@dataclass` classes (`<leader>sg` "@dataclass"). Which are frozen? Why?
- [ ] **Typing.** `K` on `retry`: read the full signature, including `ParamSpec`/`TypeVar` usage. `grd` on one of them.
- [ ] **TypedDict.** `RetryKWs` is a `TypedDict`: `grr` to see where it's used and why a dict-with-a-schema helps.
- [ ] **Context managers.** `retry_context` yields `Attempt` objects. Find `__enter__`/`__exit__` on `Attempt`.
- [ ] **Prove it.** Write a function that fails twice then succeeds, decorate it with `@stamina.retry(on=ValueError)`,
      and run it with `<leader>rr` (the learn venv has stamina installed).
