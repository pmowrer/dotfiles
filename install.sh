#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ZSH_DIR="$HOME/.oh-my-zsh"
ZSH_CUSTOM="${ZSH_DIR}/custom"

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

if [[ ! -d "$ZSH_DIR" ]]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

mkdir -p "$ZSH_DIR" "$ZSH_CUSTOM/plugins" "$ZSH_CUSTOM/themes"

clone_if_missing() {
  local repo_url="$1"
  local target_dir="$2"

  if [[ ! -d "$target_dir" ]]; then
    git clone "$repo_url" "$target_dir"
  fi
}

clone_if_missing "https://github.com/zsh-users/zsh-autosuggestions" "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone_if_missing "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
clone_if_missing "https://github.com/jeffreytse/zsh-vi-mode" "$ZSH_CUSTOM/plugins/zsh-vi-mode"
clone_if_missing "https://github.com/romkatv/powerlevel10k.git" "$ZSH_CUSTOM/themes/powerlevel10k"

cd "$REPO_ROOT"
echo "Running GNU Stow dry-run intentionally before applying links."
echo "If conflicts exist, Stow should fail loudly so collisions can be resolved manually."
stow -n -v -t "$HOME" zsh git
stow -v -t "$HOME" zsh git

current_shell_path="${SHELL:-}"
current_shell_name="${current_shell_path##*/}"
zsh_path="$(command -v zsh)"

if [[ "$current_shell_name" == "zsh" ]]; then
  echo "Current login shell is already zsh; skipping chsh."
elif [[ "${CODER:-}" == "true" ]]; then
  echo "CODER=true detected; skipping chsh in this environment."
else
  echo "Attempting to set login shell to zsh..."
  if chsh -s "$zsh_path"; then
    echo "Login shell updated to zsh."
  else
    echo "Unable to change login shell automatically."
    echo "Run this command manually if you want to switch: chsh -s \"$zsh_path\""
  fi
fi
