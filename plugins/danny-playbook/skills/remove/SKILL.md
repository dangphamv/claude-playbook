---
name: remove
description: Remove the danny-playbook kit files from this project (only files the kit created, as recorded in .claude/playbook.manifest) and its git exclude block. Docs are never deleted.
disable-model-invocation: true
---
Manifest: !`cat .claude/playbook.manifest 2>/dev/null || echo "(none)"; true`

1. Show the exact list of files that will be deleted (from the manifest). Docs in the docs directory are NOT deleted.
2. CHECKPOINT — ask for explicit confirmation; files that were edited locally will be lost. STOP until the user says yes.
3. Run `bash "${CLAUDE_PLUGIN_ROOT}/scripts/install-kit.sh" "$PWD" --remove` and show the output.
4. Tell the user to remove the danny-playbook hook entries from `.claude/settings.local.json` if they no longer want them (show the entries), and offer to do it.
