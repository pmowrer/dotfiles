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

  echo "All required tools are installed: ${required_tools[*]}"
}

backup_conflicting_target_if_needed() {
  local rel_path="$1"
  local target="$HOME/$rel_path"
  local expected="$REPO_ROOT/$2"
  local backup

  if [[ -L "$target" ]]; then
    if [[ "$(readlink "$target")" == "$expected" ]]; then
      return
    fi

    backup="${target}.pre-dotfiles-backup.$(date +%Y%m%d%H%M%S)"
    mv "$target" "$backup"
    echo "Backed up conflicting symlink: $target -> $backup"
    return
  fi

  if [[ -e "$target" ]]; then
    backup="${target}.pre-dotfiles-backup.$(date +%Y%m%d%H%M%S)"
    mv "$target" "$backup"
    echo "Backed up conflicting file: $target -> $backup"
  fi
}

prepare_stow_targets() {
  backup_conflicting_target_if_needed ".zshrc" "zsh/.zshrc"
  backup_conflicting_target_if_needed ".p10k.zsh" "zsh/.p10k.zsh"
  backup_conflicting_target_if_needed ".gitconfig" "git/.gitconfig"
}

install_oh_my_zsh_if_missing() {
  if [[ ! -d "$ZSH_DIR" ]]; then
    echo "Installing Oh My Zsh..."
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  mkdir -p "$ZSH_CUSTOM/plugins" "$ZSH_CUSTOM/themes"
}

clone_if_missing() {
  local repo_url="$1"
  local target_dir="$2"

  if [[ ! -d "$target_dir" ]]; then
    git clone "$repo_url" "$target_dir"
  fi
}

install_plugins_and_theme() {
  clone_if_missing "https://github.com/zsh-users/zsh-autosuggestions" "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  clone_if_missing "https://github.com/zsh-users/zsh-syntax-highlighting" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
  clone_if_missing "https://github.com/jeffreytse/zsh-vi-mode" "$ZSH_CUSTOM/plugins/zsh-vi-mode"
  clone_if_missing "https://github.com/romkatv/powerlevel10k" "$ZSH_CUSTOM/themes/powerlevel10k"
}

run_stow() {
  cd "$REPO_ROOT"
  echo "Running GNU Stow dry-run intentionally before applying links."
  echo "If conflicts exist, Stow should fail loudly so collisions can be resolved manually."
  stow -n -v -t "$HOME" zsh git
  stow -v -t "$HOME" zsh git
}

maybe_switch_shell() {
  local current_shell_name="${SHELL##*/}"
  local zsh_path

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
install_oh_my_zsh_if_missing
install_plugins_and_theme
prepare_stow_targets
run_stow
maybe_switch_shell
