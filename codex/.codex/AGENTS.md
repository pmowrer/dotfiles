# Agent instructions

Managed by the dotfiles repo (`~/.dotfiles`). Keep this file short: it is loaded
into every session, so it holds pointers rather than content.

## Workspace runbooks

Machine-specific setup that is known-working on this workspace is documented in
`~/.dotfiles/docs/`. Read the relevant file before debugging these tools:

- `docs/terminal-browser.md` — terminal-browser on headless Coder workspaces:
  software rendering, AppArmor, and why the visible browser must be launched
  from a Ghostty/Kitty pane rather than from an agent session.
