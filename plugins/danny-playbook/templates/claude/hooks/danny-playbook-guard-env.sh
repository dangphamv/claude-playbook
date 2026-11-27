#!/usr/bin/env bash
# PreToolUse: block reading or editing secret env files (.env.example and .env.sample stay allowed).
f=$(jq -r '.tool_input.file_path // empty')
case "$(basename "$f")" in
  .env.example|.env.sample|.env.template) exit 0 ;;
  .env|.env.*) echo "danny-playbook: $f looks like a secrets file; ask the user instead of reading it." >&2; exit 2 ;;
esac
exit 0
