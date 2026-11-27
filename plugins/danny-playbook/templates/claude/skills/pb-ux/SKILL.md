---
name: pb-ux
description: Phase 3 — user flows, 2-3 visual directions to choose from, a clickable prototype, then design tokens and a frontend rule.
disable-model-invocation: true
allowed-tools: Bash(.claude/playbook/bin/*)
argument-hint: "[flow or story IDs]"
---
Mode: !`.claude/playbook/bin/pb-context mode`
If the mode is **auto**: at each CHECKPOINT choose the recommended option yourself, log it as `auto: <decision>` with the reason, and continue instead of stopping (outward or irreversible actions — push, PR, deploy, prod migration, publish, credentials — still require asking). At the end, instead of STOP, say which phase comes next; /pb-auto chains them.
Scope: $ARGUMENTS
Config: !`.claude/playbook/bin/pb-context config`

1. Write user flows for the core stories as mermaid in `<docs.dir>/design/flows.md`, including error/empty/loading states.
2. Propose 2-3 distinct visual directions (use the ui-ux-pro-max skill for palettes, font pairings and stack guidelines, and frontend-design for the quality bar). CHECKPOINT 1 — AskUserQuestion with an ASCII preview per option. STOP until chosen.
3. Build a clickable prototype of the main flow (HTML). Ask the pb-ux-reviewer subagent to review it (usability, WCAG 2.2 AA, Vietnamese locale, mobile) and fix blockers/majors before showing it. Offer to publish it as a private Artifact for feedback, and/or check it in Chrome at mobile and desktop width. CHECKPOINT 2 — ask for feedback; iterate until approved. STOP between rounds.
4. Turn the approved design into tokens (colors, spacing, radius, typography) in the app's theme, and create `.claude/rules/frontend.md` (paths: the web app) — tokens only, required states, a11y basics, formatting helpers for money/dates.
5. Log row `| <date> | 3-ux | <direction> | <why> | design/ |`; `.claude/playbook/bin/pb-config set phase 3-ux`.
6. If the work is backend-only, skip this phase: log `3-ux | skipped | backend-only`.
7. Say: "Next: /pb-architect". STOP.
