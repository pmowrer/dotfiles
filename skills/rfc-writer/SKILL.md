---
name: rfc-writer
description: "Create or revise technical RFCs through a skeleton-first workflow: frame the decision, scaffold adaptive sections with claims, evidence, constraints, and open questions, align on structure, then expand approved sections into concise prose. Use for RFC outlines, technical proposals, architecture decisions, RFC rewrites, and pre-review checks; keep low-level implementation planning out unless the user asks for it."
---

# RFC Writer

Treat the RFC as a decision-making artifact, not a transcript of exploration. Protect reviewer attention and make the author's reasoning easy to inspect, challenge, and revise.

## Choose the phase

Infer the active phase from the request and existing artifact:

- **Frame:** identify the decision, audience, scope, constraints, sources, and decision owner.
- **Skeleton:** create or revise the RFC's structure and content stubs. This is the default for a new RFC.
- **Prose:** expand an explicitly approved skeleton, or edit prose the user has already supplied.
- **Preflight:** assess whether an RFC is ready for human review.

Do not jump from an initial idea directly to polished prose. If the user requests a complete RFC but has not approved a structure, provide the skeleton first and explain that prose is the next pass. If an existing RFC already supplies a clear structure, preserve it unless the user asks to restructure it.

## Frame the decision

Gather only context that changes the RFC's shape or recommendation: the decision sought, intended readers, why it matters now, current state, constraints, evidence, candidate approaches, and output destination. Use supplied documents and repository context when relevant.

Proceed with explicit `TBD`, `Unknown`, or `Assumption` markers when missing information does not prevent useful structure. Ask a question only when the answer would materially change the scope, decision, or section plan. Never fill gaps with plausible company facts, metrics, constraints, owners, or dates.

## Build the skeleton

Read [references/skeleton.md](references/skeleton.md) before creating or structurally revising a skeleton.

The skeleton is the primary collaboration surface. It must expose the proposed argument, not merely list blank headings. Under each included heading, write concise, topic-specific stubs for the claims to make, support needed, boundaries, unresolved questions, and reviewer decisions. Prefer fragments and bullets at this phase; polished transitions are premature.

Select sections because they help reviewers evaluate the decision. Start from the NABC spine—Need, Approach, Benefits, and Competition/Alternatives—but adapt it to the task. Do not add empty ritual sections.

End a skeleton response with no more than three high-leverage alignment questions covering structural uncertainty. Then stop. Do not expand the skeleton into prose until the user explicitly asks for expansion or confirms the structure is aligned.

When iterating on a skeleton:

1. Apply the user's requested delta without rewriting approved sections unnecessarily.
2. Preserve stable, descriptive heading names so comments remain easy to reference.
3. Summarize material structural changes briefly, then show the coherent revised skeleton.
4. Keep substantive disagreements and unknowns visible; do not smooth them away with wording.

## Expand approved prose

Read [references/prose-and-review.md](references/prose-and-review.md) before prose expansion, substantive prose editing, or preflight review.

Expand only the approved sections or scope. Treat every skeleton stub as a coverage obligation or an intentionally unresolved marker. Use connected narrative for the argument and bullets only for genuinely list-shaped material.

Prose expansion must not silently introduce a new decision, material constraint, alternative, or scope boundary. If drafting reveals one, propose a small skeleton change and seek alignment before incorporating it. This preserves the structure as the shared contract.

## Preserve authority and evidence

- The user and designated sources control facts. Mark unsupported claims and assumptions instead of inventing support.
- Prefer primary, inspectable evidence for non-obvious claims. Make clear which claim each source supports.
- Treat AI output as draft material, never as evidence.
- Steelman every serious alternative, including doing nothing, before explaining the tradeoff or rejection.
- Keep the core RFC focused on what and why. Include implementation detail only when it is necessary to evaluate feasibility or the user explicitly requests it.
- The author owns every claim. Do not leave meta-commentary, fabricated citations, or reasoning that cannot be defended.

## Completion states

State which artifact was produced:

- `Skeleton — awaiting structural alignment`
- `Skeleton — aligned; ready for prose`
- `Prose draft — awaiting content review`
- `Preflight — ready` or `Preflight — revisions required`

Do not label a skeleton aligned without the user's confirmation. Do not label an RFC ready while material `TBD`, unsupported claims, straw-man alternatives, or unresolved decision questions remain.
