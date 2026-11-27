---
name: pb-hotfix
description: Production incident — rollback first if users are hurt, reproduce with a failing test on a hotfix branch from the deployed tag, minimal fix, deploy with approval, postmortem.
disable-model-invocation: true
argument-hint: "<symptom, error, or trace>"
---
Incident: $ARGUMENTS
Deployed tag: !`git describe --tags --abbrev=0 2>/dev/null || echo "(no tags)"; true`

1. Triage: impact (who/how many), since when, last deploy. CHECKPOINT — if users are affected, recommend rollback to the previous release and ask; STOP until answered.
2. Form hypotheses; add logging or queries to confirm. Do not fix yet.
3. Branch `hotfix/<slug>` from the deployed tag. Reproduce with a failing test; commit it.
4. Minimal fix (no refactors). `/code-review high` on the diff. CHECKPOINT — show the diff and ask to deploy; STOP until yes.
5. After deploy + smoke test: merge back into the main branch.
6. Write `<docs.dir>/postmortems/<date>-<slug>.md`: timeline, root cause, what detected it, what prevents it (rule, hook, test, alert). Then run /pb-retro to apply the prevention.
