# dotfiles

Personal dotfiles managed with GNU Stow, with bootstrap automation in `install.sh`.

## Repository structure

- `install.sh` – bootstrap script that installs dependencies (including `gh` and `lazygit`), installs Oh My Zsh + plugins/themes, runs Stow, and optionally switches your login shell.
- `zsh/` – Zsh-related dotfiles (for example `.zshrc`, `.p10k.zsh`).
- `git/` – Git-related dotfiles (for example `.gitconfig`).
- `ghostty/` – Ghostty terminal config under `.config/ghostty/config` (works on macOS and Linux; ignored if Ghostty is not installed).
- `scripts/configure-codex-defaults.sh` – preserves the existing Codex config while making Vim mode the default for new sessions.
- `scripts/configure-claude-defaults.sh` – same idea for Claude Code: merges `"editorMode": "vim"` into `~/.claude/settings.json` without disturbing the rest of the file.
- `skills/` – agent skills shared by Claude Code and Codex, one directory per skill.
- `claude/` – Claude Code instructions under `.claude/CLAUDE.md`.
- `codex/` – Codex instructions under `.codex/AGENTS.md`.
- [`docs/terminal-browser.md`](docs/terminal-browser.md) – recovery guide for running terminal-browser on a headless Ubuntu 24.04 Coder workspace.

These package names match their Stow targets so this command works as-is:

```bash
stow -t "$HOME" zsh git ghostty claude codex
```

## Supported targets

- **macOS**: uses **Homebrew** for package installation.
- **Ubuntu 24.04** (and similar Debian/Ubuntu Linux): runs `apt-get update` when passwordless sudo is available, then uses **Homebrew** for package installation.
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

On Linux, the installer attempts `apt-get update` **only when passwordless sudo is available**.

- If passwordless sudo exists: runs `sudo apt-get update` to refresh existing apt metadata. A failure (including lock contention with another Coder startup task) is logged but does not stop the Homebrew bootstrap.
- If not: apt update is skipped.

In both cases, package installation is handled by Homebrew, Homebrew's confirmation prompts are disabled for unattended Coder startup, and required tools are verified afterwards.

Before running `brew install`, the installer checks whether each managed tool is already available on `PATH` and only installs missing tools with Homebrew.

### Stow dry-run, then apply

The installer intentionally runs Stow twice:

1. Dry-run with verbose output (`stow -n -v ...`)
2. Actual apply (`stow -v ...`)

This gives you an explicit preflight check before links are created.

### Codex Vim mode

The installer sets `tui.vim_mode_default = true` in `~/.codex/config.toml`, so each new Codex session starts in Vim normal mode. Existing Codex settings are preserved, including machine-local project trust, MCP server, and hook state; the updater is idempotent and does not replace the whole config with a Stow symlink.

### Claude Code Vim mode

The installer sets `"editorMode": "vim"` in `~/.claude/settings.json` (or `$CLAUDE_CONFIG_DIR/settings.json`), so each new Claude Code session starts in Vim normal mode. `Esc` enters normal mode, `i` returns to insert.

Claude Code owns this file and rewrites it when you change settings from inside the TUI, and other tooling adds hooks and status lines to it, so it is merged with `jq` rather than stowed. Existing keys are preserved and the updater is idempotent. Toggling with `/vim` inside a session writes the same key, so the two stay consistent.

### Shared agent skills

Claude Code and Codex both discover skills as `<config-dir>/skills/<name>/SKILL.md`
and read the same frontmatter, so one source directory serves both. `skills/`
holds them, and `link_agent_skills` symlinks each one into `~/.claude/skills/`
and `~/.codex/skills/`.

This is the one thing Stow cannot express: two targets resolve to the same
source, which a package tree cannot mirror. The installer links the skill
*directory* rather than its files, so adding a file to a skill needs no re-run.

Write skill bodies agent-neutrally, since both agents read the same text. A
skill may still carry agent-specific metadata beside it — `rfc-writer` ships
an `agents/openai.yaml` that only Codex reads — and if one ever has to diverge
outright, install per-agent variants instead of branching inside the body.

Skills installed by other tools are left alone. `terminal-browser` symlinks
itself into both config directories from its own install prefix, and is not
managed here.

### Agent instruction files

`~/.claude/CLAUDE.md` and `~/.codex/AGENTS.md` are stowed from `claude/` and
`codex/`. Both agents load their file into every session, so these files hold
*pointers* to the runbooks under `docs/` rather than copies of their contents.
Keeping the runbook in one place avoids the copies drifting apart, and keeps a
long machine-specific document out of every unrelated conversation.

The pointers reference `~/.dotfiles`, which the installer maintains as a
symlink to wherever this repo is checked out. Without it the pointers would
have to hardcode the Coder clone path (`~/.config/coderv2/dotfiles`), which is
wrong on any other machine.

Both files hold identical content. They are short enough that duplicating them
is cheaper than a shared file plus in-repo symlinks.

Note that `~/.claude/CLAUDE.md` is writable by Claude Code: asking it to
remember something appends to this file, so those additions land in this repo
as ordinary uncommitted changes.

### Conflict handling

Before running Stow, the installer backs up only the managed targets (`~/.zshrc`, `~/.p10k.zsh`, `~/.gitconfig`, `~/.config/ghostty/config`, `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`) when they are regular files or conflicting symlinks, using a `.pre-dotfiles-backup.<timestamp>` suffix. Symlinks that already resolve to the expected dotfiles target are treated as non-conflicting (even if their link text is relative).

Stow still fails loudly for any other collision so unexpected conflicts are not auto-overwritten.

### Idempotency guarantees

The installer is designed to be safely re-runnable:

- Existing Homebrew installations are detected in their standard prefixes even when the calling process has not initialized Homebrew's `PATH`.
- Dependency installation is naturally idempotent (`brew install` for already-installed packages; Linux may also refresh apt metadata with `apt-get update`).
- Homebrew installation is minimized by skipping packages whose corresponding commands are already available on the system.
- Oh My Zsh install only runs if `~/.oh-my-zsh` does not already exist.
- Plugin/theme repositories are only cloned when their target directories are missing.
- Stow operations can be re-run to keep symlinks aligned with repo contents.
- The `~/.dotfiles` symlink is only rewritten when it points somewhere else, and is left alone if a real file or directory occupies that path.
- Skill links are only created when missing; a correct link is left as-is, and anything else occupying the name is backed up first.
- The Codex config updater only changes the Vim-mode default and leaves an already-correct config untouched.
- The Claude Code settings updater behaves the same way, and refuses to write if `settings.json` is not valid JSON.

### `CODER=true` behavior

If `CODER=true` is set in the environment, `install.sh` skips `chsh` shell switching.

This is useful in remote/devcontainer/Coder setups where changing login shell is not desirable or not permitted.
