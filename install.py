#!/usr/bin/env python3
"""Dotfiles installer. Run ./install.sh (it finds or fetches a suitable Python first)."""

import sys

if sys.version_info < (3, 8):
    sys.exit("install.py needs Python ≥ 3.8 — run ./install.sh, which can fetch one.")

from installer.cli import main  # noqa: E402  (version check must come first)

if __name__ == "__main__":
    sys.exit(main())
