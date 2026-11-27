---
name: pb-status
description: Show where this project is in the playbook (phase, open stories, last decisions) and the one recommended next command.
disable-model-invocation: true
---
Config: !`cat .claude/playbook.json 2>/dev/null || echo "{}"`
Docs present: !`d=$(jq -r '.docs.dir // "docs"' .claude/playbook.json 2>/dev/null); ls "$d" "$d/adr" 2>/dev/null | head -40`
Recent log: !`d=$(jq -r '.docs.dir // "docs"' .claude/playbook.json 2>/dev/null); tail -8 "$d/playbook-log.md" 2>/dev/null || echo "(no log yet)"`
Git: !`git log --oneline -5 2>/dev/null; git status --short 2>/dev/null | head -10`

Phases and the file that proves each one is done:
| # | Skill | Done when |
|---|---|---|
| 0 | /danny-playbook:init (+ /pb-adopt for an existing codebase) | .claude/playbook.json has commands filled; architecture map exists for brownfield |
| 1 | /pb-product | prd.md |
| 2 | /pb-ba | stories.md (+ api-contract.yaml, data-model.md when relevant) |
| 3 | /pb-ux | design/ (skip for backend-only work, log the skip) |
| 4 | /pb-architect | adr/*.md + plan.md |
| 5 | /pb-feature <ID> | each story: test commit then feat commit, ticked in stories.md |
| 6 | /pb-qa | test-plan.md updated, review findings resolved |
| 7 | /pb-release | PR merged, tag/release, runbook.md |
| 8 | /pb-operate | routine/monitoring set up |
| maint | /pb-hotfix, /pb-retro | postmortem / CLAUDE.local.md or hook updated |

Report in at most 8 lines: current phase, what is done (with files), what is missing, and exactly ONE recommended next command with the reason.
Do not start that command yourself.
