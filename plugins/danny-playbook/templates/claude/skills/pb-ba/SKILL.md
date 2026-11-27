---
name: pb-ba
description: Phase 2 — PRD to testable user stories with Given/When/Then, data model, API contract, permission matrix and state machines.
disable-model-invocation: true
argument-hint: "[epic or PRD section]"
---
Scope: $ARGUMENTS
Config: !`cat .claude/playbook.json; true`

1. Read `<docs.dir>/prd.md`. Draft `<docs.dir>/stories.md` from the template: epic → story (As a / I want / So that), IDs like AUTH-01, size S/M/L, dependencies, a `### [ ] ID` heading per story, AC as Given/When/Then.
2. List business rules the PRD leaves open: concurrency (two users, same resource), cancellation/refund, deletion, permissions per role, time zones, money rounding, empty/error/loading/offline states.
3. CHECKPOINT 1 — AskUserQuestion for each open rule (recommended option first). STOP until answered; write answers into stories.md.
4. If there is an API or persistence: `<docs.dir>/data-model.md` (mermaid ERD, constraints, invariants) and `<docs.dir>/api-contract.yaml` (OpenAPI 3.1, error format, edge cases per endpoint). Add a permission matrix (role × action) and a state machine for the main entity.
5. Ask pb-product-manager to review stories against the PRD (missing stories, untestable AC, contradictions). Fix.
6. CHECKPOINT 2 — present the story list (ID, title, size) and ask approve / change. STOP until approved.
7. Log row `| <date> | 2-ba | ... | ... | stories.md, api-contract.yaml |`; set phase "2-ba"; ask before committing.
8. Optional: offer to create GitHub issues per story (`gh issue create`), only if the user says yes.
9. Say: "Next: /pb-ux (or /pb-architect for backend-only work)". STOP.
