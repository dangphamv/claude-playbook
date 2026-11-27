#!/usr/bin/env bash
# Copy the pinned third-party skills from vendor/skills.lock.json into the kit templates,
# each with its upstream LICENSE and a provenance file, and regenerate THIRD_PARTY_NOTICES.md.
# Downloads go to a fresh temp dir; nothing downloaded is executed.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOCK="$ROOT/vendor/skills.lock.json"
SKILLS="$ROOT/plugins/danny-playbook/templates/claude/skills"
# "install": "reference" → not auto-discoverable (would hijack phase checkpoints); phase skills read it explicitly.
REFS="$ROOT/plugins/danny-playbook/templates/claude/playbook/vendor"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
gh_() { env -u GITHUB_TOKEN gh "$@"; }

notices="$ROOT/THIRD_PARTY_NOTICES.md"
{ echo "# Third-party skills"; echo; echo "Copied unmodified into \`plugins/danny-playbook/templates/claude/skills/\` and installed into projects by /danny-playbook:init."; echo; echo "| Skill | Installed as | Source | Commit | License |"; echo "|---|---|---|---|---|"; } > "$notices"

jq -c '.skills[]' "$LOCK" | while read -r s; do
  name=$(jq -r .name <<<"$s"); repo=$(jq -r .repo <<<"$s"); sha=$(jq -r .sha <<<"$s"); path=$(jq -r .path <<<"$s"); lic=$(jq -r .license <<<"$s")
  DEST="$SKILLS"; [ "$(jq -r '.install // "skill"' <<<"$s")" = reference ] && DEST="$REFS"
  key="${repo//\//_}-$sha"
  if [ ! -d "$TMP/$key" ]; then
    mkdir -p "$TMP/$key"
    gh_ api "repos/$repo/tarball/$sha" > "$TMP/$key.tgz"
    tar -xzf "$TMP/$key.tgz" -C "$TMP/$key" --strip-components=1
  fi
  src="$TMP/$key/$path"
  [ -f "$src/SKILL.md" ] || { echo "missing $repo/$path/SKILL.md at $sha" >&2; exit 1; }
  # Refuse symlinks pointing outside the skill (plugins reject them, and they would not be copied).
  if find "$src" -type l | grep -q .; then echo "symlinks in $name — refusing" >&2; exit 1; fi
  rm -rf "$DEST/$name"; mkdir -p "$DEST/$name"; cp -R "$src/." "$DEST/$name/"
  if ! ls "$DEST/$name" | grep -qi '^licen'; then
    up=$(ls "$TMP/$key" | grep -i -m1 '^licen' || true)
    [ -n "$up" ] && cp "$TMP/$key/$up" "$DEST/$name/LICENSE.upstream" || { echo "no license file for $name" >&2; exit 1; }
  fi
  jq -n --arg repo "$repo" --arg sha "$sha" --arg path "$path" --arg lic "$lic" '{repo:$repo, sha:$sha, path:$path, license:$lic}' > "$DEST/$name/.upstream.json"
  mode=$([ "$DEST" = "$REFS" ] && echo "reference (.claude/playbook/vendor)" || echo "skill (.claude/skills)")
  echo "| \`$name\` | $mode | [$repo](https://github.com/$repo/tree/$sha/$path) | \`${sha:0:7}\` | $lic |" >> "$notices"
  echo "vendored $name ($(du -sh "$DEST/$name" | cut -f1))"
done
