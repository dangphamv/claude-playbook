#!/usr/bin/env bash
# Run the agent eval suite with Claude Code's official `claude plugin eval`.
# The kit installs agents into each project, but eval sandboxes only load the plugin under test,
# so this wraps the current agent templates in a throwaway plugin ("pb-eval") together with the cases.
#   scripts/run-evals.sh [--case <glob>] [any other claude plugin eval flags]
set -euo pipefail
KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
mkdir -p "$TMP/.claude-plugin" "$TMP/agents" "$TMP/skills" "$TMP/scripts"
echo '{"name":"pb-eval","version":"0.0.0","description":"Eval-only wrapper for danny-playbook agents"}' > "$TMP/.claude-plugin/plugin.json"
cp "$KIT"/templates/claude/agents/*.md "$TMP/agents/"
# Preloaded skills must exist where plugin agents can see them.
for s in "$KIT"/templates/claude/skills/*/; do n=$(basename "$s"); case "$n" in pb-*) ;; *) cp -R "$s" "$TMP/skills/$n" ;; esac; done
cp -R "$KIT/evals" "$TMP/evals"; rm -rf "$TMP/evals/results"
cp -R "$KIT/templates" "$TMP/templates"; cp "$KIT/scripts/install-kit.sh" "$TMP/scripts/"
claude plugin eval "$TMP" --scaffold --trust-plugin --ablation none --no-publish -j 4 --max-cost-usd "${MAX_COST_USD:-6}" "$@" \
  --output-dir "$KIT/evals/results" 2>&1 | grep -vE "^\s+✓"
