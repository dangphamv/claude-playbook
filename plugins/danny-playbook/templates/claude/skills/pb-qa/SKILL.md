---
name: pb-qa
description: Phase 6 — verify, don't trust: test matrix, E2E, security and code review, non-functional checks; user decides what to fix.
disable-model-invocation: true
allowed-tools: Bash(.claude/playbook/bin/*)
argument-hint: "[scope: branch, story IDs, or release]"
---
Mode: !`.claude/playbook/bin/pb-context mode`
If the mode is **auto**: at each CHECKPOINT choose the recommended option yourself, log it as `auto: <decision>` with the reason, and continue instead of stopping (outward or irreversible actions — push, PR, deploy, prod migration, publish, credentials — still require asking). At the end, instead of STOP, say which phase comes next; /pb-auto chains them.
Scope: $ARGUMENTS
Config: !`.claude/playbook/bin/pb-context config`

1. Ask pb-qa-engineer for a test matrix from the AC (happy/edge/negative/permission/concurrency/bad data) mapped to story IDs → `<docs.dir>/test-plan.md`. Note which rows already have automated tests.
2. CHECKPOINT 1 — AskUserQuestion: which gaps to cover now, and which checks to run (E2E via Playwright MCP or Chrome, `/security-review`, `/code-review high`, load test with k6, Lighthouse/a11y, migration dry-run). STOP until answered.
3. Run the chosen checks (pb-security-reviewer for security, pb-ux-reviewer for UI/a11y, pb-db-reviewer for migrations). E2E: drive the real app, record failures with screenshots, then turn the flow into a committed spec. Each bug: reproduce with a failing test first, then fix.
4. CHECKPOINT 2 — present all findings ranked by severity; ask fix now / later / accept. STOP until answered. Record "later" items as stories or issues.
5. Write results (numbers, environment, date) into test-plan.md — measured facts only.
6. Log row; `.claude/playbook/bin/pb-config set phase 6-qa`. Say: "Next: /pb-release". STOP.
