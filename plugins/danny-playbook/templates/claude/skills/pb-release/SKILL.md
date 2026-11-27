---
name: pb-release
description: Phase 7 — production checklist, PR to merge, build-once images/artifacts, deploy with explicit approval, smoke test, tag, runbook.
disable-model-invocation: true
allowed-tools: Bash(.claude/playbook/bin/*)
argument-hint: "[version]"
---
Mode: !`.claude/playbook/bin/pb-context mode`
If the mode is **auto**: at each CHECKPOINT choose the recommended option yourself, log it as `auto: <decision>` with the reason, and continue instead of stopping (outward or irreversible actions — push, PR, deploy, prod migration, publish, credentials — still require asking). At the end, instead of STOP, say which phase comes next; /pb-auto chains them.
Version: $ARGUMENTS
Config: !`.claude/playbook/bin/pb-context config`
Last tag: !`.claude/playbook/bin/pb-context tag`
CI: !`.claude/playbook/bin/pb-context ci`

Every outward action (push, PR, merge, deploy, migration, tag, release) needs an explicit yes from the user in this session.

1. Ask the pb-devops-sre subagent to review Dockerfiles, CI/CD workflows, compose/IaC and the deploy/rollback plan; include its findings. Production checklist — report pass/fail for each: environments & env vars complete (.env.example vs platform), secrets only in secret stores (run gitleaks if available), backups + one tested restore, error tracking/logs/uptime alerts, rollback path known, security review on the release diff + dependency audit, legal pages if user data, SEO/meta if public web.
2. CHECKPOINT 1 — show the checklist and the release notes (grouped feat/fix since last tag). AskUserQuestion: proceed / fix first. STOP until answered.
3. PR: push the branch and open a PR (suggest `/ship` to babysit CI and review comments). Merging is the user's call.
4. Deploy: prefer build-once artifacts (image tagged by commit SHA, promoted across environments). CHECKPOINT 2 — before migrating or deploying production, state exactly what will run where; STOP until the user says yes.
5. Smoke test (health, one core read, one core write path); report results.
6. Tag + release notes (`gh release create`) after approval. Write/refresh `<docs.dir>/runbook.md`: deploy, rollback, secret rotation, common incidents.
7. Log row; `.claude/playbook/bin/pb-config set phase 7-release`. Say: "Next: /pb-operate". STOP.
