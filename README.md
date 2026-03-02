# dotfiles

Personal dotfiles managed with GNU Stow, with bootstrap automation in `install.sh`.

## Repository structure

- `install.sh` – bootstrap script that installs dependencies, installs Oh My Zsh + plugins/themes, runs Stow, and optionally switches your login shell.
- `zsh/` – Zsh-related dotfiles (for example `.zshrc`, `.p10k.zsh`).
- `git/` – Git-related dotfiles (for example `.gitconfig`).

These package names are intentionally `zsh` and `git` so this command works as-is:

```bash
stow -t "$HOME" zsh git
```

## Supported targets

- **macOS**: uses **Homebrew** for package installation.
- **Ubuntu 24.04** (and similar Debian/Ubuntu Linux): uses **apt** when passwordless sudo is available.
- **Coder-compatible**: supports `CODER=true` environments (skips shell switching).

## Quickstart

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

## Installation behavior and notes

### Non-interactive Oh My Zsh install

If `~/.oh-my-zsh` is missing, the installer runs Oh My Zsh in non-interactive mode:

- `RUNZSH=no` (do not launch zsh immediately)
- `CHSH=no` (do not change shell during OMZ install)
- `KEEP_ZSHRC=yes` (do not overwrite existing `.zshrc`)

### Sudo / no-sudo behavior on Linux

On Linux, package install is attempted with apt **only when passwordless sudo is available**.

- If passwordless sudo exists: installs required packages via `sudo apt-get ...`.
- If not: package install is skipped, and the script only verifies required tools are already installed.

If required tools are missing after verification, the script exits with an error.

### Stow dry-run, then apply

The installer intentionally runs Stow twice:

1. Dry-run with verbose output (`stow -n -v ...`)
2. Actual apply (`stow -v ...`)

This gives you an explicit preflight check before links are created.

### Conflict handling

If Stow detects file collisions/conflicts, it fails loudly so you can resolve them manually.

Typical resolution workflow:

1. Back up or remove conflicting files in `$HOME`.
2. Re-run `./install.sh`.

### Idempotency guarantees

The installer is designed to be safely re-runnable:

- Dependency installation is naturally idempotent (`brew install` / `apt-get install` for already-installed packages).
- Oh My Zsh install only runs if `~/.oh-my-zsh` does not already exist.
- Plugin/theme repositories are only cloned when their target directories are missing.
- Stow operations can be re-run to keep symlinks aligned with repo contents.

### `CODER=true` behavior

If `CODER=true` is set in the environment, `install.sh` skips `chsh` shell switching.

This is useful in remote/devcontainer/Coder setups where changing login shell is not desirable or not permitted.

## User-specific settings

For machine/user-local shell settings that should not be committed, create:

```bash
~/.zshrc.<username>
```

It is sourced automatically from `.zshrc` when present.
