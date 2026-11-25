# Claude Code

Status line (Monokai):

```
Opus 5 │ effort high │ ~/repo/src │  main │ ctx 32% │ 5h 3% · in 4h 34m │ 7d 22% │ $26.58 │ +142 -37
```

model · effort · directory (bold leaf) · branch · context % (green → yellow → orange → pink) · 5h limit + reset countdown · 7d limit · session cost · diff stats. Segments hide when their data is absent.

**SessionStart hook:** if `.claude/SKILLS.md` exists in the cwd or any parent, its contents are injected into context at session start — a per-project always-on prompt without a global rule.

| cmd | does |
|---|---|
| `/help` | full list |
| `/rename <name>` | name the session |
| `/clear` | clear context |
| `/model` | switch model |
| `/fast` | toggle fast mode |
| `/loop <interval> <cmd>` | recurring prompts |
