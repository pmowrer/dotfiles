---
name: pr-writing
description: Write, rewrite, or review pull request titles and descriptions so a peer reviewer understands the change before opening the diff. Use whenever the user asks to draft, groom, tighten, update, or check a PR description or title, to prepare the body for `gh pr create` or `gh pr edit`, or to bring a stale description up to date, even if they only say "write up the PR" or "the description is bad". Do not use for commit messages or review comments, and do not publish unless the user separately asks.
---

# PR writing

A reviewer who knows the system, but was not part of this work, should finish
the description knowing three things before opening the diff: what work the PR
represents, why the project needs it, and where to look hard. The description
orients the reviewer. The diff and the review thread carry the detail. Apply the
active agent instruction file's writing rules. This skill adds PR-specific
guidance.

## The failures to avoid

Agent drafts describe a change from the implementer's side, and they fail in
two opposite ways.

The compressed draft makes accurate-sounding statements about migrations,
invariants, and checks, in terms coined during the work. The reviewer still has
to read the code to learn what the PR is.

The exhaustive draft says everything the implementer knows: every column,
trigger, grant, and check, every test the change got, and every risk anyone
thought of. The point is in there, but buried. The author's edits to these
drafts are almost all cuts.

Write the way a teammate explains a change at a whiteboard. Say what exists
today and what is wrong with it, then what this PR changes and why the project
needs it, then what a reviewer could misjudge. Use plain words, the system's
real names, real examples, and numbers that come with a yardstick. Stop when the
reviewer has what they need to read the diff well.

## Gather the evidence

Read the diff against the intended base, the commits, the linked ticket and its
parent epic, the repository's PR template and PR guidance, and related PRs. Read
enough surrounding code to make every claim true on the base branch. Treat an
existing PR body as a source of links and still-valid facts, not as a shape to
preserve.

For a stacked PR, describe only this PR's delta. GitHub already shows the stack
order, base, and dependencies, so don't restate them. A prior PR may appear when
it supplies context the reader needs, for example "#123 added X, including Y.
This PR removes Y."

If the evidence undermines the PR's premise, tell the user directly and
recommend what to do. Examples: the change is a no-op, it duplicates other work,
or it does not do what the ticket asks. Don't write that doubt into the
description.

## Size the description to the change

A small, self-explanatory change needs one to three plain sentences and no
headings: what changes, and why if that isn't obvious.

A substantive change gets sections chosen for its content, typically in this
order:

1. Background, when the reader lacks context
2. Summary
3. Why
4. One or two explanatory sections named for what they explain
5. Risks
6. JIRA ticket
7. Notes

Most PRs need only some of these. Use the repository template's headings when
they exist, and drop a template section that would only hold filler. Never add
a section because an earlier PR had one; each section exists because this
change needs it.

## What each section does

**Background** explains what the relevant part of the system is, why it exists,
and how it works today, so the change makes sense. Use it when the Summary would
otherwise depend on context the reviewer lacks. A few sentences is typical.

**Summary** is the headline: one or two sentences saying what the PR allows or
changes, in behavior or capability terms, such as "Run expired service account
token cleanup every minute instead of once per hour." A short list can follow
when the change has a few distinct cases. Columns, triggers, constraints, error
codes, and file paths don't belong here. Open with the change itself or the
background it needs, not with a bare dependency such as "Builds on #123 by…".
For a large diff, one clause of orientation is enough, such as "most of the
diff is new integration tests". Don't count lines or list files.

**Why** gives the concrete need. Name the scenario that fails or can't happen
today, or show how the change fits the larger initiative, in terms a
product-aware engineer recognizes. A Why that restates the implementation is a
Summary. If the design isn't the obvious one, name the obvious approach and say
why it loses, such as on load, cost, or safety. A short paragraph is usually
enough. If the evidence supports no reason, ask the user rather than inventing
one.

**Explanatory sections** explain the one or two ideas a reviewer needs to judge
the design, headed by what they explain, for example "How the cache is notified"
or "Schema changes". They are not a changelog of every function, trigger,
constraint, or check the diff touches; the diff already shows those. Prefer
real artifacts:

- Schema changes go in a `diff` block of the affected tables, with a short
  `# comment` saying what each new or changed field means.
- Allowed and rejected combinations go in a matrix table.
- An example uses real rows or values taken from the code, fixtures, or tests.
  Never invent a presentation format or values the system can't produce.

Keep tables readable: one item per row, with the real names.

Explain an implementation choice only when a reviewer will see it in the diff
and wonder why, such as a simpler design that was rejected or a function
rewritten in another language for plan reuse. Don't narrate what the code does.

**Risks** collects more noise than any other section. Keep a risk only if a
reviewer who missed it would misjudge the PR: they would assume it ships
something it doesn't, miss a consumer that will break or log errors, or miss a
real performance, limit, or security concern. Give each risk you keep its
concrete effect and a yardstick, such as a relative change, a comparison with a
timeout or limit, or the largest real case. Leave out:

- Test coverage. "A mistake here would grant access; the tests cover A, B, and
  C" is a test list, not a risk.
- Protections carried over unchanged from earlier work. They are status quo. A
  protection this PR adds is a different matter.
- Numbers that show no problem, such as sub-millisecond lookups far under any
  limit, or a cost that appears only under a setting nobody uses.
- Routine migration mechanics such as locks, ordering, and rollback. If
  something makes them unusual, give it one sentence with a yardstick.
- Design descriptions disguised as risks.

One to three risks is typical, and none is fine.

**JIRA ticket** links the ticket.

**Notes** holds what the reviewer needs that fits nowhere above: a schema diff
or one-line change bullets when the diff is hard to read (migrations
especially), known limitations, and follow-ups. It isn't for implementation
housekeeping: how grants or owners carry over, ordering between a migration and
later setup steps, objects left in place, or coordination with other PRs such
as renumbering a migration. Raise coordination problems with the user directly.

**Test plan** is usually left out. Include a check only if a reviewer would
repeat it by hand, or if it establishes something the rest of the description
doesn't already claim. Passing-test counts, hook runs, lists of covered cases,
and restatements of the Summary's or Why's claims don't belong.

## Write plainly

- Use plain, terse full sentences or clean bullets, not fragments joined by
  semicolons. A little informality is fine.
- Use the system's real names consistently. Introduce each term or identifier
  before relying on it. Don't coin labels while drafting ("resolver", "cache
  roles", "target-aware source"). Don't put plain words in code format, where
  they look like identifiers.
- Describe what changes. Don't reassure that existing behavior stays unless a
  reviewer has a concrete reason to think it changed. Don't present an obvious
  design choice as a feature or a risk.
- Give every number a baseline and, where one applies, the limit it is measured
  against. Prefer relative change when absolute values are hard to judge.
- Describe the final change against the base branch. Leave out draft history,
  intermediate revisions, and approaches the reviewer never saw.
- Don't mention a capability as if it exists or ships when it doesn't.
- Link inline on the words that name the artifact. Prefer durable issues,
  documents, and PRs over chat links.

## Cut before reviewing

Drafts come out long, and the author's edits are mostly cuts. After drafting,
reread the draft and delete:

- What the diff shows directly: column lists, trigger and function behavior,
  grants, file paths, and line counts.
- Risks, notes, and test-plan items that fail the tests above.
- Sentences that repeat an earlier section.
- Background the reviewer already has.

Then read what remains. The Summary, Why, and explanatory sections should still
tell the reviewer what the work is, why the project needs it, and how the design
holds together. Stop cutting when removing anything more would leave a reviewer
question unanswered.

## Review before presenting

Reread the draft as the reviewer would. The author's corrections usually arrive
as a reviewer's question about one sentence, so ask these questions of every
sentence. Answer a question by making the sentence more precise or deleting it,
not by adding another sentence.

- What does this term mean? Has it been introduced, and is it the system's real
  name?
- Like what? Which ones? Replace a vague claim with the concrete case.
- Compared with what? A number needs a baseline or yardstick.
- Isn't this already true today? If so, delete it.
- Is that supported yet? Is it accurate on the base branch? Check the code.
- So what? If the reviewer gains nothing, delete it.
- Does the content answer its heading?

Then check the whole draft:

- After the first paragraph, can a reviewer say what work the PR represents?
- Does every section earn its place?
- Is anything below the explanatory sections there because the implementer
  knows it, rather than because the reviewer needs it?

## Title

Name the concrete behavior or capability, briefly, in the repository's title
convention, such as conventional commits. Prefer plain words over a long
identifier. If the PR already has a title that does this, keep it. Use the terms
the description uses, not jargon from drafting. Keep rationale, validation, and
ticket references out of the title unless the repository requires them.

## Deliver

Return the title and the full body. Drafting or revising produces prose only:
don't publish, edit the PR, post comments, or create tickets unless the user
separately asks. List any facts you couldn't verify, and ask the user for
missing ones, such as production numbers, instead of guessing.

## Examples

Before drafting a substantive description, read
[references/examples.md](references/examples.md). It holds annotated
descriptions the author wrote or approved, and before-and-after rewrites,
including what the author cut from an agent draft. Take the reasoning behind
each element. Don't copy a heading or section into a PR whose content doesn't
call for it.
