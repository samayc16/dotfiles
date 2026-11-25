# neovim (leader = `Space`)

Press a leader prefix and pause: which-key lists everything under it. `<leader>?` shows buffer-local keys, `<leader>sk` searches every keymap, `<leader>sC` (or `:Cheat`) shows this page in a float (`:Cheat tmux` for another app's).
Layout: `nvim/lua/config/` (options, keymaps) · `nvim/lua/plugins/` (one file per concern) · `nvim/lua/plugins/lang/` (one file per language).

## languages (all offline once installed)
| language | LSP | format | run `<leader>rr` | debug |
|---|---|---|---|---|
| Python | basedpyright + ruff | ruff (on save) | `.venv` python, else python3 | debugpy (`<leader>dm` test method) |
| C / C++ | clangd (Xcode's on macOS) | clang-format (on save if `.clang-format`) | clang or gcc (`<leader>rc`), -std=c23 / c++26 + ASan/UBSan where they work | codelldb ("Debug current file") |
| Swift | sourcekit-lsp | swift-format / SwiftFormat | `swift run` (packages) or `swift file` | lldb-dap · Xcode apps: `<leader>X…` |
| SystemVerilog / Verilog | slang-server | Verible (`<leader>f`) | Verilator `--binary` or Icarus (`<leader>rc`); top = module named after file | waves: `<leader>ro` → surfer |
| Haskell | haskell-language-server | fourmolu (on save) | runghc | |
| Rust | rust-analyzer via rustaceanvim, clippy on save | rustfmt (on save) | `cargo run` in a Cargo project, else `rustc` | codelldb (`<leader>dn` debuggables) |
| Lua / shell | lua_ls + lazydev / bashls + ShellCheck | stylua / shfmt (`<leader>f`) | `nvim -l` / bash | |

Standalone C++ files default to **C++26** and C files to **C23** (`clangd/config.yaml`); projects use their `compile_commands.json`.

## code (LSP)
| keys | does |
|---|---|
| `K` | hover docs |
| `grd` / `grr` / `gri` / `grt` / `grD` | definition / references / implementation / type / declaration |
| `grn` or `<leader>cr` | rename symbol |
| `gra` or `<leader>ca` | code action |
| `gO` / `gW` | document / workspace symbols |
| `]d` `[d` · `]r` `[r` | next/prev diagnostic · next/prev reference to symbol under cursor |
| `<leader>q` / `<leader>Q` | diagnostics list (buffer / workspace) |
| `<leader>cs` | symbols outline |
| `<leader>cl` | run code lens |
| `<leader>ch` | C/C++: switch source ↔ header |
| `<leader>cR` / `<leader>ci` | restart LSP / LSP info |
| `<leader>f` | format buffer |
| `<leader>th` · `<leader>td` · `<leader>tf` | toggle inlay hints · multi-line diagnostics · format on save |

## completion & snippets
| keys | does |
|---|---|
| `Ctrl-y` / `Tab` / `Enter` | accept suggestion (all three work; `Ctrl-e` closes the menu for a plain newline) |
| `Ctrl-n` / `Ctrl-p` | next / previous suggestion |
| `Ctrl-Space` | open menu / docs |
| `Tab` / `Shift-Tab` | jump between snippet placeholders |
| `Ctrl-k` | signature help |

SystemVerilog snippets: `mod` `modp` `aff` `affs` `acomb` `fsm` `intf` `pkg` `struct` `enum` `genfor` `tb` `assertp` `coverp` `cg` `class` `func` `task` `fork` · UVM: `uvm_item` `uvm_seq` `uvm_drv` `uvm_mon` `uvm_agent` `uvm_sb` `uvm_env` `uvm_test` `uvm_top` `uinfo` `uerr` `ufatal` `cfgset` `cfgget`.

## run & build (overseer)
| keys | does |
|---|---|
| `<leader>rr` / `<leader>rR` | run current file / with arguments |
| `<leader>ro` | pick a project task (make, cmake, swift build/test, pytest, verilator lint, iverilog, surfer…) |
| `<leader>rl` | re-run last task |
| `<leader>rc` · `:Toolchain [c\|cpp\|hdl]` | choose what `<leader>rr` uses: clang / gcc / gcc-NN, clang++ / g++, Verilator / Icarus (saved) |
| `<leader>rt` | toggle task list (`o` open output, `dd` dispose) |
| `<leader>rs` | run a shell command as a task |

## debug (nvim-dap)
| keys | does |
|---|---|
| `<leader>db` / `<leader>dB` | toggle breakpoint / conditional breakpoint |
| `<leader>dc` or `F5` | start / continue |
| `<leader>do` `<leader>di` `<leader>dO` (`F10` `F11` `F12`) | step over / into / out |
| `<leader>dC` | run to cursor |
| `<leader>de` | evaluate expression / selection |
| `<leader>du` / `<leader>dr` | toggle debug UI / REPL |
| `<leader>dl` / `<leader>dt` | run last / terminate |

## Xcode projects (macOS)
Run `:XcodebuildSetup` once in the project root (writes `buildServer.json` so sourcekit-lsp understands the `.xcodeproj`).
| keys | does |
|---|---|
| `<leader>XX` | all Xcode actions |
| `<leader>Xr` / `<leader>Xb` / `<leader>Xd` | build & run on simulator / build / build & debug |
| `<leader>Xt` / `<leader>XT` / `<leader>Xe` | tests / test class / test explorer |
| `<leader>Xs` / `<leader>Xp` / `<leader>Xl` | select device / SwiftUI preview / logs |
| `<leader>Xo` | open in Xcode (previews, signing, asset catalogs) |

## SystemVerilog design (slang-server)
| keys | does |
|---|---|
| `<leader>vh` / `<leader>vs` / `<leader>va` | design hierarchy / search hierarchy / select active instance |
Per-project include dirs, file lists and UVM paths go in `.slang/server.json`.

## Rust (rustaceanvim)
| keys | does |
|---|---|
| `<leader>ce` / `<leader>cE` | explain this error (`rustc --explain`) / the full compiler message |
| `<leader>cm` | expand the macro under the cursor |
| `<leader>cD` | open docs.rs for the symbol |
| `<leader>cp` / `<leader>cC` | parent module / open Cargo.toml |
| `<leader>rn` / `<leader>dn` | run / debug a test, binary or example (runnables / debuggables) |
| `<leader>th` | hide / show inlay hints (inferred types and lifetimes, on by default) |
In `Cargo.toml`, crates.nvim shows the latest version of each dependency; `gra` upgrades it.

## search (telescope)
| keys | does |
|---|---|
| `<leader>sf` / `<leader>sg` / `<leader>sw` | files / live grep / word under cursor |
| `<leader><leader>` / `<leader>s.` | open buffers / recent files |
| `<leader>/` / `<leader>s/` | fuzzy in buffer / grep open files |
| `<leader>sh` `sk` `sc` `sd` `sq` `st` | help / keymaps / commands / diagnostics / quickfix / TODOs |
| `<leader>sr` / `<leader>sn` / `<leader>sN` | resume / nvim config / notifications |

## editing
| keys | does |
|---|---|
| `saiw"` / `sd'` / `sr)'` | surround: add / delete / replace (mini.surround) |
| `ci(` `daf` `cia` `yiq` `vib` | text objects incl. function call `f`, argument `a`, quote `q`, bracket `b` (mini.ai) |
| `gcc` / `gc{motion}` | comment line / motion |
| `J` / `K` (visual) | move selection down / up |
| `Ctrl-s` | save |
| `Ctrl-d` / `Ctrl-u` / `n` / `N` | scroll / search, cursor stays centred |
| `za` `zc` `zo` `zR` `zM` | folds (treesitter) |
| `[x` · `<leader>tc` | jump to enclosing function/class · toggle sticky context header |

## files, git, buffers, windows
| keys | does |
|---|---|
| `-` | file browser (oil): edit the listing like a buffer, `:w` applies renames/moves/deletes |
| `Shift-h` / `Shift-l` · `<leader>1`…`9` | prev / next buffer · jump to buffer N |
| `<leader>x` · `<leader>bp` / `<leader>bo` | close buffer · pin / close others |
| `:q` | closes the buffer, or quits if it's the last one |
| `]c` `[c` · `<leader>hs` `hr` `hp` `hb` `hd` | next/prev git hunk · stage / reset / preview / blame / diff |
| `<leader>gg` / `<leader>gl` / `<leader>gB` | lazygit / file log / open on GitHub |
| `<leader>tb` | toggle inline git blame |
| `Ctrl-h/j/k/l` | move between splits and tmux panes |
| `<leader>tt` or `Ctrl-/` | toggle terminal |
| `<leader>ut` | undotree |
| `<leader>tm` · `<leader>tw` · `<leader>ts` · `<leader>tr` | toggle markdown render · wrap · spell · relative numbers |

## Claude Code
| keys | does |
|---|---|
| `<leader>ac` / `<leader>af` | toggle / focus Claude panel |
| `<leader>ab` · `<leader>as` (visual) | add current file · send selection |
| `<leader>aa` / `<leader>ad` | accept / deny Claude's diff |

## keeping it healthy
| command | does |
|---|---|
| `:Lazy` | plugins (`:Lazy sync` to update, then commit `nvim/lazy-lock.json`) |
| `:Mason` | language servers / formatters / debuggers |
| `:checkhealth` | diagnose anything |
| `nvim --headless -c 'luafile ~/.config/nvim/scripts/smoke.lua'` | end-to-end test of every language |
