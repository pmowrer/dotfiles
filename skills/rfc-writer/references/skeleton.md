# RFC Skeleton

Read this reference when creating a new RFC skeleton or revising its structure.

## What the skeleton must accomplish

A useful skeleton lets a reviewer inspect the argument before spending attention on prose. It should reveal:

- the exact decision or recommendation
- why a decision is needed now
- the current state and the proposed change
- the important constraints and scope boundaries
- the expected benefits and how they would be recognized
- the strongest realistic alternatives and their tradeoffs
- the evidence already available and the evidence still needed
- the few unresolved questions that could change the decision

Write topic-specific stubs. `Describe the problem` is an empty prompt; `Need — release rollback requires three manual handoffs; quantify incident frequency from the deployment dashboard (TBD source)` exposes a claim and its missing support.

## Default anatomy

Use only the parts that serve the decision.

### Title and metadata

Use a decision-oriented title. Include a compact metadata block when the information is known:

- Author or directly responsible owner
- Decision owner
- Reviewers or affected groups
- Status
- Last updated or review date
- Revisit date or trigger, when the decision should be tested later

Do not invent people or dates. Keep unknown fields visibly `TBD`, or omit fields that do not help this RFC.

### Decision summary

State the proposed decision in one or two provisional sentences. Make the actor, action, scope, and intended outcome explicit. If no recommendation exists yet, state the decision to be made and the leading options.

### Need

Cover the current problem, affected people or systems, why it matters now, evidence, and governing constraints. Ground the section in the organization's actual situation rather than generic industry claims.

Useful stub roles include:

- `Problem —` the observable condition or failure
- `Impact —` who or what is affected and how
- `Evidence —` an inspectable source, or a clearly marked evidence gap
- `Why now —` the trigger, deadline, growth point, incident, or newly available capability
- `Constraint —` a non-negotiable boundary

### Approach

Explain enough of the current state to make the proposed change legible, then show the proposed state and the delta between them. Keep this at the level of what and why.

For architectural changes, consider `Current state` and `Proposed state` subsections with simple bird's-eye diagrams. A diagram should expose components and relationships that would otherwise take several paragraphs to explain.

Useful stub roles include:

- `Current —` the relevant baseline, not a full system tour
- `Proposal —` the recommended model or policy
- `Delta —` what changes and what remains unchanged
- `Boundary —` non-goals and deliberate exclusions
- `Feasibility —` only the implementation facts necessary to trust the proposal
- `Unknown —` a question that could alter the approach

### Benefits

Name the concrete outcomes and beneficiaries. Replace adjectives such as “scalable,” “simple,” or “maintainable” with observable effects. Quantify when practical; label projections as estimates or hypotheses.

Useful stub roles include:

- `Outcome —` the change expected if the proposal works
- `Measure —` a metric, signal, or qualitative observation that would demonstrate it
- `Beneficiary —` the people or systems receiving the benefit
- `Assumption —` what must be true for the benefit to materialize

### Competition or alternatives

Start with doing nothing. Add only serious alternatives a reasonable decision-maker might choose. Give each alternative a descriptive subheading and cover:

- its strongest good-faith case
- the conditions under which it would be preferable
- its material tradeoffs
- why the proposal is preferred under the current constraints

Do not manufacture weak options merely to make the recommendation look inevitable.

## Conditional sections

Add these only when they materially improve the decision:

- `Goals and non-goals` when scope is disputed or easy to misread
- `Requirements or principles` when several approaches must be tested against shared criteria
- `Risks and mitigations` when downside, reversibility, or failure modes may change the choice
- `Security, privacy, compliance, or accessibility` when these are decision dimensions
- `Operational impact, migration, or rollout` when adoption cost or sequencing affects feasibility; keep it high level unless implementation planning was requested
- `Success and revisit plan` when the decision should be measured, reversed, or revisited at a trigger
- `Open questions` for unresolved items that matter to approval
- `Further reading` or `Appendix` for optional deep dives that would interrupt the core argument

## Stub grammar

Use short labeled fragments where labels improve scanning. Choose only the roles needed for that section:

```markdown
## Need

- Problem — <specific provisional claim>
- Evidence — <source or TBD evidence gap>
- Constraint — <boundary that shapes the choice>
- Alignment check — <question reviewers must agree on>
```

Other useful labels are `Decision`, `Current`, `Proposal`, `Delta`, `Outcome`, `Measure`, `Assumption`, `Risk`, `Tradeoff`, `Unknown`, and `Reviewer check`.

Keep each bullet atomic: one claim, source, boundary, or question. Avoid paragraph-length bullets, repeated setup, and generic prompts. Use descriptive headings instead of fragile numbering unless the user wants numbered sections.

## Alignment gate

Conclude with up to three questions that would cause structural change, such as:

- Is this the right decision boundary, or should two decisions be separated?
- Is any affected audience or governing constraint missing?
- Are these the alternatives reviewers will genuinely want compared?

Do not spend the alignment gate on wording preferences or facts that can safely remain `TBD`. The next pass should revise the skeleton, not begin prose, unless the user explicitly approves expansion.
