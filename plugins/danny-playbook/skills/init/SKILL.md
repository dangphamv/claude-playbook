---
name: init
description: Set up the current project for the danny-playbook workflow — agents, phase skills, hooks, rules, permissions and CLAUDE.local.md, all kept out of git. Works for new and existing projects.
disable-model-invocation: true
argument-hint: "[one-line description of the project or the work ahead]"
---
Work ahead: $ARGUMENTS
Kit root: ${CLAUDE_PLUGIN_ROOT}
Project: !`pwd; true`
Git: !`git rev-parse --is-inside-work-tree 2>/dev/null && git log --oneline -3 2>/dev/null; git ls-files | wc -l | xargs echo "tracked files:"; true`
Already set up: !`test -f .claude/playbook.json && cat .claude/playbook.json || echo "no"; true`
Manifests: !`ls package.json pnpm-workspace.yaml turbo.json pyproject.toml requirements.txt go.mod Cargo.toml pom.xml build.gradle Makefile docker-compose.yml compose.yaml 2>/dev/null; ls .github/workflows 2>/dev/null; true`
Existing Claude config: !`ls CLAUDE.md AGENTS.md .claude 2>/dev/null; ls .claude/agents .claude/skills 2>/dev/null; true`

You are installing a local, uncommitted toolkit. Follow the steps in order and stop at every CHECKPOINT.

1. If this is not a git repository, ask whether to run `git init`. STOP until answered.
2. If `.claude/playbook.json` already exists, say so and offer `/danny-playbook:update` instead; STOP.
3. Detect: greenfield (few or no tracked files) vs existing codebase; the stack; real commands for format/lint/typecheck/test/build (package.json scripts, Makefile, CI workflows, pyproject). Only propose a command that already works in this repo today — the tool and its config exist (verify cheaply, e.g. `<tool> --version` or the script exists in package.json). **Greenfield: leave every command empty**; /pb-architect fills them after scaffolding. Hooks run these commands on every edit and before every stop, so a command that cannot run yet only produces noise. For `format`, the command receives a file path as its last argument (e.g. `pnpm exec prettier --write`, `ruff format`); leave it empty if nothing fits.
4. CHECKPOINT 1 — one AskUserQuestion call:
   - Docs (PRD, ADR, stories, log): "tracked" — committed under docs/ (your own project) — or "private" — kept in .playbook/docs and excluded from git (someone else's / team repo).
   - Confirm the detected commands (show them; offer "edit"). For greenfield, say they stay empty until scaffolding.
   - Project type confirmation: new product / feature work on an existing codebase.
   - Mode: "guided" — stop and ask at every phase checkpoint (best for learning or important decisions) — or "auto" — pick recommended options, log them, chain phases with /pb-auto; outward or irreversible actions still ask.
   STOP until answered.
5. Run: `bash "${CLAUDE_PLUGIN_ROOT}/scripts/install-kit.sh" "$PWD" --docs <tracked|private>` and show its output. If it prints a WARNING about files not excluded, stop and report.
6. Write the confirmed commands into `.claude/playbook.json` (`commands.*`) and the chosen `mode`, using jq.
7. Fill CLAUDE.local.md "Stack" and "Commands" sections with what you detected (short, factual). If a committed CLAUDE.md or AGENTS.md exists, do not edit it; CLAUDE.local.md complements it.
8. Create 1-3 path rules in `.claude/rules/` that fit this stack (e.g. api.md for the backend folder, db.md for migrations), each under 10 lines, then add their paths to `.claude/playbook.manifest` and re-run step 5's script (it is idempotent and refreshes the git exclude block).
9. Optional skills that cannot ship in the kit (license). AskUserQuestion (multi-select, skippable): Trail of Bits security skills for pb-security-reviewer / pb-devops-sre (`claude plugin marketplace add trailofbits/skills`, then install `differential-review`, `insecure-defaults`, `supply-chain-risk-auditor`, `agentic-actions-auditor` from marketplace `trailofbits` at project scope); Vercel web-design-guidelines for pb-ux-reviewer (show the user `https://github.com/vercel-labs/agent-skills/tree/main/skills/web-design-guidelines` and let them install it — no license, so do not copy it yourself). Run only what the user selects; agents work without them.
10. Verify: `git status --porcelain --untracked-files=all` shows none of the kit files; `bash -n` each hook; run `.claude/hooks/danny-playbook-guard-env.sh` with `{"tool_input":{"file_path":".env"}}` on stdin and confirm exit 2.
11. Report in a short table what was created, that it is excluded from git, and that hooks and skills load in the NEXT session (`/exit`, then `claude` again in this folder). Then recommend: greenfield → `/pb-product <idea>` (guided) or `/pb-auto <idea>` (auto); existing codebase → `/pb-adopt`. Mention that `/pb-mode guided|auto` switches modes at any time. Append the first row to the playbook log: `| <date> | 0-setup | docs <mode>, commands confirmed | <why> | .claude/playbook.json |`. STOP.
