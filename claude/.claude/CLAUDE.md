# Agent instructions

Managed by the dotfiles repo (`~/.dotfiles`). Keep this file short: it is loaded
into every session. Prefer pointers over content, and inline only rules that
have to apply without being looked up first.

## Writing

For anything a person reads: code comments, commit messages, PR descriptions,
tickets, docs, chat.

- Active voice, present tense.
- The reader was not in this session. Describe the thing, not your changing
  understanding of it — no "as discussed", no rationale you have since dropped.
  History of the system earns its place; history of the draft does not. A
  discovery that undermines the point of the work is not content for the
  artifact: take it to whoever owns the work, with a recommendation.
- Cut what the reader can reconstruct from what is already in front of them.
- One idea per paragraph. Name the specific error, limit, or caller. Length is
  not evidence of rigor.

### Code comments

The reader has the code, so a comment earns its place only by saying what the
code cannot: why this and not the obvious alternative, a constraint imposed from
outside, a gotcha waiting for the next editor.

- Default to deleting a redundant comment rather than rewriting it. A shorter
  restatement of what the code already says is not a fix.
- Explain the decision at this site, not the domain. Do not restate upstream
  documentation — link it instead.
- No line-by-line narration of the implementation, and no dating the comment
  against a change ("now uses", "changed this to", "previously").
- Keep it proportional — four lines of prose on a one-line default is a smell.

## Workspace runbooks

Machine-specific setup that is known-working on this workspace is documented in
`~/.dotfiles/docs/`. Read the relevant file before debugging these tools:

- `docs/terminal-browser.md` — terminal-browser on headless Coder workspaces:
  software rendering, AppArmor, and why the visible browser must be launched
  from a Ghostty/Kitty pane rather than from an agent session.
