---
name: pb-auto
description: Run the playbook end to end in auto mode — move through phases and delegate to the right agents without stopping at decision checkpoints, logging every auto-decision; still stops before any outward or irreversible action.
disable-model-invocation: true
allowed-tools: Bash(.claude/playbook/bin/*)
argument-hint: "[goal or feature] [--until <phase>]"
---
Goal: $ARGUMENTS
Config: !`.claude/playbook/bin/pb-context config`
Recent log: !`.claude/playbook/bin/pb-context log 6`
Phase skills: !`.claude/playbook/bin/pb-context skills`

You are the orchestrator. Run `.claude/playbook/bin/pb-config set mode auto`, then run the phases in order starting from the first one not yet done:
`1-product → 2-ba → 3-ux (skip with a logged reason if no UI) → 4-architect (+ phase-0 scaffold) → 5-build (every open story, in plan order) → 6-qa → 7-release → 8-operate`.
Stop after the phase before `auto.stopBefore` (default: stop before 7-release) or before `--until <phase>` if given.

For each phase:
1. Read `.claude/skills/<phase skill>/SKILL.md` and follow its steps. Its `!` lines are shell commands: run them yourself first to get the same context.
2. At every CHECKPOINT: do not ask. Choose the option you would have marked "(Recommended)", state it in one line, and append to the playbook log:
   `| <date> | <phase> | auto: <decision> | <why, incl. the main alternative rejected> | <evidence> |`
3. Delegate exactly as the phase says (pb-product-manager, pb-architect, pb-db-reviewer, pb-security-reviewer, pb-ux-reviewer, pb-devops-sre, pb-qa-engineer). Run independent reviews in parallel. Review findings: fix critical/high automatically; log medium/low as follow-ups instead of fixing.
4. TDD still applies in 5-build: failing test committed first, never edit a committed test.
5. Commit each phase's output with a conventional commit (docs only if docs.mode is "tracked"). Update the phase with `.claude/playbook/bin/pb-config set phase <phase>`.
6. Print one progress line: `✓ <phase> — <what was produced> — next: <phase>`. Then continue with the next phase.

Hard stops — even in auto mode, STOP and ask the user (AskUserQuestion) when:
- the next action is outward or irreversible: git push, opening/merging a PR, deploy, production migration or data change, publishing, sending messages, paying, deleting user data, creating accounts or cloud resources;
- a secret, credential, or paid service is needed;
- requirements conflict or the goal is too vague to pick a safe default (e.g. unknown target users AND unknown platform);
- a check still fails after `auto.maxFixAttempts` attempts (default 3) — report what was tried;
- context is getting long: commit, summarize progress into the log, and tell the user to run `/compact` or start a new session and re-run /pb-auto (it resumes from the log).

When you stop or finish: a short report — phases completed, auto-decisions taken (the user can revisit any of them with the matching /pb-* skill in guided mode), open follow-ups, and the exact next command.
