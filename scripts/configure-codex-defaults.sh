#!/usr/bin/env bash
set -euo pipefail

config_file="${1:-${CODEX_HOME:-$HOME/.codex}/config.toml}"
config_dir="$(dirname "$config_file")"
temp_file=""

cleanup() {
  if [[ -n "$temp_file" && -e "$temp_file" ]]; then
    rm -f -- "$temp_file"
  fi
}
trap cleanup EXIT

mkdir -p "$config_dir"

if [[ -L "$config_file" ]]; then
  echo "Warning: $config_file is a symlink; leaving it unchanged." >&2
  echo "Set tui.vim_mode_default = true in its source file instead." >&2
  exit 0
fi

if [[ -e "$config_file" && ! -f "$config_file" ]]; then
  echo "Error: $config_file exists but is not a regular file." >&2
  exit 1
fi

temp_file="$(mktemp "${config_file}.tmp.XXXXXX")"
chmod 600 "$temp_file"

if [[ -f "$config_file" ]]; then
  awk '
    function write_default() {
      if (!wrote_default) {
        print "vim_mode_default = true"
        wrote_default = 1
      }
    }

    BEGIN {
      at_root = 1
      in_tui = 0
      saw_tui = 0
      wrote_default = 0
    }

    {
      if (at_root && $0 ~ /^[[:space:]]*tui\.vim_mode_default[[:space:]]*=/) {
        print "tui.vim_mode_default = true"
        wrote_default = 1
        next
      }

      if ($0 ~ /^[[:space:]]*\[\[?[^]]+\]\]?[[:space:]]*(#.*)?$/) {
        if (in_tui) {
          write_default()
        }

        at_root = 0
        in_tui = ($0 ~ /^[[:space:]]*\[tui\][[:space:]]*(#.*)?$/)
        if (in_tui) {
          saw_tui = 1
        }
      }

      if (in_tui && $0 ~ /^[[:space:]]*vim_mode_default[[:space:]]*=/) {
        write_default()
        next
      }

      print
    }

    END {
      if (in_tui) {
        write_default()
      } else if (!saw_tui && !wrote_default) {
        if (NR > 0) {
          print ""
        }
        print "[tui]"
        print "vim_mode_default = true"
      }
    }
  ' "$config_file" > "$temp_file"
else
  printf '%s\n' '[tui]' 'vim_mode_default = true' > "$temp_file"
fi

if [[ -f "$config_file" ]] && cmp -s "$config_file" "$temp_file"; then
  echo "Codex already starts in Vim mode; config unchanged."
  exit 0
fi

mv -- "$temp_file" "$config_file"
temp_file=""
echo "Configured Codex to start new sessions in Vim mode."
