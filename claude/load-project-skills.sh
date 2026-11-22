#!/usr/bin/env bash
# SessionStart hook: if .claude/SKILLS.md exists in CWD or any ancestor,
# inject its contents into the model's context. Lets a project ship its own
# always-on guidance without a global rule.

# Needs jq >= 1.6 (--rawfile); on boxes without it the hook is a no-op.
command -v jq >/dev/null 2>&1 || exit 0

d=$PWD
while [ "$d" != "/" ]; do
  if [ -f "$d/.claude/SKILLS.md" ]; then
    jq -Rsn \
      --rawfile content "$d/.claude/SKILLS.md" \
      --arg path "$d/.claude/SKILLS.md" \
      '{
        systemMessage: ("Loaded project skills from " + $path),
        hookSpecificOutput: {
          hookEventName: "SessionStart",
          additionalContext: ("# Project Skills (auto-loaded from " + $path + ")\n\n" + $content)
        }
      }'
    exit 0
  fi
  d=$(dirname "$d")
done
exit 0
