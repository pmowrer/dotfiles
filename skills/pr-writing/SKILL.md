---
name: pr-description
description: House style for a pull request body. Use when writing a description before `gh pr create`, and equally when revising one — `gh pr edit --body`, "update/rewrite the PR description", correcting a body after a fact it relied on changed, or reworking a draft you wrote earlier in this session. Not for commit messages or the PR title.
---

# PR descriptions

The `## Writing` rules in the agent instruction file (`~/.claude/CLAUDE.md`
or `~/.codex/AGENTS.md`) govern the prose and are not repeated here. This
skill adds what is specific to a PR body.

## What it is for

A PR description orients a reviewer enough that they can start reading the diff.
It is not a design document, an incident writeup, or a defense of the change.

A reviewer needs the same orientation whether the diff is 20 lines or 2,000, so
size tracks how much the reader cannot see, not how much work went in. Once the
reader knows what changed, what it affects, and why, the description is finished.
Reviewers ask for the rest in review.

## Structure

Always: one or two sentences at the top saying what the change does.

`## Background` and `## Why` carry the context and the reason when the reader
needs them. When the user asks for those sections, or hands you their wording,
that is the format: write to it and do not argue it down to something shorter.
Otherwise include each only when it supplies something the reader lacks — a
small, self-explanatory change is complete as its opening sentences.

Any other section needs the repo's `.github/PULL_REQUEST_TEMPLATE.md` to ask for
it, or the user to ask by name — never a heading coined for material with nowhere
else to go. With a template, follow its layout and fold this content into the
sections it already provides.

Where a section appears, give it the one fact or reason the reader cannot do
without, in a sentence or two.

## What the body owes the reader

The reader has the diff, the title, and nothing else. Every term, system, and
constraint the description leans on is explained, linked, or dropped.

- Never invent a benefit to fill a section. When the reason the change was
  started does not survive contact with the facts, say what the change does and
  stop.
- Stay truthful about what the change actually configures or enables, and about
  consequences a reviewer needs: a limitation that survives the merge, an effect
  outside the diff. Put those where they read naturally — no rule promotes them
  to the lead.
- Describe a matching default neutrally, as configuration. "Inert", "no-op" and
  "does nothing" are judgments about whether the change should exist, and the
  body is not where that gets settled — for or against.

## When the facts undermine the work

If what you learn while writing means the change may not be needed — the behavior
already exists, the premise was wrong, the fix is redundant — tell the user
directly: the finding, and your recommendation. That is the deliverable.

Do not write the doubt into the description, and do not file it as a comment or a
ticket instead — that leaves the decision unmade, somewhere the user may never
read.

## Your reasoning is not the artifact

Alternatives you dropped, a correction that redirected you, questions you have
not settled — that reasoning earns its keep by deciding which fact leads and
which reason you give. Facts about the change go in the body, as above; your
route to it does not.

**There is no overflow.** What the reader needs is in the description. What they
do not need is left out, and left out means gone, not relocated. A PR comment is
for follow-up discussion with reviewers — not an appendix, a second installment,
or a home for prose cut from the body.

So a drafting request stays a drafting request. Asked to shorten a description,
you are done when the description is shorter: it produces no comment, no ticket,
no follow-up task, and no decision handed back to the user. The one exception is
above — a finding that the work itself may not be needed goes straight to the
user.

## Revising a body, including your own draft

Rewrite from the current diff, not from the body on the page. This applies as
much to a draft you wrote an hour ago as to one you inherited: your own earlier
text is not a baseline, and a fact corrected since you wrote it makes that text a
worse starting point, not a better one.

- The published body has no memory. Whoever reads it sees one version, and never
  saw the draft, the premise the PR was opened on, or the correction. A phrase
  like "the rationale this change was opened on" is only producible by editing
  the old text — writing from the diff cannot generate it.
- Harvest the old body's ticket and doc links, and any fact that still earns a
  place. Drop the rest, including whole sections of accurate content, and carry
  over none of its length, headings, or level of detail.
- Delete link machinery it left behind: reference-style definitions, footnotes,
  bot-inserted link dumps.

## References

- Link every artifact you mention, inline, on the words that name it — Jira
  issues, Confluence pages, Google Docs, design docs, RFCs, upstream issues,
  related PRs, commits — and never leave a bare ticket key or doc title unlinked
  when a URL exists. No footnotes, reference-style definitions, or link dumps.
- Being linkable is not a reason to mention something. Three tickets cited
  because all three have URLs is bloat.
- Prefer durable references — ticket, doc, upstream source — over chat threads.
  Do not quote or attribute internal discussion.
- With no link available for a claim, state the claim plainly rather than
  gesturing at a source the reader cannot open.

## Examples

Each shows one behavior. Their technical content is scenery — do not carry facts
out of them into a real description.

**Nothing to add beyond the change itself.**
Title: `fix(ci): Raise lint job timeout to 20 minutes`

```markdown
Raises the `lint` job timeout from 10 to 20 minutes. The job began hitting the
old limit once the type-check pass moved into it.
```

**A reason the diff cannot show.**
Title: `Retry node drain on transient API errors`

```markdown
Node drains now retry evictions that fail with a retryable API error instead of
failing the drain outright.

## Background

`drain-controller` calls the eviction API once per pod and treats any non-200 as
terminal, marking the node `DrainFailed`. The Kubernetes API returns 429 and 503
routinely once a maintenance window puts several hundred pods in flight, so
healthy drains fail and an operator retries them by hand.

## Why

Manual retries stall maintenance windows and are the largest single source of
pages for the drain path. [PLAT-4821](https://example.atlassian.net/browse/PLAT-4821)
tracks the work.
```

**A large diff gets the same size, not more.** 241 added lines across three
files. Background states how the thing works today, in one line; Why states the
gap, directly. The work behind it also settled which metric the rules had to read
and identified follow-up work; neither is here.
Title: `feat(monitoring): Page on WAL-archive stalls and missing backups`

```markdown
Adds two paging alerts for the primary database: one when WAL stops reaching the
backup bucket, one when there is no usable base backup.

## Background

The database is backed up with twice-daily base backups plus a WAL archive.

## Why

If backups stopped working, nobody would know. These two alerts close the gap.
```

**The original rationale did not survive.** Opened to bound a recovery point
believed to be unbounded; the operator already applies that bound. The finding
and a recommendation go to the user first — that conversation is the real
deliverable. If the change still lands, the body says what it configures and
names the default it matches, without a `## Why` it cannot honestly fill and
without arguing the change's worth either way.
Title: `feat(db): Make archive_timeout configurable and pin QA to five minutes`

```markdown
Adds an `archiveTimeout` chart value for the Postgres cluster and sets it to five
minutes in QA, matching the operator's default for an unset `archive_timeout`.
```
