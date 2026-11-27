#!/usr/bin/env bash
# SessionStart: stdout goes into Claude's context — where we are, what changed, what is next.
cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || exit 0
cfg=.claude/playbook.json
[ -f "$cfg" ] || exit 0
dir=$(jq -r '.docs.dir' "$cfg")
echo "danny-playbook: mode=$(jq -r '.mode // "guided"' "$cfg"), phase=$(jq -r '.phase' "$cfg"), docs=$dir ($(jq -r '.docs.mode' "$cfg"))"
echo "branch: $(git branch --show-current 2>/dev/null)"
git status --short 2>/dev/null | head -15
if [ -f "$dir/stories.md" ]; then
  open=$(grep -cE '^#+ *\[ \]' "$dir/stories.md" || true)
  echo "open stories: $open"; grep -m5 -E '^#+ *\[ \]' "$dir/stories.md" || true
fi
[ -f "$dir/playbook-log.md" ] && { echo "last decisions:"; grep -E '^\|' "$dir/playbook-log.md" | tail -3; }
echo "next: run /pb-status to see the recommended next step."
