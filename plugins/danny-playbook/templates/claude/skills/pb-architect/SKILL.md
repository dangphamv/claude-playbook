---
name: pb-architect
description: Phase 4 — ADRs for each significant decision (2-3 options, trade-offs) and a dependency-ordered plan; nothing is built until the user approves.
disable-model-invocation: true
argument-hint: "[decision or area]"
---
Focus: $ARGUMENTS
Config: !`cat .claude/playbook.json; true`
Existing ADRs: !`d=$(jq -r .docs.dir .claude/playbook.json); ls "$d/adr" 2>/dev/null || echo "(none)"; true`

Tip for the user: `/model opusplan` and plan mode (Shift+Tab) fit this phase.

1. From stories + contract, list the decisions that need an ADR (data store, locking/concurrency, auth, queue vs cron, hosting, build/deploy, config & secrets, observability, migration strategy, local dev). Also note foundation items often forgotten: docker compose for local deps, env schema validation, structured logs + request id, health check, threat model for auth/payments/uploads.
2. Ask the pb-architect subagent for options per decision. CHECKPOINT 1 — for each decision AskUserQuestion with the options and your recommendation. STOP until answered.
3. Write `<docs.dir>/adr/NNNN-<slug>.md` from the template (status, context, options table, decision, consequences).
4. Write `<docs.dir>/plan.md`: phase 0 scaffold, then parallel tracks; each task = story ID, files, tests, DoD.
5. CHECKPOINT 2 — tell the user they can edit the plan (Ctrl+G in plan mode) and ask approve / change. STOP until approved.
6. If approved and the project has no scaffold yet, offer to do phase-0 scaffold (monorepo, CI, local deps) as its own commit(s); ask first.
7. Fill `commands.*` in .claude/playbook.json if they are now known. Log row; phase "4-architect".
8. Say: "Next: /pb-feature <first story ID>". STOP.
