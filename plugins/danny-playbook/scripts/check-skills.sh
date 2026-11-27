#!/usr/bin/env bash
# Every !`command` in a skill must exit 0 — a non-zero exit makes Claude Code abort the skill.
# Runs each one in an empty, non-git directory (the worst case) and in a git repo with no commits.
set -uo pipefail
KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fail=0
for mode in empty git; do
  d="$(mktemp -d)"; [ "$mode" = git ] && git -C "$d" init -q
  while IFS= read -r line; do
    file="${line%%:*}"; cmd="${line#*:}"
    cmd="${cmd//\$\{CLAUDE_PLUGIN_ROOT\}/$KIT}"
    if ! (cd "$d" && bash -c "$cmd" >/dev/null 2>&1); then echo "FAIL ($mode) ${file#$KIT/}: $cmd"; fail=1; fi
  done < <(grep -rHo '!`[^`]*`' "$KIT/skills" "$KIT/templates/claude/skills" | sed -E 's/:!`(.*)`$/:\1/')
  rm -rf "$d"
done
[ $fail = 0 ] && echo "all skill shell commands exit 0"
exit $fail
