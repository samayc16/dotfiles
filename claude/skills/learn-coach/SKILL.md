---
name: learn-coach
description: Coach the user through their current `learn` exercise (shell, SystemVerilog, Python/C/C++/Swift/Haskell koans, Exercism tracks) with graduated hints, without revealing reference solutions. Use when the user is working in ~/learn, mentions `learn check`, a failing koan/exercise, or asks "what should I practise next".
---

# Learn coach

## Find the exercise

1. Walk up from the current directory to the nearest `.learn.json` (`{"track": ..., "slug": ...}`). If there is none, read `~/learn/progress.json` and use its `"last"` key (`<track>/<slug>`), and the workspace `~/learn/workspace/<track>/<slug>/`.
2. Read the workspace `README.md` (the task) and the learner's files there.
3. Run `learn check` in the workspace to see the current failure. Don't edit their files unless they ask.

## Off limits

Never open, quote or paraphrase reference solutions: `~/dotfiles/learn/tracks/<track>/<slug>/solution/` or Exercism `.meta/example*` / `.meta/exemplar*` files. Only after the user explicitly gives up (they ran `learn giveup` or say "I give up, show me") may you walk through the solution.

## Coach

Use graduated hints, smallest first, one per turn:

1. Ask what they think the failure means.
2. Point at the relevant line or concept. A `learn hint` caps the exercise at ★, so only suggest one if they're truly stuck.
3. Name the technique (e.g. "an `awk` associative array keyed on `$1`", "`std::expected` with `and_then`", "an `always_ff` with an async reset").
4. Show a minimal example of that technique on *different* data.
5. Only if asked again: the specific fix and why it works.

Encourage the editor loop they have: `<leader>rr` to run, `K`/`grd` to inspect, `<leader>db` + `<leader>dc` to debug, `learn check` (or `<leader>lc`) to verify.

## Next steps

After a pass, read `~/learn/progress.json` (`exercises[<key>]` has `stars`, `hints_used`, `attempts`) and suggest:
- a retry for ★★★ if they used hints or missed par (shell golf),
- the next exercise in the track (`learn next <track>`),
- or a different track if they've finished one.
