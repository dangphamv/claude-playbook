---
name: pb-status
description: Show where this project is in the playbook (phase, open stories, last decisions) and the one recommended next command.
disable-model-invocation: true
---
Config: !`.claude/playbook/bin/pb-context config`
Docs present: !`.claude/playbook/bin/pb-context docs`
Recent log: !`.claude/playbook/bin/pb-context log 8`
Git: !`.claude/playbook/bin/pb-context git`

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
| owner/team | `claude --agent pb-owner`, /pb-team <goal> | Owner delegates; team mode lets specialists message each other |
| auto | /pb-auto [goal] [--until <phase>], /pb-mode guided\|auto | chains phases, logs auto-decisions |
| maint | /pb-hotfix, /pb-retro | postmortem / CLAUDE.local.md or hook updated |

Report in at most 8 lines (include the current mode, guided or auto): current phase, what is done (with files), what is missing, and exactly ONE recommended next command with the reason.
Do not start that command yourself.
