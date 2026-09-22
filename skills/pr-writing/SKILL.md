---
name: pr-writing
description: Write or revise pull request titles and descriptions for reviewers. Use for PR drafting, rewriting an existing title or body, or checking PR prose before publication. Do not use for commit messages, review comments, or publishing unless the user separately requests that action.
---

# PR writing

Write a title and description that let a reviewer understand the change before
reading the diff. Apply the active agent instruction file's writing rules; this
skill adds only PR-specific guidance.

## Establish the current change

Use the current diff against the intended base, the repository's PR template
and title conventions, and any authoritative linked issue or design document.
Treat an existing PR body as a source of links and still-valid facts, not as the
shape or length of the rewrite.

For a stacked PR, keep inherited changes out of the title and lead. Describe the
current PR's delta, then identify the upstream PR or base separately when that
dependency affects review.

If the evidence undermines the premise for the PR, tell the user what you found
and recommend what to do next. Do not hide that decision in polished PR prose.

## Write the title

Name the concrete behavior or reviewer-visible scope of this PR. Follow the
repository's established syntax when one exists. Keep rationale, validation,
ticket references, and upstream stack details in the body unless the repository
requires them in titles.

## Write the description

Lead with one or two connected sentences that say what changes and why it
matters. Omit the reason when the evidence does not support one; never invent a
benefit to complete a template.

Write for an engineer who knows the system but was not part of the private
conversation. Explain a concept before naming the field or internal identifier
that implements it. Include only constraints and details that help the reviewer
assess the change.

Follow headings requested by the user or supplied by the repository template.
Otherwise add a heading only when it helps the reviewer find information they
need. Match content to each selected heading: `Summary` explains what changes;
`Why` explains the larger initiative or purpose instead of repeating the
implementation. A small, self-explanatory change can be complete after the
opening.

Include concise validation evidence when it helps assess the change. State a
material limitation, migration effect, rollout constraint, or lasting behavior
when the reviewer cannot infer it from the diff. Use full sentences and avoid
stubby fragments joined by semicolons.

Link artifacts inline on the words that name them. Prefer durable issues,
documents, source, and related PRs over chat. Do not add a link merely because
one exists.

Use a small diagram only when relationships, ownership, or a state transition
would otherwise take more prose to explain and the target supports the format.

## Keep the artifact current and scoped

Remove draft history, abandoned rationale, stale sections, footnotes, and link
dumps. Keep the artifact focused on the final change.

A drafting or revision request produces the requested prose. Do not publish it,
post comments, create tickets, or move omitted material elsewhere unless the
user separately asks for that action.
