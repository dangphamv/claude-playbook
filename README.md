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

Every checkpoint appends a row to `playbook-log.md` (decision · why · evidence), which doubles as interview material.

## What gets installed in a project
| Path | Purpose |
|---|---|
| `.claude/agents/pb-*.md` | product-manager, architect, db-reviewer, qa-engineer, security-reviewer |
| `.claude/skills/pb-*/` | the phase skills above |
| `.claude/hooks/danny-playbook-*.sh` | block `.env` reads; run your format command after edits; typecheck before Claude stops; session status |
| `.claude/rules/*.md` | path-scoped rules for your stack (created at init) |
| `.claude/settings.local.json` | permissions + hook registration (merged, personal) |
| `.claude/playbook.json` | docs mode/dir, your format/lint/typecheck/test/build commands, current phase |
| `CLAUDE.local.md` | local project memory (a committed `CLAUDE.md` is left untouched) |
| `.claude/playbook/templates/` | PRD, stories, ADR, plan, test plan, runbook, log templates |

Remove everything the kit created: `/danny-playbook:remove`. Pull newer kit files: `/danny-playbook:update`.

## Why it is built this way
- **Plugins cannot ship CLAUDE.md, rules or permissions**, so `init` installs them into the project from templates.
- **Project-level hooks, not plugin hooks**: plugin hooks would run in every repo; these only run where you ran `init`.
- **Skills, not commands**, with `disable-model-invocation: true`: phases run only when you type them.
- **`.git/info/exclude`, not `.gitignore`**: works in team repos without a diff.
