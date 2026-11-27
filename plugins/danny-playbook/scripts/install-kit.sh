#!/usr/bin/env bash
# Install (or update) the danny-playbook kit into a project.
#
#   install-kit.sh <project-dir> [--docs tracked|private] [--remove]
#
# - Copies templates/claude/* into <project>/.claude/ without overwriting existing files.
# - Writes CLAUDE.local.md and .claude/playbook.json if missing.
# - Merges permissions + hooks into .claude/settings.local.json (personal, never committed).
# - Lists every file it created in .git/info/exclude, so the repo's .gitignore is never touched
#   and team repos stay clean. Files that already existed (e.g. a committed CLAUDE.md) are left alone.
# - --remove deletes only the files recorded in .claude/playbook.manifest and the exclude block.
set -euo pipefail

KIT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TPL="$KIT/templates"
TARGET="${1:?usage: install-kit.sh <project-dir> [--docs tracked|private] [--remove]}"
shift
DOCS_MODE=""
REMOVE=0
while [ $# -gt 0 ]; do
  case "$1" in
    --docs) DOCS_MODE="$2"; shift 2 ;;
    --remove) REMOVE=1; shift ;;
    *) echo "unknown option: $1" >&2; exit 64 ;;
  esac
done

command -v jq >/dev/null || { echo "jq is required (brew install jq)" >&2; exit 69; }
cd "$TARGET"
[ -d .git ] || { echo "not a git repository: $TARGET (run git init first)" >&2; exit 65; }

EXCLUDE=.git/info/exclude
MANIFEST=.claude/playbook.manifest
BEGIN="# >>> danny-playbook (local tooling, not committed)"
END="# <<< danny-playbook"
mkdir -p .git/info && touch "$EXCLUDE"

strip_block() { awk -v b="$BEGIN" -v e="$END" '$0==b{s=1;next} $0==e{s=0;next} !s' "$EXCLUDE" > "$EXCLUDE.tmp" && mv "$EXCLUDE.tmp" "$EXCLUDE"; }

if [ "$REMOVE" = 1 ]; then
  [ -f "$MANIFEST" ] || { echo "nothing to remove: no $MANIFEST"; exit 0; }
  while IFS= read -r f; do [ -n "$f" ] && [ -e "$f" ] && rm -f "$f" && echo "removed $f"; done < "$MANIFEST"
  rm -f "$MANIFEST"
  find .claude -type d -empty -delete 2>/dev/null || true
  strip_block
  echo "kit removed (settings.local.json hooks/permissions from the kit were left in place; review it)"
  exit 0
fi

LIST="$(mktemp)"; trap 'rm -f "$LIST"' EXIT
[ -f "$MANIFEST" ] && cat "$MANIFEST" > "$LIST"
record() { echo "$1" >> "$LIST"; }

# 1. .claude/{agents,skills,hooks,rules} — no clobber.
while IFS= read -r -d '' src; do
  rel="${src#"$TPL/claude/"}"
  dst=".claude/$rel"
  if [ -e "$dst" ]; then continue; fi
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
  case "$dst" in *.sh) chmod +x "$dst" ;; esac
  record "$dst"
  echo "created $dst"
done < <(find "$TPL/claude" -type f ! -name 'settings.local.json' ! -name 'playbook.json' -print0)

# 2. Doc templates live inside .claude/playbook/templates; phases instantiate them into docsDir.
while IFS= read -r -d '' src; do
  dst=".claude/playbook/templates/${src#"$TPL/"}"
  [ -e "$dst" ] && continue
  mkdir -p "$(dirname "$dst")" && cp "$src" "$dst" && record "$dst"
done < <(find "$TPL/docs" -type f -print0)

# 3. playbook.json (project config read by hooks and skills).
if [ ! -f .claude/playbook.json ]; then
  mode="${DOCS_MODE:-tracked}"
  docs_dir="docs"; [ "$mode" = private ] && docs_dir=".playbook/docs"
  jq --arg mode "$mode" --arg dir "$docs_dir" '.docs.mode=$mode | .docs.dir=$dir' "$TPL/claude/playbook.json" > .claude/playbook.json
  record .claude/playbook.json
  echo "created .claude/playbook.json (docs: $mode → $docs_dir)"
fi
DOCS_DIR="$(jq -r '.docs.dir' .claude/playbook.json)"
DOCS_MODE="$(jq -r '.docs.mode' .claude/playbook.json)"

# 4. CLAUDE.local.md: personal project memory, auto-loaded by Claude Code. A committed CLAUDE.md is never touched.
if [ ! -f CLAUDE.local.md ]; then
  sed "s#{{DOCS_DIR}}#$DOCS_DIR#g" "$TPL/CLAUDE.local.md" > CLAUDE.local.md
  record CLAUDE.local.md
  echo "created CLAUDE.local.md"
fi

# 5. settings.local.json: union permissions, append kit hooks once.
SL=.claude/settings.local.json
kit_settings="$TPL/claude/settings.local.json"
if [ ! -f "$SL" ]; then
  cp "$kit_settings" "$SL"; record "$SL"; echo "created $SL"
else
  jq -s '
    def uniq_cat(a; b): ((a // []) + (b // [])) | unique;
    .[0] as $cur | .[1] as $kit
    | $cur
    | .permissions.allow = uniq_cat($cur.permissions.allow; $kit.permissions.allow)
    | .permissions.ask   = uniq_cat($cur.permissions.ask;   $kit.permissions.ask)
    | .permissions.deny  = uniq_cat($cur.permissions.deny;  $kit.permissions.deny)
    | .hooks = (reduce ($kit.hooks | to_entries[]) as $e (($cur.hooks // {});
        .[$e.key] = (if ((.[$e.key] // []) | tostring | contains("danny-playbook")) then .[$e.key]
                     else ((.[$e.key] // []) + $e.value) end)))
  ' "$SL" "$kit_settings" > "$SL.tmp" && mv "$SL.tmp" "$SL"
  echo "merged kit permissions + hooks into $SL"
fi

# 6. Private docs dir.
if [ "$DOCS_MODE" = private ]; then mkdir -p "$DOCS_DIR"; fi

# 7. Manifest + git exclude block (rewritten every run, so it is always exact).
mkdir -p .claude && awk 'NF && !seen[$0]++' "$LIST" > "$MANIFEST"
strip_block
{
  echo "$BEGIN"
  cat "$MANIFEST"
  echo "$MANIFEST"
  # Personal by definition, even if they existed before the kit (only when not tracked).
  for f in .claude/settings.local.json CLAUDE.local.md; do
    grep -qxF "$f" "$MANIFEST" || git ls-files --error-unmatch "$f" >/dev/null 2>&1 || echo "$f"
  done
  [ "$DOCS_MODE" = private ] && echo "/.playbook/"
  echo "$END"
} >> "$EXCLUDE"

# Safety check: nothing the kit created may show up as untracked.
leak="$(git status --porcelain --untracked-files=all -- $(cat "$MANIFEST") "$MANIFEST" .claude/settings.local.json CLAUDE.local.md 2>/dev/null | grep '^??' || true)"
if [ -n "$leak" ]; then echo "WARNING: not excluded from git:" >&2; echo "$leak" >&2; exit 1; fi
echo "done: $(wc -l < "$MANIFEST" | tr -d ' ') kit files, all excluded via $EXCLUDE"
