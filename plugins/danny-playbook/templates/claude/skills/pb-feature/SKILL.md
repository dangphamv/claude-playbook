---
name: pb-feature
description: Phase 5 — implement ONE user story with strict TDD (failing test committed first), review, tick the story.
disable-model-invocation: true
argument-hint: "<STORY-ID>"
---
Story: $ARGUMENTS
Config: !`cat .claude/playbook.json; true`
Branch: !`git branch --show-current; true`

1. Read story $ARGUMENTS in `<docs.dir>/stories.md`, the related part of `<docs.dir>/api-contract.yaml`, relevant ADRs and plan task.
2. If on the default branch, propose a branch `feat/<story-id-lowercase>`.
3. CHECKPOINT 1 — list the files you will add/change and the test cases (one per AC + edge cases). AskUserQuestion approve / change. STOP until approved.
4. Write the tests (or ask pb-qa-engineer to). Run them: they MUST fail, for the right reason. Show the failing output. Commit only the tests: `test($ARGUMENTS): <what>`.
5. Implement until `commands.test` passes. Do NOT edit the committed tests; if a test is wrong, stop and ask.
6. If SQL/migrations changed → pb-db-reviewer. If auth/payments/webhooks/uploads changed → pb-security-reviewer.
7. Run `/simplify`, then `/code-review medium`. CHECKPOINT 2 — present findings (severity, file:line) and ask which to fix. STOP until answered; fix the chosen ones.
8. Run lint + typecheck + tests. Tick `### [x] $ARGUMENTS` in stories.md. Commit `feat($ARGUMENTS): <what>` (stage specific files only; never files from .claude/playbook.manifest).
9. Log row `| <date> | 5-build | $ARGUMENTS | <key choice> | <test sha>, <feat sha> |`; phase "5-build".
10. Say the next open story ID (or "/pb-qa" when all are done). STOP.
