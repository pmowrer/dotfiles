#!/usr/bin/env bash
set -euo pipefail

required_tools=(git curl zsh stow)

install_with_brew() {
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found. Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    if [[ -x /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi

  brew install git curl ca-certificates zsh stow
}

install_with_apt_if_possible() {
  if sudo -n true >/dev/null 2>&1; then
    sudo apt-get update
    sudo apt-get install -y git curl ca-certificates zsh stow
  else
    echo "Passwordless sudo is unavailable; skipping apt package installation."
    echo "Will only verify required tools are present."
  fi
}

verify_required_tools() {
  local missing=()
  local tool

  for tool in "${required_tools[@]}"; do
    if ! command -v "$tool" >/dev/null 2>&1; then
      missing+=("$tool")
    fi
  done

  if (( ${#missing[@]} > 0 )); then
    echo "Error: missing required tool(s): ${missing[*]}" >&2
    exit 1
  fi
}

case "$(uname -s)" in
  Darwin)
    install_with_brew
    ;;
  Linux)
    install_with_apt_if_possible
    ;;
  *)
    echo "Error: unsupported platform: $(uname -s)" >&2
    exit 1
    ;;
esac

verify_required_tools

echo "All required tools are installed: ${required_tools[*]}"
