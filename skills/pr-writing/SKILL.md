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
enough surrounding code to support each claim and distinguish existing behavior
from what this PR introduces. For a flag or configuration change, check the
behavior in the implementation and version it configures; a design plan alone
does not establish shipped behavior. Treat an existing PR body as a source of
links and still-valid facts, not as a shape to preserve. When feedback rejects
its focus, rebuild the description rather than line-editing it.

For a stacked PR, describe only this PR's delta. GitHub already shows the stack
order, base, and dependencies, so don't restate them. A prior PR may appear when
it supplies context the reader needs, for example "#123 added X, including Y.
This PR removes Y."

If the evidence undermines the PR's premise, tell the user directly and
recommend what to do. Examples: the change is a no-op, it duplicates other work,
or it does not do what the ticket asks. Don't write that doubt into the
description.

## Size the description to the change

Size the description by what the reviewer needs to understand, not the number
of changed lines. A small, self-explanatory change needs a short paragraph and
no headings: what changes, and why if that isn't obvious.

A flag-only diff can enable substantial behavior. Explain what becomes possible,
for which users or callers, and why the project enables it here. Naming the flag
and its new value does not explain its effect. Use another short paragraph when
the behavior needs one.

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

**Summary** tells the reviewer what the PR changes. Identify the independent
major changes before writing it. Lead with the behavior or capability, such as
"Run expired service account token cleanup every minute instead of once per
hour." Give other major changes their own plain sentence or short bullet;
don't pack them into the opening sentence to meet a sentence count.

Describe an intended capability in terms of what users or callers can now do,
including material changes in which data they can see. A lookup or source change
alone may not explain that effect. Put the capability here even when a Risk also
discusses it.

A switch in the source the code reads, the service it calls, or the messages it
consumes changes how the system works. Name that switch here, with the real
source names where they help the reviewer, even when its implementation is a
view or table. State any flag or caller restriction that limits the change.
A Risk can explain a consequence of the switch; it cannot be the only place
that tells the reader the switch happens.

Leave incidental columns, joins, error codes, file paths, measurements, and
verification to the diff or an explanatory section. Open with the change or
the background it needs, not a bare dependency such as "Builds on #123 by…".
For a large diff, "most of the diff is new integration tests" can orient the
reader. Don't count lines or list files.

**Why** gives the concrete need. Name the scenario that fails or can't happen
today, or show how the change fits the larger initiative, in terms a
product-aware engineer recognizes. Ground it in one real case from the code,
tests, or ticket, such as a specific action, request, or record the change
affects. A category on its own, such as "some users lose access", draws "Like
what?". A Why that restates the implementation is a Summary. If the design
isn't the obvious one, name the obvious approach and say why it loses, such as
on load, cost, or safety. A short paragraph is usually enough. If the evidence
supports no reason, ask the user rather than inventing one.

**Explanatory sections** explain the one or two ideas a reviewer needs to judge
the design, headed by what they explain, for example "How the cache is notified"
or "Schema changes". They are not a changelog of every function, trigger,
constraint, or check the diff touches; the diff already shows those. Prefer
real artifacts:

- Schema changes go in a `diff` block of the affected tables, with a short
  `# comment` saying what each new or changed field means. Let the block carry
  the schema. After it, add at most one plain sentence on what it enforces;
  don't restate its keys, constraints, or triggers in prose.
- Allowed and rejected combinations go in a matrix table.
- An example uses real rows or values taken from the code, fixtures, or tests.
  Never invent a presentation format or values the system can't produce.

Keep tables readable: one item per row, with the real names.

Explain an implementation choice only when a reviewer will see it in the diff
and wonder why, such as a simpler design that was rejected or a function
rewritten in another language for plan reuse. Don't narrate what the code does.

When the mechanism is the point, as in a performance or correctness fix, explain
it at the depth of a teammate who hasn't read this code: what the work has to
do, what made it slow or wrong, and what changed. Describe each object by what
it is ("a combined list of active and archived workspaces"), not by its
identifier. Say what the engine does in plain words ("it scans the whole list
once per row") rather than in its own terms ("nested loop", "can't flatten the
UNION member"). Round counts are enough. Name the section for the reader's
question, such as "What made the view slow", not for the code.

**Risks** collects more noise than any other section. Keep a risk only if a
reviewer who missed it would misjudge the PR: they would assume it ships
something it doesn't, miss a consumer that will break or log errors, or miss a
real performance, limit, or security concern. Give each risk you keep its
concrete effect and a yardstick, such as a relative change, a comparison with a
timeout or limit, or the largest real case. Make each risk self-contained:
name the affected behavior and the concrete concern, so the reader does not
have to infer its connection to the Summary. Leave out:

- Test coverage. "A mistake here would grant access; the tests cover A, B, and
  C" is a test list, not a risk.
- Protections carried over unchanged from earlier work. They are status quo. A
  security change this PR introduces is a different matter: say who can reach
  it and why that is safe, for example which roles can run a new privileged
  path.
- Numbers that show no problem, such as sub-millisecond lookups far under any
  limit, or a cost that appears only under a setting nobody uses.
- Routine migration mechanics such as locks, ordering, and rollback. If
  something makes them unusual, give it one sentence with a yardstick.
- Design descriptions or unimplemented alternatives with no established
  limitation or harmful outcome.

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
  semicolons or commas. A little informality is fine. Terse means words the
  reader parses once, not fewer sentences: two plain sentences beat one
  compressed one.
- Say who does what, with the real actor as the subject: "Clients choose the
  response language with the `Accept-Language` header", not "the
  language a request names in `Accept-Language`". Don't hang a clause off a noun
  without "that" or "which", don't stack "of" phrases, and don't give objects
  people's verbs ("a request names", "every request acts in").
- Say what a structure holds and what that changes, not its shape: "the proxy
  keeps the latest saved version of each document", not
  "one cache entry per document at its latest version".
- Plain doesn't mean broader. When you simplify a claim, keep the limits on who
  or what it covers, such as which credential, which kind of account, or which
  flag state: "with self-service exports enabled, signed-in users can export
  search results; API keys cannot start exports", not "clients can export".
- Use the system's real names consistently. Introduce each term or identifier
  before relying on it. Don't coin labels while drafting ("resolver", "cache
  roles", "target-aware source"). A word inside an identifier isn't a term the
  reader knows: call a role named `billing_writer` by that name, not "the
  writer". Don't put plain words in code format, where they look like
  identifiers. A version or PR number is not an explanation: say what relevant
  behavior it supplies, or cut it.
- Describe what changes. Don't reassure that existing behavior stays unless a
  reviewer has a concrete reason to think it changed. Keep unchanged behavior
  when it defines a boundary of the new capability, such as excluded callers
  or requests without the new input. A refactor or performance change keeps its
  results by definition, so don't say it does or report the
  parity checks. Don't present an obvious design choice as a feature or a
  risk.
- Give every number a baseline and, where one applies, the limit it is measured
  against. Prefer relative change when absolute values are hard to judge.
- Every number and table row should show a difference the reader cares about.
  Cut a row that barely differs from its neighbor, and leave out how the numbers
  were measured unless the method changes how to read them. If the numbers
  raise an obvious question, such as one environment not improving, answer it
  in a few plain sentences.
- Describe the final change against the base branch. Leave out draft history,
  intermediate revisions, and approaches the reviewer never saw.
- Don't mention a capability as if it exists or ships when it doesn't.
- Link inline on the words that name the artifact. Prefer durable issues,
  documents, and PRs over chat links.

## Cut before reviewing

Drafts come out long, and the author's edits are mostly cuts. After drafting,
reread the draft and delete:

- Inventories of columns, functions, grants, paths, and line counts that add
  no explanation beyond the diff. Keep major source or contract changes and
  the artifacts that explain behavior: a boundary table can make allowed and
  rejected combinations clear in a way that a paragraph cannot. Cut prose
  that repeats the table rather than cutting the table for brevity.
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
sentence. Make it more precise, split it when it carries several ideas, or
delete it when the reviewer gains nothing. Preserve the limits on who or what
it describes when you split or shorten it.

- What does this term mean? Has it been introduced, and is it the system's real
  name?
- Like what? Which ones? Replace a vague claim with the concrete case.
- Compared with what? A number needs a baseline or yardstick.
- Isn't this already true today? Keep it only if it explains a boundary the
  reviewer could otherwise misunderstand.
- Is that supported yet? Is it accurate on the base branch? Check the code.
- So what? If the reviewer gains nothing, delete it.
- Can you read it aloud once without backing up? If not, split it and put the
  actor first.
- Could a teammate who hasn't read this code follow it? If not, describe the
  thing in plain words instead of its identifiers and internals.
- Does the content answer its heading?

Then check the whole draft:

- After the first paragraph, can a reviewer say what work the PR represents?
- Does the Summary cover each major change, or is one disclosed only in Risks
  or Notes? Check against the changes you identified before drafting.
- Does every section earn its place?
- Is anything below the explanatory sections there because the implementer
  knows it, rather than because the reviewer needs it?

## Title

Name the concrete behavior or capability, briefly, in the repository's title
convention, such as conventional commits. Prefer plain words over a long
identifier, and don't compress a mechanism into the title ("serve the language
a request names in Accept-Language"). If the PR already has a title that does this, keep it. Use the terms
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

For a small flag or configuration change, read
[example 10](references/examples.md#10-a-one-line-flag-change-that-enables-a-capability)
for explaining enabled behavior without recapping deployment history.
