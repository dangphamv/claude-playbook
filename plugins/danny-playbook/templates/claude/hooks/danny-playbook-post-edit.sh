#!/usr/bin/env bash
# PostToolUse(Edit|Write): run the project's format command on the edited file (commands.format in .claude/playbook.json).
# The command receives the file path as its last argument. A failure is sent back to Claude (exit 2) to fix.
cfg="$CLAUDE_PROJECT_DIR/.claude/playbook.json"
[ -f "$cfg" ] || exit 0
cmd=$(jq -r '.commands.format // empty' "$cfg")
[ -n "$cmd" ] || exit 0
f=$(jq -r '.tool_input.file_path // empty')
[ -f "$f" ] || exit 0
case "$f" in */node_modules/*|*/.git/*|*/dist/*|*/.next/*) exit 0 ;; esac
cd "$CLAUDE_PROJECT_DIR" || exit 0
. "$CLAUDE_PROJECT_DIR/.claude/hooks/danny-playbook-lib.sh"
runnable "$cmd" || exit 0   # toolchain not set up yet (e.g. before scaffolding)
out=$(eval "$cmd \"\$f\"" 2>&1) || { echo "format/lint failed for $f:" >&2; echo "$out" | tail -40 >&2; exit 2; }
exit 0
