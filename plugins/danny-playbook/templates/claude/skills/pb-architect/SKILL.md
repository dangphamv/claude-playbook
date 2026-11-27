---
name: pb-architect
description: Phase 4 — ADRs for each significant decision (2-3 options, trade-offs) and a dependency-ordered plan; nothing is built until the user approves.
disable-model-invocation: true
allowed-tools: Bash(.claude/playbook/bin/*)
argument-hint: "[decision or area]"
---
Mode: !`.claude/playbook/bin/pb-context mode`
If the mode is **auto**: at each CHECKPOINT choose the recommended option yourself, log it as `auto: <decision>` with the reason, and continue instead of stopping (outward or irreversible actions — push, PR, deploy, prod migration, publish, credentials — still require asking). At the end, instead of STOP, say which phase comes next; /pb-auto chains them.
Focus: $ARGUMENTS
Config: !`.claude/playbook/bin/pb-context config`
Existing ADRs: !`.claude/playbook/bin/pb-context adr`

Tip for the user: `/model opusplan` and plan mode (Shift+Tab) fit this phase.

1. From stories + contract, list the decisions that need an ADR (data store, locking/concurrency, auth, queue vs cron, hosting, build/deploy, config & secrets, observability, migration strategy, local dev). Also note foundation items often forgotten: docker compose for local deps, env schema validation, structured logs + request id, health check, threat model for auth/payments/uploads.
2. Ask the pb-architect subagent for options per decision. CHECKPOINT 1 — for each decision AskUserQuestion with the options and your recommendation. STOP until answered.
3. Write `<docs.dir>/adr/NNNN-<slug>.md` from the template (status, context, options table, decision, consequences).
4. Write `<docs.dir>/plan.md` using the writing-plans skill's structure: phase 0 scaffold, then parallel tracks; each task = story ID, files, tests, DoD.
5. CHECKPOINT 2 — tell the user they can edit the plan (Ctrl+G in plan mode) and ask approve / change. STOP until approved.
6. If approved and the project has no scaffold yet, offer to do phase-0 scaffold (monorepo, CI, local deps) as its own commit(s); ask first.
7. After scaffolding, fill the commands with `.claude/playbook/bin/pb-config set commands.<name> "<cmd>"` (format gets the file path as last argument) and run each once to prove it works — the hooks start enforcing them immediately. Log row; `.claude/playbook/bin/pb-config set phase 4-architect`.
8. Say: "Next: /pb-feature <first story ID>". STOP.
