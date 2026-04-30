#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ZSH_DIR="$HOME/.oh-my-zsh"
ZSH_CUSTOM="${ZSH_DIR}/custom"
required_tools=(git curl zsh stow gh lazygit)
brew_packages=(git curl zsh stow gh lazygit claude-code)

brew_command_for_package() {
  local package="$1"

  case "$package" in
    claude-code)
      echo "claude"
      ;;
    *)
      echo "$package"
      ;;
  esac
}

install_with_brew() {
  local brew_bin=""

  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found. Installing Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  if brew_bin="$(command -v brew 2>/dev/null)"; then
    eval "$("$brew_bin" shellenv)"
  elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  elif [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  else
    echo "Error: Homebrew installation completed, but brew was not found on PATH." >&2
    exit 1
  fi

  local packages_to_install=()
  local package
  local command_name

  for package in "${brew_packages[@]}"; do
    command_name="$(brew_command_for_package "$package")"

    if command -v "$command_name" >/dev/null 2>&1; then
      echo "Found $command_name on system; skipping brew install for $package."
    else
      packages_to_install+=("$package")
    fi
  done

  if (( ${#packages_to_install[@]} > 0 )); then
    brew install "${packages_to_install[@]}"
  else
    echo "All Homebrew-managed tools are already available; skipping brew install."
  fi
}

self_heal_managed_files() {
  # Coder workspace restores have been observed to truncate files in this
  # repo to zero bytes (s3 streaming flakiness). The Coder template's
  # install_direnv script then writes the direnv hook through the still-valid
  # symlinks back into our stowed files, leaving them as a single-line
  # `eval "$(direnv hook ...)"`. That breaks the next interactive shell.
  #
  # Detect that exact pattern — uncommitted modifications to files we manage —
  # and restore them from HEAD before we proceed. Then attempt a fast-forward
  # to origin so HEAD is itself up to date. --ff-only means we never clobber
  # legitimate local commits; we only undo the corruption.
  cd "$REPO_ROOT"

  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    return
  fi

  local managed=(zsh/.zshrc zsh/.zprofile zsh/.p10k.zsh git/.gitconfig)
  local dirty=()
  local f

  for f in "${managed[@]}"; do
    if [[ -e "$f" ]] && ! git diff --quiet -- "$f" 2>/dev/null; then
      dirty+=("$f")
    fi
  done

  if (( ${#dirty[@]} > 0 )); then
    echo "Detected uncommitted modifications in managed files: ${dirty[*]}"
    echo "Likely Coder workspace-restore corruption; restoring from HEAD."
    git checkout -- "${dirty[@]}"
  fi

  local branch
  branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  if [[ -n "$branch" && "$branch" != "HEAD" ]]; then
    if git fetch --quiet origin "$branch" 2>/dev/null; then
      git merge --ff-only "origin/$branch" 2>/dev/null \
        || echo "Could not fast-forward to origin/$branch; staying on local HEAD."
    fi
  fi
}

apt_update_if_possible() {
  if sudo -n true >/dev/null 2>&1; then
    sudo apt-get update
  else
    echo "Passwordless sudo is unavailable; skipping apt metadata update."
    echo "Will continue with Homebrew package installation and tool verification."
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
    if [[ "$target" -ef "$expected" ]]; then
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

self_heal_managed_files

case "$(uname -s)" in
  Darwin)
    install_with_brew
    ;;
  Linux)
    apt_update_if_possible
    install_with_brew
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
