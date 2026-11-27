# Set up a project without the plugin (docs mode)

Give this file to Claude Code inside the target project, e.g.:

> Follow ~/project/claude-playbook/SETUP.md to set up this project.

## Instructions for Claude
1. Locate the kit. Use `KIT=~/project/claude-playbook/plugins/danny-playbook` if it exists; otherwise clone it:
   `gh repo clone dangphamv/claude-playbook /tmp/claude-playbook && KIT=/tmp/claude-playbook/plugins/danny-playbook`.
2. Read `$KIT/skills/init/SKILL.md` and follow its steps exactly, reading `${CLAUDE_PLUGIN_ROOT}` as `$KIT`.
   The `!` lines at the top of that file are shell commands: run them yourself to gather the same context.
3. Respect every CHECKPOINT: ask with AskUserQuestion and stop until the user answers.

Result is identical to `/danny-playbook:init`: agents, `/pb-*` skills, hooks, rules, permissions and
CLAUDE.local.md are installed into the project and excluded from git via `.git/info/exclude`.
