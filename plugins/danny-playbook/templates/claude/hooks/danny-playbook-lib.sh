#!/usr/bin/env bash
# Shared by the danny-playbook hooks. A configured command is "runnable" only when its tool exists here,
# so a greenfield repo (no package.json yet) is not blocked by checks that cannot run.
runnable() {
  local cmd="$1" tool
  tool="${cmd%% *}"
  case "$tool" in
    pnpm|npm|npx|yarn|bun|node) [ -f package.json ] || return 1 ;;
    uv|poetry|python|python3|pytest|ruff|mypy) [ -f pyproject.toml ] || [ -f requirements.txt ] || [ -f setup.py ] || return 1 ;;
    go) [ -f go.mod ] || return 1 ;;
    cargo) [ -f Cargo.toml ] || return 1 ;;
    make) [ -f Makefile ] || return 1 ;;
  esac
  command -v "$tool" >/dev/null 2>&1
}
