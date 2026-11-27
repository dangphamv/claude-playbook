---
name: pb-mode
description: Switch the playbook between guided mode (stop and ask at every checkpoint) and auto mode (pick recommended options, log them, keep going; still stop for outward/irreversible actions).
disable-model-invocation: true
argument-hint: "guided | auto [--stop-before <phase>]"
---
Requested: $ARGUMENTS
Current: !`.claude/playbook/bin/pb-context config`

Run `.claude/playbook/bin/pb-config set mode <value>` (and `.claude/playbook/bin/pb-config set auto.stopBefore <phase>` if given). Valid phases: 1-product … 8-operate.
Explain in two lines what changes: in auto mode the /pb-* phase skills pick the recommended option at each checkpoint and log it as `auto:`; /pb-auto chains phases. Outward or irreversible actions always ask.
Tip: combine with Claude Code's permission auto mode (Shift+Tab → auto) so routine commands are not prompted either.
