# RFC Prose and Review

Read this reference when expanding an approved skeleton, editing substantive RFC prose, or performing preflight review.

## Expand from the skeleton

Treat the aligned skeleton as the shared contract. Expand only the requested section set and preserve its decision, scope, claims, evidence needs, alternatives, and open issues.

For each section:

1. Open with the section's substantive thesis, not generic scene-setting.
2. Connect context, claim, evidence, implication, and recommendation in a clear causal chain.
3. Use specific actors, systems, conditions, and outcomes.
4. Distinguish observed facts, sourced claims, estimates, assumptions, and recommendations.
5. End when the section has done its job; do not restate the same conclusion in new words.

Write primarily in sentences and paragraphs. Bullets are appropriate for actual sets, requirements, sequences, or compact factual comparisons. They should not substitute for the reasoning between claims.

If prose expansion exposes a new material decision, constraint, scope boundary, risk, or alternative, pause the affected section. Present the proposed skeleton delta and explain why it matters before incorporating it.

## Prose quality

- Prefer direct assertions with explicit support over hedged, generic exposition.
- Make every paragraph advance the decision. Remove background the intended reader already knows unless it is necessary to understand the delta.
- Avoid unsupported claims such as “industry standard,” “best practice,” “future-proof,” or “more scalable.” Replace them with evidence, a bounded prediction, or an explicit assumption.
- Use calibrated language: facts are factual; estimates and speculation are labeled; uncertainty remains visible.
- Explain implementation detail only when it changes the assessment of feasibility, cost, risk, or reversibility.
- Keep citations adjacent to the claims they support and point to inspectable underlying material.
- Do not cite an AI conversation or AI-generated summary as the end of an evidence chain.

As a default, aim for a core argument that a reviewer can engage with in one sitting. Prefer roughly 1,500–2,000 words and treat 2,500 words as a soft ceiling unless the user, template, or subject requires otherwise. Put supporting data, deep examples, and implementation plans in appendices or linked artifacts.

## Alternatives quality

For each alternative, including doing nothing:

1. State why a reasonable person would choose it.
2. State when it would outperform the proposal.
3. Describe its real cost or limitation under the present constraints.
4. Explain the preference without caricaturing the alternative.

If the proposal still looks inevitable after this exercise, check whether selection criteria were chosen after the fact or important context is missing.

## Preflight review

Classify findings so revisions remain easy:

- `Structure` — wrong decision boundary, missing or misplaced section, absent alternative, or unresolved dependency
- `Reasoning` — unsupported inference, missing causal link, hidden assumption, or contradiction
- `Evidence` — missing, weak, stale, inaccessible, or misapplied support
- `Prose` — repetition, unclear referent, generic filler, buried recommendation, or list-shaped argument
- `Scope` — unnecessary implementation detail or material content outside the decision

Check the RFC in this order:

1. **Decision:** Is the requested decision or recommendation immediately identifiable?
2. **Need:** Is the problem specific to the current context, evidenced, and timely?
3. **Approach:** Are current state, proposed state, delta, and boundaries clear?
4. **Benefits:** Are outcomes concrete, measurable where practical, and appropriately qualified?
5. **Alternatives:** Is doing nothing considered, and is every serious option steelmanned?
6. **Evidence:** Can reviewers inspect support for important non-obvious claims?
7. **Ownership:** Could the author explain and defend every claim?
8. **Attention:** Can repetition, background, or detail move out without weakening the argument?
9. **Open items:** Are unresolved issues explicit, and do any block review?

For a review request, lead with the highest-impact findings and propose structural corrections before line edits. Do not rewrite the whole RFC unless the user asks.
