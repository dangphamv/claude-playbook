#!/usr/bin/env bash
# Regression check for the danny-playbook agents: each agent reviews fixtures with seeded defects,
# and the answer key (cases.json) is matched against its findings. Costs about $2-3 per full run.
#   evals/run.sh [agent-name]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d)"; OUT="$ROOT/evals/results/$(date +%Y%m%d-%H%M%S)"; mkdir -p "$OUT"
cp -R "$ROOT/evals/fixtures/." "$WORK/" && cd "$WORK" && git init -q && git add . && git -c user.email=e@e -c user.name=e commit -qm fixtures
bash "$ROOT/plugins/danny-playbook/scripts/install-kit.sh" "$WORK" >/dev/null
agents=$(jq -r 'keys[]' "$ROOT/evals/cases.json"); [ $# -gt 0 ] && agents="$1"
for a in $agents; do
  n=$(jq --arg a "$a" '.[$a] | length' "$ROOT/evals/cases.json")
  for i in $(seq 0 $((n-1))); do
    prompt=$(jq -r --arg a "$a" --argjson i "$i" '.[$a][$i].prompt' "$ROOT/evals/cases.json")
    claude -p "$prompt Delegate this to the $a subagent and return its findings verbatim." --max-turns 20 \
      --permission-mode dontAsk --allowedTools "Agent,Read,Grep,Glob,Bash(git *),Bash(cat *),Bash(ls *)" > "$OUT/$a-$i.txt" 2>&1 &
    sleep 2 # stagger starts
  done
done
wait
total=0; hit=0; failed=0
for a in $agents; do
  n=$(jq --arg a "$a" '.[$a] | length' "$ROOT/evals/cases.json")
  for i in $(seq 0 $((n-1))); do
    # A real review is long; a short file is a failed run (usage limit, auth, timeout), not a weak agent.
    if [ "$(wc -c < "$OUT/$a-$i.txt")" -lt 800 ]; then
      failed=$((failed+1)); echo "RUN FAILED $a #$i: $(head -c 200 "$OUT/$a-$i.txt")"; continue
    fi
    while IFS=$'\t' read -r label re; do
      total=$((total+1))
      if grep -qiE "$re" "$OUT/$a-$i.txt"; then hit=$((hit+1)); else echo "MISS $a: $label"; fi
    done < <(jq -r --arg a "$a" --argjson i "$i" '.[$a][$i].checks | to_entries[] | "\(.key)\t\(.value)"' "$ROOT/evals/cases.json")
  done
done
echo "score: $hit/$total (keyword match; read $OUT for the full reports)"
[ "$failed" -eq 0 ] || { echo "$failed run(s) failed — score is incomplete; rerun later." >&2; rm -rf "$WORK"; exit 1; }
rm -rf "$WORK"
