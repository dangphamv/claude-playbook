# danny-playbook

A Claude Code plugin that turns the [idea → release playbook](reference/claude-code-playbook.html) into something you can run in any repository.

One command configures the current project — subagents, phase skills, hooks, path rules, permissions and a local `CLAUDE.local.md` — **without committing anything**: every file the kit creates is listed in `.git/info/exclude`, and existing files are never overwritten. Then each phase of the playbook is a skill that does the work and **stops for your decision** before moving on.

## Install
```bash
# once per machine (private repo: needs git access to dangphamv/claude-playbook)
claude plugin marketplace add dangphamv/claude-playbook
claude plugin install danny-playbook@danny-playbook
```
Develop/test locally without installing: `claude --plugin-dir ~/project/claude-playbook/plugins/danny-playbook`.

No plugin on the machine? Point Claude at [SETUP.md](SETUP.md) — same result.

## Use
```text
cd my-project && claude
/danny-playbook:init "what we are building"      # asks: docs tracked or private, confirms commands
/exit, then claude again                          # hooks & skills load at session start
/pb-status                                        # where am I, what is next
```

| Phase | Skill | Stops to ask you | Output |
|---|---|---|---|
| 0 | `/danny-playbook:init`, `/pb-adopt` (existing code) | docs mode, commands, danger zones | `.claude/*`, `CLAUDE.local.md`, `architecture.md` |
| 1 Product | `/pb-product <idea>` | up to 8 scoping questions, PRD approval | `prd.md` |
| 2 BA | `/pb-ba` | open business rules, story list | `stories.md`, `api-contract.yaml`, `data-model.md` |
| 3 UX | `/pb-ux` | visual direction, prototype feedback | `design/`, tokens, frontend rule |
| 4 Architecture | `/pb-architect` | each decision, plan approval | `adr/*.md`, `plan.md` |
| 5 Build | `/pb-feature <ID>` | file list, review findings | `test(ID)` commit → `feat(ID)` commit |
| 6 QA | `/pb-qa` | which checks, which findings to fix | `test-plan.md`, e2e specs |
| 7 Release | `/pb-release` | checklist, every deploy/migration | PR, tag, `runbook.md` |
| 8 Operate | `/pb-operate` | which routines | scheduled routines, runbook |
| Maintenance | `/pb-hotfix`, `/pb-retro` | rollback, deploy, new guard | postmortem, rule/hook/test |
| Auto | `/pb-auto [goal] [--until <phase>]`, `/pb-mode guided\|auto` | only outward/irreversible actions | all of the above, decisions logged as `auto:` |

### Guided vs auto
- **guided** (default): every checkpoint asks you and stops. Best for learning the process or high-stakes decisions.
- **auto**: `/pb-auto "<goal>"` moves through the phases by itself, delegates to the right agent at each step, picks the recommended option at each checkpoint and logs it (`auto:` rows in `playbook-log.md`). It stops before release by default (`auto.stopBefore`), and always stops for push/PR/deploy/production data/publishing/credentials, for conflicting requirements, and when a check still fails after 3 attempts. Re-run `/pb-auto` to resume from the log; revisit any auto-decision with the matching `/pb-*` skill in guided mode.
- Pair auto with Claude Code's permission auto mode (Shift+Tab → auto) so routine commands are not prompted.

Every checkpoint appends a row to `playbook-log.md` (decision · why · evidence), which doubles as interview material.

## What gets installed in a project
| Path | Purpose |
|---|---|
| `.claude/agents/pb-*.md` | 7 specialists, see below |
| `.claude/skills/pb-*/` | the phase skills above |
| `.claude/hooks/danny-playbook-*.sh` | block `.env` reads; run your format command after edits; typecheck before Claude stops; session status |
| `.claude/rules/*.md` | path-scoped rules for your stack (created at init) |
| `.claude/settings.local.json` | permissions + hook registration (merged, personal) |
| `.claude/playbook.json` | mode (guided/auto), docs mode/dir, your format/lint/typecheck/test/build commands, current phase |
| `.claude/playbook/bin/pb-config`, `pb-context` | read/write the config and gather skill context through one allow-listed path (Claude Code protects `.claude/` from edits, and a failing `!` command aborts a skill) |
| `CLAUDE.local.md` | local project memory (a committed `CLAUDE.md` is left untouched) |
| `.claude/playbook/templates/` | PRD, stories, ADR, plan, test plan, runbook, log templates |

Remove everything the kit created: `/danny-playbook:remove`. Pull newer kit files: `/danny-playbook:update`.

## Agents
| Agent | Model | Role | Built on |
|---|---|---|---|
| `pb-product-manager` | opus | Frame ideas, PRD, scope, metrics, story review | JTBD, four product risks (value/usability/feasibility/viability), outcome + guardrail metrics, pre-mortem, VN regulatory flags marked **[verify]** |
| `pb-architect` | opus | Options, ADRs, capacity estimates, plans | back-of-envelope numbers, failure modes, reversibility, fitness-function tests |
| `pb-db-reviewer` | sonnet, read-only | Migrations & queries | Postgres lock levels, expand→contract, races/deadlocks, integrity (money, time zones), indexing, rollback |
| `pb-qa-engineer` | sonnet | Test matrix, failing tests first, E2E/load | risk-based testing, boundary/decision-table/state-transition/property-based, determinism |
| `pb-security-reviewer` | sonnet, read-only | Threat model & diff review | OWASP Top 10, API Top 10 2023, LLM Top 10, ASVS; source→sink evidence |
| `pb-ux-reviewer` | sonnet, read-only | Screens & prototypes | WCAG 2.2 AA, Nielsen heuristics, VN locale (VND, dates, diacritics), mobile |
| `pb-devops-sre` | sonnet, read-only | Docker, CI/CD, IaC, release readiness | CI supply-chain security, build-once images, safe deploy/rollback, SLO-based ops |

### Third-party skills (vendored, pinned)
Installed with the kit and preloaded into the agents that use them (see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)):
`ui-ux-pro-max` + `frontend-design` → pb-ux-reviewer, /pb-ux · `test-driven-development` + `webapp-testing` → pb-qa-engineer, /pb-feature · `supabase-postgres-best-practices` → pb-db-reviewer · `writing-plans` → pb-architect · `systematic-debugging` → /pb-hotfix · `verification-before-completion` → /pb-feature · `brainstorming` (reference only, so it cannot hijack checkpoints) → /pb-product.
Refresh: bump a `sha` in `vendor/skills.lock.json`, run `scripts/vendor-skills.sh`, then `evals/run.sh`.
Not vendored (license): Trail of Bits security skills (CC-BY-SA) and Vercel web-design-guidelines (no license) — /danny-playbook:init offers to install them from source.

Every reviewer returns `[severity] file:line — problem — failure/exploit scenario — fix`, skips style, and ends with **Not verified**.

### Evals
`evals/run.sh [agent]` runs each agent against fixtures with seeded defects (`evals/fixtures`, answer key in `evals/cases.json`) and scores the findings (~$2-3 per full run). Run it after editing an agent.

| Agent | Seeded defects found (27/11/2026) |
|---|---|
| pb-db-reviewer | 21/21 (incl. deadlock lock order, `NOT IN` + NULL, float money, FK without index) |
| pb-security-reviewer | 22/22 (incl. LLM prompt injection with a refund tool, ReDoS, prototype pollution, `Math.random` reset tokens) |
| pb-ux-reviewer | 12/12 |
| pb-devops-sre | 13/13 (incl. `pull_request_target` pwn request, script injection) |
| pb-qa-engineer | 10/10 coverage categories |

PM and architect output is judged qualitatively (not keyword-scorable).

## Why it is built this way
- **Plugins cannot ship CLAUDE.md, rules or permissions**, so `init` installs them into the project from templates.
- **Project-level hooks, not plugin hooks**: plugin hooks would run in every repo; these only run where you ran `init`.
- **Skills, not commands**, with `disable-model-invocation: true`: phases run only when you type them.
- **`.git/info/exclude`, not `.gitignore`**: works in team repos without a diff.
