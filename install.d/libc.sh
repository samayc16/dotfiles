#!/usr/bin/env bash
# What this Linux system's C library can run, for install.d/mise.sh. Sourced, never executed; no
# side effects. Safe under `set -euo pipefail`. Bash 3.2 compatible. Needs version_ge (lib.sh).

NVIM_GLIBC_FLOOR=2.34 # Neovim's usual Linux build
NODE_GLIBC_FLOOR=2.28 # Node's official Linux build, which also needs libatomic.so.1
GIT_FLOOR=2.19        # lazy.nvim's partial clones (--filter); the installer's `git -C` needs 1.8.5

# "2.28", or empty on musl, where getconf has no GNU_LIBC_VERSION
# (`|| true`: under pipefail the failing getconf would otherwise end the caller)
glibc_version() { getconf GNU_LIBC_VERSION 2>/dev/null | awk '{ print $2 }' || true; }

# (no `| grep -q`: under pipefail, grep quitting at the first match can fail the pipeline)
has_libatomic() { [[ "$({ ldconfig -p || /sbin/ldconfig -p; } 2>/dev/null)" == *libatomic.so.1* ]]; }

# Neovim's usual build can't run here (glibc too old), but its glibc 2.17 build can.
wants_old_glibc_nvim() {
  local glibc
  glibc="$(glibc_version)"
  [[ -n "$glibc" ]] && ! version_ge "$glibc" "$NVIM_GLIBC_FLOOR"
}

# Node's official build can't run here (no libatomic.so.1, or glibc too old), and this is x86-64,
# where the Node.js project publishes a glibc 2.17 build with those built in.
wants_glibc217_node() {
  local glibc
  glibc="$(glibc_version)"
  [[ -n "$glibc" && "$(uname -m)" == x86_64 ]] || return 1
  ! has_libatomic || ! version_ge "$glibc" "$NODE_GLIBC_FLOOR"
}

# "1.8.3.1" for the git on PATH, or empty without one (`|| true`: as for glibc_version)
git_version() { git --version 2>/dev/null | awk '{ print $3 }' || true; }

# A git new enough for everything here (CentOS 7's 1.8.3 isn't; neither is no git at all).
git_ok() {
  local version
  version="$(git_version)"
  [[ -n "$version" ]] && version_ge "$version" "$GIT_FLOOR"
}

# A python3 ≥ 3.9 that can make a venv with pip in it (Debian's lacks ensurepip without python3-venv).
python_ok() { command -v python3 >/dev/null 2>&1 && python3 -c 'import sys, ensurepip, venv; sys.exit(sys.version_info < (3, 9))' >/dev/null 2>&1; }
