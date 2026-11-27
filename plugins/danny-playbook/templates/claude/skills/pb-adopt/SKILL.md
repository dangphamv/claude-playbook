---
name: pb-adopt
description: Phase 0 for an existing codebase (brownfield) — map architecture, data flow and danger zones before changing anything, then fill CLAUDE.local.md.
disable-model-invocation: true
allowed-tools: Bash(.claude/playbook/bin/*)
argument-hint: "[area to focus on]"
---
Mode: !`.claude/playbook/bin/pb-context mode`
If the mode is **auto**: at each CHECKPOINT choose the recommended option yourself, log it as `auto: <decision>` with the reason, and continue instead of stopping (outward or irreversible actions — push, PR, deploy, prod migration, publish, credentials — still require asking). At the end, instead of STOP, say which phase comes next; /pb-auto chains them.
Focus: $ARGUMENTS
Config: !`.claude/playbook/bin/pb-context config`

Goal: understand before touching. Do not modify source code in this skill.

1. Use the built-in Explore agent (2-3 in parallel, different angles: entry points & routing; data model & persistence; build/test/deploy) to map the repo. Read the key files they return.
2. Write `<docs.dir>/architecture.md`: components, data flow (mermaid), external services, how to run/test locally, and a **danger zones** table (untested code, complex modules, shared state, migrations, money/auth paths) with file paths.
3. Detect real commands (package.json scripts, Makefile, CI workflow) and propose values for `commands.format|lint|typecheck|test|build` in .claude/playbook.json.
4. CHECKPOINT — AskUserQuestion: confirm the commands, which danger zones matter for upcoming work, and whether to add characterization tests around them first. STOP until answered.
5. Apply the answers: set them with `.claude/playbook/bin/pb-config set commands.<name> "<cmd>"`, update the Stack/Commands sections of CLAUDE.local.md. If characterization tests were approved, write them (they must pass on current code) and commit as `test: characterize <area>` after the user confirms.
6. Append to `<docs.dir>/playbook-log.md`: `| <date> | 0-adopt | <decision> | <why> | <evidence> |`. run `.claude/playbook/bin/pb-config set phase 0-adopted`.
7. Tell the user the next step (/pb-status or the phase that matches their task) and STOP.
