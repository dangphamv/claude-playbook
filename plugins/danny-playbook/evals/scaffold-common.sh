#!/usr/bin/env bash
# Shared scaffold for every eval case: runs in the case's fresh working directory.
# Copies the seeded-defect fixtures, makes it a git repo, and installs the danny-playbook kit (agents, skills, hooks).
set -euo pipefail
EVALS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp -R "$EVALS/fixtures/." .
git init -q && git add . && git -c user.email=eval@example.com -c user.name=eval commit -qm fixtures
bash "$EVALS/../scripts/install-kit.sh" "$PWD" >/dev/null
