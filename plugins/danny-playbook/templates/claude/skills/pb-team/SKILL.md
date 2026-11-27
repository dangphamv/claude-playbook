---
name: pb-team
description: Run work as an agent team — the Owner leads, pb-* specialists are teammates who message each other directly and share a task list. For cross-checking designs, parallel reviews, and debates; costs more tokens than subagents.
disable-model-invocation: true
argument-hint: "<goal for the team>"
---
Goal: $ARGUMENTS
Teams: !`.claude/playbook/bin/pb-context teams`
Agents: !`.claude/playbook/bin/pb-context agents`
Config: !`.claude/playbook/bin/pb-context config`

1. If teams are not `on`: explain they are an experimental Claude Code feature (more tokens, one team per session, no resume of teammates; split panes need tmux or iTerm2). Ask the user (AskUserQuestion) whether to enable; if yes run `.claude/playbook/bin/pb-config teams on` and tell them to restart Claude Code (ideally `claude --agent pb-owner`) and run /pb-team again. STOP.
2. Read the goal and the playbook state. Decide whether a team is worth it: teams fit work where specialists must challenge each other or work in parallel on separate files (design review, multi-angle review, independent modules). For sequential or same-file work, say so and recommend /pb-auto or the phase skill instead; ask before continuing.
3. Propose the team (3–5 teammates), each from a pb-* agent type with a short name and a clear deliverable, plus the shared task list with dependencies and which files each teammate owns. Note: teammates don't receive preloaded skills; mention the skill in their brief if they need it. In guided mode, ask the user to approve the team; in auto mode, proceed and log `auto: team = ...`.
4. Spawn the teammates by agent type and name. Create the tasks. Tell teammates they may message each other directly to resolve questions, must not edit files owned by another teammate, and must report blockers to the lead.
5. As lead: monitor tasks, unblock, settle disagreements with reasons (or ask the user), and verify deliverables against code and test output. Hard stops from the Owner rules still apply (push, PR, deploy, production data, publishing, credentials → ask).
6. Finish: shut the team down, append decisions to the playbook log (`team:` rows with evidence), commit outputs, and report to the user: what each teammate produced, decisions, open items, next step.
