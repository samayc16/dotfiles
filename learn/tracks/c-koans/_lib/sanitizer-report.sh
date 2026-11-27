#!/usr/bin/env bash
# Print a koan binary's stderr for a beginner: sanitizer reports without the shadow-byte dump and
# workspace paths, then one line saying what went wrong in plain words.
# Usage: sanitizer-report.sh <stderr file> <exit status>   (shared by c-koans and cpp-koans)
set -uo pipefail
log="$1" status="$2"
[[ -s "$log" ]] || { ((status < 128)) || echo "✗ crashed (signal $((status - 128))) before the checks finished"; exit 0; }

strip_paths() {
  local sed_args=()
  for dir in "${LEARN_WORKSPACE:-}" "${LEARN_EXERCISE_DIR:-}"; do
    [[ -n "$dir" ]] && sed_args+=(-e "s#$dir/##g")
  done
  if ((${#sed_args[@]})); then sed "${sed_args[@]}"; else cat; fi
}

# Drop the shadow-byte block, ASan's unwinder hint and the ==pid== banners.
awk '
  /^Shadow bytes around the buggy address:/ { skip = 1; next }
  skip && /^(=>)? *0x[0-9a-f]+:/ { next }
  { skip = 0 }
  /^HINT: this may be a false positive/ { hint = 1; next }
  hint && /^ +\(longjmp/ { hint = 0; next }
  { hint = 0 }
  /^==[0-9]+==ABORTING/ || /^=+$/ { next }
  { print }
' "$log" | strip_paths

kind=$(grep -m1 -oE 'AddressSanitizer: [a-z-]+( on unknown address 0x0+ )?' "$log" | sed 's/AddressSanitizer: //')
where=$(grep -m1 -E '^SUMMARY: ' "$log" | strip_paths | sed -E 's/^SUMMARY: [A-Za-z]+: [a-z-]+ //; s/ +$//')
ub=$(grep -m1 -oE 'runtime error: .*' "$log" | sed 's/runtime error: //')
case "$kind" in
  *buffer-overflow*) what="read or wrote past the end of an array or string (a missing '\\0'?)" ;;
  heap-use-after-free*) what="used memory after free()ing it" ;;
  double-free* | attempting*) what="freed the same memory twice" ;;
  stack-use-after-*) what="used a local variable after its function or block ended" ;;
  "SEGV on unknown address 0"*) what="dereferenced a null pointer" ;;
  SEGV*) what="followed a pointer to memory it doesn't own" ;;
  "") what=${ub:+$ub (undefined behaviour)} ;;
  *) what="memory error: $kind" ;;
esac
if [[ -n "${what:-}" ]]; then
  echo
  echo "✗ crashed${where:+ at $where}: $what"
  echo "  The sanitizer stopped the run there, so the checks after it didn't run."
elif ((status >= 128)); then
  echo "✗ crashed (signal $((status - 128))) before the checks finished"
fi
exit 0
