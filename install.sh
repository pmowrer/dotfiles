#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v stow >/dev/null 2>&1; then
  echo "Error: GNU stow is required but not installed." >&2
  exit 1
fi

cd "$REPO_ROOT"
stow -t "$HOME" zsh git

echo "Dotfiles installed with stow."
