# Project notes (danny-playbook, local only, not committed)

<!-- /danny-playbook:init fills the sections below. Keep under ~150 lines; anything mandatory belongs in a hook or permission. -->

## Stack
- (detected at init)

## Commands
- (from .claude/playbook.json → commands)

## Working agreement
- Source of truth for requirements: {{DOCS_DIR}}/prd.md, {{DOCS_DIR}}/stories.md. Decisions: {{DOCS_DIR}}/adr/.
- API contract (if any): {{DOCS_DIR}}/api-contract.yaml — change it before changing code.
- Phases run through /pb-* skills. Each phase ends at a checkpoint: ask the user with AskUserQuestion and STOP. Never start the next phase on your own.
- Every phase appends one row to {{DOCS_DIR}}/playbook-log.md: decision, why, evidence (file/commit).
- Build with TDD: tests from acceptance criteria first, see them fail, commit them, then implement. Never edit a committed test to make it pass.
- Conventional commits. Stage specific files. Do not commit anything listed in .claude/playbook.manifest.

## Never
- Read or edit .env files (a hook blocks it). Run migrations or deploys against production without asking.
- Refactor code the current story does not need.
