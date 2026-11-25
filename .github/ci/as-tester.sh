#!/usr/bin/env bash
# Run a command as the CI's unprivileged user `tester`: runuser where util-linux has it, else su
# (Alpine's busybox).
set -euo pipefail
if command -v runuser >/dev/null 2>&1; then
  exec runuser -u tester -- "$@"
fi
exec su -s /bin/sh -c "$(printf '%q ' "$@")" tester
