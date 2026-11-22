#!/usr/bin/env bash
# Shared checker for the systemverilog track. Each exercise's check.sh sets:
#
#   SOURCES="a.sv b.sv"   learner files in the workspace (compiled in this order)
#   SUPPORT="x.sv"        read-only helper files in the exercise dir, compiled BEFORE sources
#   TB="tb.sv"            read-only testbench(es) in the exercise dir (default tb.sv)
#   TOP=tb                top module
#   RUNS="default"        simulation runs; each gets +MODE=<run>
#   EXPECT_<run>=<text>   that run must FAIL and print <text> (e.g. an assertion label);
#                         runs without EXPECT_ must print "ALL TESTS PASSED"
#   NEEDS_Z3=1            constrained randomization needs the z3 SMT solver
#   COMPILE_HINT=<text>   extra advice printed when the build fails
#
# Contract (learn CLI): cwd = workspace, LEARN_EXERCISE_DIR = exercise dir in repo,
# LEARN_WORKSPACE = workspace. Exit 0 = pass.
# Set WAVES=1 to also dump wave.vcd into the workspace (open it with: surfer wave.vcd).
set -u

EX=${LEARN_EXERCISE_DIR:?LEARN_EXERCISE_DIR is not set - run this through: learn check}
WS=${LEARN_WORKSPACE:-$PWD}
LIB="$EX/../_lib"
TOP=${TOP:-tb}
TB=${TB:-tb.sv}
RUNS=${RUNS:-default}
TIMEOUT=${TIMEOUT:-60}

if [ -t 1 ]; then G=$'\033[32m' R=$'\033[31m' Y=$'\033[33m' D=$'\033[2m' N=$'\033[0m'; else G= R= Y= D= N=; fi
fail() { printf '%s✗ %s%s\n' "$R" "$*" "$N"; exit 1; }

command -v verilator >/dev/null || fail "verilator not found (brew install verilator / pacman -S verilator)"
if [ -n "${NEEDS_Z3:-}" ] && ! command -v z3 >/dev/null; then
  fail "This exercise uses constrained randomization, which needs the z3 solver (brew install z3 / pacman -S z3)"
fi

files=("$LIB/tbu.sv")
for f in ${SUPPORT:-}; do files+=("$EX/$f"); done
for f in ${SOURCES:?SOURCES not set}; do
  [ -f "$WS/$f" ] || fail "Missing $f in $WS"
  files+=("$WS/$f")
done
for f in $TB; do files+=("$EX/$f"); done

build=$(mktemp -d "${TMPDIR:-/tmp}/learn-sv.XXXXXX")
trap 'rm -rf "$build"' EXIT

args=(--binary --timing --assert -j 0 -Wall -Wno-fatal --top-module "$TOP" -Mdir "$build/obj")
if [ -n "${WAVES:-}" ]; then args+=(--trace +define+DUMP); fi

printf '%sbuilding with verilator...%s\n' "$D" "$N"
if ! verilator "${args[@]}" "${files[@]}" >"$build/build.log" 2>&1; then
  printf '%s✗ Does not compile yet:%s\n' "$R" "$N"
  grep -E -A3 '^%Error' "$build/build.log" | grep -v -E '^%Error: Exiting due to' | head -30
  [ -n "${COMPILE_HINT:-}" ] && printf '%sHint: %s%s\n' "$Y" "$COMPILE_HINT" "$N"
  exit 1
fi

# Lint warnings in YOUR files are tips, not failures.
mine=$(grep -E '^%Warning' "$build/build.log" | grep -F "$WS/" || true)
if [ -n "$mine" ]; then
  n=$(printf '%s\n' "$mine" | wc -l | tr -d ' ')
  printf '%sLint (%s warning%s in your code, not fatal):%s\n' "$Y" "$n" "$([ "$n" = 1 ] || echo s)" "$N"
  printf '%s\n' "$mine" | sed -e "s#$WS/##g" -e 's/^/  /' | head -6
fi

status=0
for run in $RUNS; do
  expect_var="EXPECT_$run"
  expect=${!expect_var:-}
  label=$([ "$run" = default ] && echo "simulation" || echo "run '$run'")
  (cd "$WS" && perl -e 'alarm shift; exec @ARGV or die "exec failed: $!\n"' "$TIMEOUT" \
    "$build/obj/V$TOP" "+MODE=$run") >"$build/run.log" 2>&1
  rc=$?
  if [ "$rc" -eq 142 ]; then
    printf '%s✗ %s timed out after %ss (a loop waiting on a clock edge that never comes?)%s\n' "$R" "$label" "$TIMEOUT" "$N"
    status=1
    continue
  fi
  if [ -z "$expect" ]; then
    if [ "$rc" -eq 0 ] && grep -q 'ALL TESTS PASSED' "$build/run.log"; then
      grep -E '^(PASS|ALL TESTS PASSED)' "$build/run.log" | sed "s/^/  $G/; s/\$/$N/"
    else
      printf '%s✗ %s failed:%s\n' "$R" "$label" "$N"
      grep -E 'PASS|FAIL|Error|Assertion|checks' "$build/run.log" | grep -v -E '^- ' | head -25
      status=1
    fi
  else
    if [ "$rc" -ne 0 ] && grep -qF -- "$expect" "$build/run.log"; then
      printf '  %sPASS: %s - %s fired as it should%s\n' "$G" "$run" "$expect" "$N"
    else
      printf '%s✗ %s: bad stimulus was injected, but %s did not fire%s\n' "$R" "$run" "$expect" "$N"
      grep -E 'Assertion|Error' "$build/run.log" | head -5
      status=1
    fi
  fi
done

if [ -n "${WAVES:-}" ] && [ -f "$WS/wave.vcd" ]; then
  printf '%swaveform: %s/wave.vcd  (open with: surfer wave.vcd)%s\n' "$D" "$WS" "$N"
fi
[ "$status" -eq 0 ] && printf '%s✓ All checks passed!%s\n' "$G" "$N"
exit "$status"
