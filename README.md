# dotfiles

Managed with GNU Stow using package directories.

## Layout

- `zsh/.zshrc`
- `zsh/.p10k.zsh`
- `git/.gitconfig`

These package names are intentionally `zsh` and `git` so this command works as-is:

```bash
stow -t "$HOME" zsh git
```

## Install

From the repo root:

```bash
./install.sh
```

This script validates that `stow` is installed and then runs `stow -t "$HOME" zsh git`.

## User-specific settings

For machine/user-local shell settings that should not be committed, create:

```bash
~/.zshrc.<username>
```

It is sourced automatically from `.zshrc` when present.
