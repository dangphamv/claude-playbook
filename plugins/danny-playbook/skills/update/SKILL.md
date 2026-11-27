---
name: update
description: Bring new or missing danny-playbook files into an already set-up project without overwriting local edits, and show which kit templates changed upstream.
disable-model-invocation: true
---
Kit root: ${CLAUDE_PLUGIN_ROOT}
Config: !`cat .claude/playbook.json 2>/dev/null || echo "not set up — run /danny-playbook:init"; true`

1. If not set up, tell the user to run /danny-playbook:init and STOP.
2. For each file under `${CLAUDE_PLUGIN_ROOT}/templates/claude/` that already exists in `.claude/`, diff kit vs project and list the ones that differ (the project copy may have intentional local edits).
3. Run `bash "${CLAUDE_PLUGIN_ROOT}/scripts/install-kit.sh" "$PWD"` to add missing files (never overwrites) and refresh the git exclude block.
4. CHECKPOINT — for files that differ, AskUserQuestion (multi-select): which to replace with the kit version. STOP until answered; replace only those.
5. Report what was added/replaced. Remind: restart the session to load changed hooks/skills.
