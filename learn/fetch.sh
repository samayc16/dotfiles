#!/usr/bin/env bash
# Download everything `learn` needs to work OFFLINE (run it before a flight).
#
#   ~/learn/vendor/<lang>     Exercism tracks (python, c, cpp, swift, rust), MIT
#   ~/learn/projects/<lang>   small real-world codebases to read with the LSP
#   ~/learn/docs/<lang>       offline reference docs (cppreference, Python, GHC base, ...)
#   ~/learn/.venv             Python with pytest for the Python tracks
#
# Idempotent: re-running moves each repo to its pinned commit, keeping any you've changed. Offline, network steps are skipped
# with a message and everything already on disk keeps working.
# Usage: learn/fetch.sh [--no-docs] [--no-projects]
set -uo pipefail

LEARN_HOME="${LEARN_HOME:-$HOME/learn}"
WITH_DOCS=1
WITH_PROJECTS=1
for arg in "$@"; do
  case "$arg" in
    --no-docs) WITH_DOCS=0 ;;
    --no-projects) WITH_PROJECTS=0 ;;
    -h | --help) sed -n '2,11p' "$0"; exit 0 ;;
    *) echo "unknown option: $arg" >&2; exit 2 ;;
  esac
done

FAILURES=()
section() { printf '\n\033[1;38;2;120;220;232m── %s\033[0m\n' "$1"; }
ok() { printf '  \033[38;2;169;220;118m✓\033[0m %s\n' "$1"; }
skip() { printf '  \033[38;2;114;112;114m· %s\033[0m\n' "$1"; }
fail() { printf '  \033[38;2;255;97;136m✗\033[0m %s\n' "$1"; FAILURES+=("$1"); }

ONLINE=0
if curl -fsS --max-time 5 -o /dev/null https://github.com 2>/dev/null; then ONLINE=1; fi
IS_MAC=0
[[ "$(uname -s)" == "Darwin" ]] && IS_MAC=1

# Shallow clone at a pinned commit (sparse when paths follow the pin), or move an existing clone
# to a new pin. A clone you've changed (edited files, or commits of your own) is left alone.
# To bump a pin: git ls-remote <url> HEAD
sync_repo() {
  local url="$1" dir="$2" rev="$3" name
  shift 3
  name="$(basename "$dir")"
  if [[ -d "$dir/.git" ]]; then
    if [[ "$(git -C "$dir" rev-parse -q --verify HEAD)" == "$rev" ]]; then
      skip "have $name"
    elif ! pristine "$dir"; then
      skip "keeping $name: it has your changes"
    elif ((!ONLINE)); then
      skip "offline: keeping $name"
    elif checkout_pin "$dir" "$rev"; then
      ok "updated $name"
    else
      fail "update $url"
    fi
    return
  fi
  if ((!ONLINE)); then
    fail "offline and $dir is missing ($url)"
    return
  fi
  mkdir -p "$(dirname "$dir")"
  if (($# > 0)); then
    git clone -q --depth 1 --filter=blob:none --sparse "$url" "$dir" && git -C "$dir" sparse-checkout set "$@"
  else
    git clone -q --depth 1 "$url" "$dir"
  fi && checkout_pin "$dir" "$rev" && ok "cloned $name" || fail "clone $url"
}

# No edits to tracked files and no commits of yours (in a depth-1 clone, HEAD is a shallow root).
pristine() {
  [[ -z "$(git -C "$1" status --porcelain --untracked-files=no)" ]] &&
    grep -qxF "$(git -C "$1" rev-parse HEAD)" "$(git -C "$1" rev-parse --absolute-git-dir)/shallow" 2>/dev/null
}

checkout_pin() {
  [[ "$(git -C "$1" rev-parse HEAD)" == "$2" ]] && return 0
  git -C "$1" fetch -q --depth 1 origin "$2" && git -C "$1" checkout -q --detach FETCH_HEAD
}

# Download a URL to a file unless it already exists.
fetch_file() {
  local url="$1" dest="$2"
  if [[ -s "$dest" ]]; then
    skip "have $(basename "$dest")"
    return 0
  fi
  if ((!ONLINE)); then
    fail "offline and missing $(basename "$dest")"
    return 1
  fi
  mkdir -p "$(dirname "$dest")"
  if curl -fL --retry 3 --silent --show-error -o "$dest.part" "$url"; then
    mv "$dest.part" "$dest"
    ok "downloaded $(basename "$dest")"
  else
    rm -f "$dest.part"
    fail "download $url"
    return 1
  fi
}

brew_install() {
  local pkg="$1"
  command -v brew >/dev/null || return 1
  for _ in $(seq 1 90); do
    local out
    out="$(brew install "$pkg" 2>&1)" && return 0
    if grep -q "has already locked" <<<"$out"; then sleep 10; else echo "$out" | tail -3; return 1; fi
  done
  return 1
}

section "toolchain"
if command -v cmake >/dev/null; then
  ok "cmake $(cmake --version | head -1 | awk '{print $3}')"
elif ((IS_MAC)) && ((ONLINE)); then
  brew_install cmake && ok "installed cmake" || fail "brew install cmake"
else
  fail "cmake missing (macOS: brew install cmake · Arch: sudo pacman -S cmake)"
fi
for tool in python3 make git; do
  command -v "$tool" >/dev/null && ok "$tool" || fail "$tool missing"
done
if ((IS_MAC)); then
  command -v swift >/dev/null && ok "swift ($(swift --version 2>&1 | head -1 | sed 's/.*version \([0-9.]*\).*/\1/'))" || fail "swift missing (install Xcode)"
fi

section "python venv"
VENV="$LEARN_HOME/.venv"
if [[ -x "$VENV/bin/python" ]] && "$VENV/bin/python" -c 'import pytest' 2>/dev/null; then
  ok "venv ready ($("$VENV/bin/python" --version))"
elif ((ONLINE)); then
  if command -v uv >/dev/null; then
    uv venv -q "$VENV" && uv pip install -q --python "$VENV/bin/python" pytest
  else
    python3 -m venv "$VENV" && "$VENV/bin/pip" install -q pytest
  fi && ok "venv created with pytest" || fail "python venv"
else
  fail "offline and no venv with pytest"
fi

section "exercism tracks"
for pin in python:479f11b44b02337b0413e805b948491c2179615a c:1675b02c310198e9752e516ee1a2294b76a37f84 \
  cpp:3ad5d0e99c0972b7e429d30c9539954207238b37 swift:a0e8e9ef7453d4010e123c6af8e1fb296eafad43 \
  rust:0a9b22d667da5a226bf480b0152ae29dfba99545; do
  sync_repo "https://github.com/exercism/${pin%%:*}" "$LEARN_HOME/vendor/${pin%%:*}" "${pin#*:}"
done

write_flags() { [[ -f "$1/compile_flags.txt" ]] || printf '%s\n' "${@:2}" >"$1/compile_flags.txt"; }

if ((WITH_PROJECTS)); then
  section "example projects"
  P="$LEARN_HOME/projects"
  sync_repo https://github.com/antirez/kilo "$P/c/kilo" 323d93b29bd89a2cb446de90c4ed4fea1764176e
  sync_repo https://github.com/rui314/chibicc "$P/c/chibicc" 90d1f7f199cc55b13c7fdb5839d1409806633fdb
  sync_repo https://github.com/p-ranav/argparse "$P/cpp/argparse" 7d093f8e1201db2dded2eee94de77665698ee9dc
  sync_repo https://github.com/rigtorp/SPSCQueue "$P/cpp/SPSCQueue" cd49c7cb430fbb298d981c1793c0d46348c4c9d5
  sync_repo https://github.com/karpathy/micrograd "$P/python/micrograd" 7bc720e951fe422b8f8814aa5aa1b64121d26b4c
  sync_repo https://github.com/hynek/stamina "$P/python/stamina" 8f399b7bd620cfa7e0f5928cb243c025a0f10451
  sync_repo https://github.com/apple/swift-argument-parser "$P/swift/swift-argument-parser" d225b6fe8aed45478d1e36e770bf269c5d48d3a9
  sync_repo https://github.com/YosysHQ/picorv32 "$P/sv/picorv32" ef203c2b0a3fb793280f5114941416c425c5b461

  # Editor support so grd/grr/K work immediately in each project.
  [[ -d "$P/c/kilo" ]] && write_flags "$P/c/kilo" -std=c99 -Wall -Wextra -D_DEFAULT_SOURCE -D_BSD_SOURCE
  [[ -d "$P/c/chibicc" ]] && write_flags "$P/c/chibicc" -std=c11 -Wall
  for proj in argparse SPSCQueue; do
    dir="$P/cpp/$proj"
    if [[ -d "$dir" ]] && command -v cmake >/dev/null; then
      cmake -S "$dir" -B "$dir/build" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DCMAKE_BUILD_TYPE=Debug \
        -DARGPARSE_BUILD_TESTS=ON -DARGPARSE_BUILD_SAMPLES=ON >/dev/null 2>&1 &&
        ln -sf build/compile_commands.json "$dir/compile_commands.json" &&
        ok "$proj: compile_commands.json" || fail "$proj: cmake configure"
    fi
  done
  for proj in micrograd stamina; do
    dir="$P/python/$proj"
    [[ -d "$dir" && ! -f "$dir/pyrightconfig.json" ]] &&
      printf '{\n  "venvPath": "%s",\n  "venv": ".venv"\n}\n' "$LEARN_HOME" >"$dir/pyrightconfig.json"
  done
  if [[ -d "$P/python/stamina" && -x "$VENV/bin/python" ]] && ((ONLINE)); then
    if command -v uv >/dev/null; then
      uv pip install -q --python "$VENV/bin/python" -e "$P/python/stamina"
    else
      "$VENV/bin/pip" install -q -e "$P/python/stamina"
    fi && ok "stamina installed into the learn venv (imports resolve)" || fail "install stamina deps"
  fi
  if ((IS_MAC)) && [[ -d "$P/swift/swift-argument-parser" ]]; then
    (cd "$P/swift/swift-argument-parser" && swift build -q >/dev/null 2>&1) &&
      ok "swift-argument-parser: built (sourcekit-lsp index ready)" || fail "swift-argument-parser: swift build"
  fi
fi

if ((WITH_DOCS)); then
  section "offline docs"
  D="$LEARN_HOME/docs"
  DL="$D/.downloads"
  mkdir -p "$DL"

  # C & C++: cppreference offline HTML book (content CC-BY-SA/GFDL; packaging GPL-3)
  CPPREF=20250209
  if [[ ! -f "$D/cppreference/reference/en/index.html" ]]; then
    fetch_file "https://github.com/PeterFeicht/cppreference-doc/releases/download/v$CPPREF/html-book-$CPPREF.zip" \
      "$DL/cppreference-html-book-$CPPREF.zip" &&
      rm -rf "$D/cppreference" && mkdir -p "$D/cppreference" &&
      unzip -q "$DL/cppreference-html-book-$CPPREF.zip" -d "$D/cppreference" && ok "cppreference unpacked"
  else
    skip "have cppreference"
  fi

  # Python docs matching the learn venv's version
  if [[ -x "$VENV/bin/python" ]]; then
    PYV="$("$VENV/bin/python" -c 'import sys; print(f"{sys.version_info[0]}.{sys.version_info[1]}")')"
    if [[ ! -f "$D/python/python-$PYV-docs-html/index.html" ]]; then
      fetch_file "https://docs.python.org/$PYV/archives/python-$PYV-docs-html.zip" "$DL/python-$PYV-docs-html.zip" &&
        mkdir -p "$D/python" && unzip -q -o "$DL/python-$PYV-docs-html.zip" -d "$D/python" && ok "python $PYV docs unpacked"
    else
      skip "have python $PYV docs"
    fi
  fi

  # Haskell: GHC's base haddock (brew's ghc ships none) + Learn You a Haskell (CC BY-NC-SA, personal use)
  if command -v ghc >/dev/null; then
    GHCV="$(ghc --numeric-version)"
    BASEV="$(ghc-pkg list --global --simple-output 2>/dev/null | tr ' ' '\n' | grep -E '^base-[0-9]' | head -1)"
    if [[ -n "$BASEV" && ! -f "$D/haskell/$BASEV-docs/index.html" ]]; then
      fetch_file "https://downloads.haskell.org/ghc/$GHCV/hackage_docs/$BASEV-docs.tar.gz" "$DL/$BASEV-docs.tar.gz" &&
        mkdir -p "$D/haskell" && tar -xzf "$DL/$BASEV-docs.tar.gz" -C "$D/haskell" && ok "$BASEV haddock unpacked"
    else
      skip "have ${BASEV:-base} haddock"
    fi
  else
    skip "ghc not installed: skipping base haddock"
  fi
  sync_repo https://github.com/learnyouahaskell/learnyouahaskell.github.io "$D/haskell/lyah" 1e60d107cceadccf2a2d4b6cf67e94fc77c61e19 source_md static

  # Swift: The Swift Programming Language (Apache-2.0), Markdown sources: read in nvim
  sync_repo https://github.com/swiftlang/swift-book "$D/swift/swift-book" 16a2a4caa408c86fc85bde1e1dfff4745b6e454c TSPL.docc

  # SystemVerilog/Verilog: Verilator's user guide (reStructuredText, readable as text)
  sync_repo https://github.com/verilator/verilator "$D/sv/verilator" b3a6da96bee52fc7eebc39c9198c326a613bc1bc docs/guide

  rm -rf "$DL" # archives are unpacked; the extracted index files above are the idempotency markers
fi

section "tldr"
if command -v tldr >/dev/null; then
  if ((ONLINE)); then
    tldr --update >/dev/null 2>&1 && ok "tldr cache updated" || fail "tldr --update"
  else
    skip "offline: tldr uses its existing cache"
  fi
else
  skip "tldr not installed"
fi

section "summary"
for dir in vendor projects docs .venv; do
  [[ -d "$LEARN_HOME/$dir" ]] && printf '  %-9s %s\n' "$dir" "$(du -sh "$LEARN_HOME/$dir" 2>/dev/null | cut -f1)"
done
((ONLINE)) || echo "  (offline run: network steps were skipped)"
if ((${#FAILURES[@]})); then
  printf '\n  %d problem(s):\n' "${#FAILURES[@]}"
  printf '   - %s\n' "${FAILURES[@]}"
  exit 1
fi
echo "  all set. Try: learn"
