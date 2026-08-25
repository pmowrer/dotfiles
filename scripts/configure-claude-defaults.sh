#!/usr/bin/env bash
set -euo pipefail

# Claude Code writes ~/.claude/settings.json itself (theme, effort level) and
# other tooling adds hooks to it, so this file cannot be stowed from the repo.
# Merge our defaults in instead, the same way configure-codex-defaults.sh does
# for ~/.codex/config.toml.

config_file="${1:-${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json}"
config_dir="$(dirname "$config_file")"
temp_file=""

cleanup() {
  if [[ -n "$temp_file" && -e "$temp_file" ]]; then
    rm -f -- "$temp_file"
  fi
}
trap cleanup EXIT

file_mode() {
  stat -c '%a' "$1" 2>/dev/null || stat -f '%Lp' "$1" 2>/dev/null
}

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required to merge Claude Code settings." >&2
  exit 1
fi

mkdir -p "$config_dir"

if [[ -L "$config_file" ]]; then
  echo "Warning: $config_file is a symlink; leaving it unchanged." >&2
  echo 'Set "editorMode": "vim" in its source file instead.' >&2
  exit 0
fi

if [[ -e "$config_file" && ! -f "$config_file" ]]; then
  echo "Error: $config_file exists but is not a regular file." >&2
  exit 1
fi

temp_file="$(mktemp "${config_file}.tmp.XXXXXX")"

if [[ -s "$config_file" ]]; then
  chmod "$(file_mode "$config_file")" "$temp_file"

  if ! jq --indent 2 '.editorMode = "vim"' "$config_file" > "$temp_file"; then
    echo "Error: $config_file is not valid JSON; not touching it." >&2
    exit 1
  fi
else
  chmod 644 "$temp_file"
  jq -n --indent 2 '{editorMode: "vim"}' > "$temp_file"
fi

if [[ -f "$config_file" ]] && cmp -s "$config_file" "$temp_file"; then
  echo "Claude Code already starts in Vim mode; settings unchanged."
  exit 0
fi

mv -- "$temp_file" "$config_file"
temp_file=""
echo "Configured Claude Code to start new sessions in Vim mode."
