---
name: pb-retro
description: Turn a repeated mistake or postmortem into a permanent guard — a line in CLAUDE.local.md, a path rule, a hook, or a test.
disable-model-invocation: true
allowed-tools: Bash(.claude/playbook/bin/*)
argument-hint: "<what went wrong>"
---
Mode: !`.claude/playbook/bin/pb-context mode`
If the mode is **auto**: at each CHECKPOINT choose the recommended option yourself, log it as `auto: <decision>` with the reason, and continue instead of stopping (outward or irreversible actions — push, PR, deploy, prod migration, publish, credentials — still require asking). At the end, instead of STOP, say which phase comes next; /pb-auto chains them.
Problem: $ARGUMENTS
Current rules: !`.claude/playbook/bin/pb-context rules`

1. Name the failure precisely (what happened, what should have happened, how often).
2. Choose the weakest guard that reliably works: test (behaviour) > hook or permission deny (must never happen) > path rule (applies to some files) > CLAUDE.local.md line (preference). Context files are advisory; anything mandatory must be a hook or permission.
3. CHECKPOINT — AskUserQuestion with the proposed guard and its exact text/code. STOP until approved.
4. Apply it, verify it triggers (e.g. run the hook script with a sample input), and log a row `| <date> | retro | <guard> | <why> | <file> |`.
