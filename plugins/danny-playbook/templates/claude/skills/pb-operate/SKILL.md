---
name: pb-operate
description: Phase 8 — after release: monitoring, scheduled routines (dependency bumps, error triage, health checks), KPI dashboard, feedback loop back to the PRD.
disable-model-invocation: true
allowed-tools: Bash(.claude/playbook/bin/*)
---
Mode: !`.claude/playbook/bin/pb-context mode`
If the mode is **auto**: at each CHECKPOINT choose the recommended option yourself, log it as `auto: <decision>` with the reason, and continue instead of stopping (outward or irreversible actions — push, PR, deploy, prod migration, publish, credentials — still require asking). At the end, instead of STOP, say which phase comes next; /pb-auto chains them.
Config: !`.claude/playbook/bin/pb-context config`

1. Propose an operations set and CHECKPOINT with AskUserQuestion (multi-select):
   - daily health + error triage (cloud routine via `/schedule`, opens an issue with analysis),
   - weekly dependency bump PR with tests,
   - `/loop` watcher for a deploy or CI run,
   - KPI dashboard from the PRD success metrics (published as an artifact),
   - uptime alert / log alert setup.
   STOP until chosen.
2. Set up only the chosen ones. Show each routine's prompt and schedule before creating it.
3. Add an "Operations" section to `<docs.dir>/runbook.md` listing what runs, where, and how to stop it.
4. Explain the loop: user feedback → update prd.md → new stories (/pb-ba) → next cycle.
5. Log row; `.claude/playbook/bin/pb-config set phase 8-operate`. STOP.
