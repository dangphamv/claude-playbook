#!/usr/bin/env bash
# Stop: run commands.typecheck before Claude ends its turn; on failure Claude must keep fixing (exit 2).
# stop_hook_active guards against an endless loop when the check cannot pass.
input=$(cat)
[ "$(echo "$input" | jq -r '.stop_hook_active // false')" = true ] && exit 0
cfg="$CLAUDE_PROJECT_DIR/.claude/playbook.json"
[ -f "$cfg" ] || exit 0
cmd=$(jq -r '.commands.typecheck // empty' "$cfg")
[ -n "$cmd" ] || exit 0
cd "$CLAUDE_PROJECT_DIR" || exit 0
# Nothing changed since the last commit → nothing to check.
[ -z "$(git status --porcelain 2>/dev/null)" ] && exit 0
out=$(eval "$cmd" 2>&1) || { echo "typecheck failed ($cmd):" >&2; echo "$out" | tail -60 >&2; exit 2; }
exit 0
