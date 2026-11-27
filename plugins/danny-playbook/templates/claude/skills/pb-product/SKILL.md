---
name: pb-product
description: Phase 1 — turn an idea into a PRD through structured questions. Plan-only; no code.
disable-model-invocation: true
argument-hint: "<idea or feature in one sentence>"
---
Mode: !`.claude/playbook/bin/pb-context mode`
If the mode is **auto**: at each CHECKPOINT choose the recommended option yourself, log it as `auto: <decision>` with the reason, and continue instead of stopping (outward or irreversible actions — push, PR, deploy, prod migration, publish, credentials — still require asking). At the end, instead of STOP, say which phase comes next; /pb-auto chains them.
Idea: $ARGUMENTS
Config: !`.claude/playbook/bin/pb-context config`
Existing PRD: !`.claude/playbook/bin/pb-context prd`

Rules: do not write code. Do not assume answers — ask.

1. Read .claude/playbook/vendor/brainstorming/SKILL.md and use its questioning method (one topic at a time, multiple choice, propose approaches with trade-offs) inside this checkpoint; this skill's checkpoints and outputs take precedence over its flow. CHECKPOINT 1 — brainstorm. Ask up to 8 questions with AskUserQuestion (max 4 per call, each with a recommended option first): who has the problem, how we measure success, MVP must-haves, explicit non-goals, constraints (time, budget, team, hosting), compliance (personal data — Vietnam Decree 13/2023 if relevant). STOP until answered.
2. If market/competitor context matters, offer research (WebSearch); only do it if the user says yes. Save to `<docs.dir>/research.md` with sources.
3. Draft `<docs.dir>/prd.md` from `.claude/playbook/templates/docs/prd.md` (or add a new section to an existing PRD for a feature). Every metric has a number; unknowns go to Open questions with a recommended default.
4. Ask the pb-product-manager subagent to review the draft; fix what it finds.
5. CHECKPOINT 2 — show a 10-line summary (problem, MVP, non-goals, metrics, risks, open questions) and ask: approve / change. STOP until approved.
6. Append to `<docs.dir>/playbook-log.md`: `| <date> | 1-product | <scope decided> | <why> | prd.md |`. Run `.claude/playbook/bin/pb-config set phase 1-product`.
7. If docs.mode is "tracked", ask before committing `docs: PRD for <topic>`.
8. Say: "Next: /pb-ba". STOP.
