# Annotated examples

These are descriptions the author wrote or approved, with notes on why each part
is there. Names, numbers, and ticket keys are changed; the structure and the
author's phrasing are kept. The shapes differ because the changes differ. Pick
the shape the change calls for.

## Contents

1. Small change, no headings
2. Small change with Summary and Why
3. Background and Why in two lines, and how a draft re-bloated them
4. Bug fix: mechanism-first draft vs. the author's rewrite
5. Performance scoping with an honest limitation
6. Design choice and quantified risks
7. What the author cut from an agent draft
8. Sentence-level rewrites

---

## 1. Small change, no headings

> Clean up - removes unused fields from the `useSession` query that is fetched
> on app load. We want to optimize this query since it blocks app load.

- One sentence says what changes and one says why. Nothing else is needed.
- "Blocks app load" is the reason a reviewer cares. Listing the removed fields
  would repeat the diff.

## 2. Small change with Summary and Why

> ## Summary
>
> Run expired service account token cleanup every minute instead of once per
> hour.
>
> ## Why
>
> The hourly schedule allows expired tokens to accumulate and be deleted in a
> burst at the start of each hour. Running cleanup continuously keeps normal
> runs small while preserving the existing batched cleanup behavior and its
> ability to drain a backlog.

- The Summary is one sentence of behavior, with the before and after in plain
  terms.
- The Why names the concrete problem (a burst at the top of each hour) instead
  of a generic benefit.

## 3. Background and Why in two lines

The author dictated these sections for a PR that adds backup alerts:

> Adds two paging alerts for the app's Postgres cluster: one when WAL stops
> reaching the backup bucket, one when there is no usable base backup.
>
> ## Background
>
> The app DB is backed up using twice daily base backups and WAL archive.
>
> ## Why
>
> If backups stopped working, we wouldn't know. These two alerts close the gap.

- The Background gives the one fact the reader needs: how backups work today.
- The Why is the risk in plain words, then how this PR closes it.

A later agent revision expanded the same Why into several paragraphs. They
covered alert thresholds, the reasons for 26h, metric-family edge cases,
retention depth, and WAL volume headroom. The author's reaction was "not focused
enough" and "way too dense and in the weeds." Rule-tuning rationale belongs in
the alert definitions or the review thread. When it truly matters, it goes in a
short Notes bullet, not in the Why.

## 4. Bug fix: mechanism-first draft vs. the author's rewrite

Agent draft:

> ## Summary
>
> `AliasGuard` is registered as a single schema extension instance, and the
> GraphQL library reuses that instance for every request. Its alias count was
> only set in `__init__`, so it accumulated for the life of each worker. Once a
> worker had counted `MAX_QUERY_ALIASES` aliases in total, it rejected every
> later aliased query with "Too many aliases in query". This is what broke
> listing, creating, and deleting API keys after #118 added one alias to each
> of those queries.
>
> The guard now resets the count when each request is parsed. …

Author's rewrite, published:

> ## Background
>
> `AliasGuard` is a guard extension in our GraphQL server that protects against
> DOS attacks. It's intended to limit the number of GraphQL aliases used in any
> one query. Without it, an attacker could hypothetically put our GraphQL
> server under stress by using a lot of GraphQL aliases to construct
> intentionally high complexity queries.
>
> ## Bug
>
> `AliasGuard` was created a long time ago and has had a latent bug that was
> exposed by INC-512. It is supposed to count aliases per request, but the
> counter is not being reset, effectively only allowing one use of a GraphQL
> alias per application lifetime.
>
> The guard now resets the count when each request is parsed. The new
> regression test runs the same schema twice with a one-alias query, and it
> fails on master with the incident's error.

What changed:

- **Purpose before mechanism.** The reader first learns what the guard is
  for, so the bug's impact is obvious.
- **The bug is stated as intent versus behavior.** "Supposed to count per
  request, but the counter is not being reset." The implementation detail
  (`__init__`, a shared instance) is left to the diff.
- **The incident is named,** so reviewers can connect the PR to it.
- **The headings fit the content.** A bug fix gets Background and Bug, not a
  generic Summary and Why.
- **One sentence of validation:** a regression test that fails on master. That
  says more than a list of test runs.

## 5. Performance scoping with an honest limitation

> ## Summary
>
> Removes fetching of `currentUser.team.members` from app startup, which was
> fetching all users in the entire team. For teams with a lot of users
> (staging suddenly had 15k this morning), this will slow app load to a crawl
> (if it loads at all).
>
> The fetch is instead moved into the sharing settings view, which needs a
> users list for granting access. The sharing settings view should have been
> fetching its own users list in the first place - views fetch specific data,
> app load fetches only data critical to show the app shell and common views.
>
> ## Test plan
>
> * The app loads without errors.
> * Elevated latency on staging is resolved.
>
> ## JIRA ticket
> https://example.atlassian.net/browse/APP-311
>
> ## Notes
> This PR doesn't solve the fundamental problem of fetching too many users. It
> just moves the problem into a subset of the app (sharing settings) to prevent
> blocking of app load. A follow-up will need to paginate `team.members`.

- **A real number makes the impact concrete:** 15k users in staging.
- **The design principle is stated once, plainly:** views fetch their own
  data, and app load fetches only what the shell needs. That tells reviewers
  how to judge the move.
- **The Test plan holds the two checks that matter,** both observable
  behavior. It doesn't restate CI.
- **Notes says what the PR doesn't fix and what follows.** A reviewer would
  otherwise ask whether the problem is solved.

## 6. Design choice and quantified risks

Examples 6 and 7 come from one system: an edge proxy that caches each member's
permissions per workspace, fed by a database view.

> ## Summary
>
> When permission data changes, the database sends the edge proxy each affected
> member's entries from `member_permissions_by_workspace`, added in #120, so
> the proxy can update its per-workspace cache without querying the database.
>
> ## Why
> The edge proxy has to learn when a member's per-workspace entries change. The
> simplest approach is to tell it which member changed and let it re-read the
> view. But then every proxy instance (up to 12) runs the same query for every
> change, multiplying the database load by the number of instances.
>
> ## How the edge proxy is notified
> Instead, the database looks up the new entries once and sends them in one
> transaction:
> - `member_workspaces`: the workspaces the member can access. The proxy
>   removes the member's entries for any other workspace.
> - `member_workspace`: one per workspace, with that workspace's headers and
>   actions.
>
> ## Risks
> * The current edge proxy doesn't recognize the new `member_workspaces` and
>   `member_workspace` messages. It will log an `invalid notification action`
>   warning for each one until
>   [PROXY-88](https://example.atlassian.net/browse/PROXY-88) adds support.
>
> * Changes to permission data, such as editing a role or a group membership,
>   take longer than today, because they now also look up the affected
>   members' per-workspace entries. For a change to one member, that adds about
>   10% to the 20–40 ms they already spend on notifications. For a change that
>   affects a whole workspace, such as creating a project, it adds an estimated
>   20–60% to their 0.9 s in the largest workspace, for a worst case of about
>   1.5 s, well under the 30 s statement timeout.
>
> * A notification over 8,000 bytes fails the change. The largest
>   `member_workspace` today is about 2,500 bytes, about 30% of the limit, and
>   grows mostly with the workspace's project count. `member_workspaces`
>   reaches the limit only when a member can access about 600 workspaces.
>
> ## JIRA ticket
>
> [PERM-210](https://example.atlassian.net/browse/PERM-210)

- **The Why argues against the obvious design.** It names the simple approach
  (tell the proxy to re-read) and the concrete cost that rules it out (up to
  12 instances, each repeating the query). The author's note on an earlier
  draft was: "It still doesn't cover why. The whole reason we're down this path
  is because performance concerns."
- **The explanatory section is named for what it explains,** with one bullet
  per message type.
- **Every risk names the concrete effect and a way to judge it:**
  - A warning that will appear, and the ticket that removes it.
  - Relative slowdown on today's baseline, the worst case, and the timeout it
    stays under.
  - The limit, today's largest case as a percentage of it, and what makes it
    grow.
- **Phrasing the author rejected along the way:**
  - "Commits that change permission data": what's a commit here?
  - "Writes that change access": what writes, and why drop the established
    term?
  - "Permission changes take longer": longer than what?
  - Raw milliseconds without a baseline: hard to interpret in a vacuum.
  - A sentence reassuring that existing messages are still sent: "we don't
    need to cover status quo unless there is reason to believe it would have
    changed."

## 7. What the author cut from an agent draft

A later PR in the same system replaces a function call per member and workspace
with one set-based query. That brings a full read of the cache view on staging
from about 8 s to about 350 ms. An agent wrote the draft from an earlier version
of this skill. The author kept its Background, Summary, Why, and design section
almost unchanged. They cut most of what came after, which took the body from
about 4,900 to 3,000 characters.

**Title.** The draft's title was "perf(permissions): Compute
member_permissions_by_workspace in one query, not one call per row". The
author kept the PR's existing title, "perf(permissions): Aggregate full-cache
reads in one query", which names the behavior in plain words.

**Risks.** Of four draft risks, the author kept only the one a reviewer would
otherwise get wrong: the proxy doesn't read the new view yet, so the speedup
reaches production only after a follow-up switches it. The author cut these:

> The four views decide which actions each member gets in each workspace, so a
> mistake there grants or drops access. … The tests compare the new view and
> function with the old function … They cover direct, group, and inherited
> grants; inactive members, workspaces, and roles; and an ID used by both a
> user and a service account.

- Every authorization change can grant or drop access, so this tells the
  reviewer nothing new. The rest is a list of test cases.

> The function is `SECURITY DEFINER` … The migration creates them inside a `DO`
> block that sets `search_path` to `pg_catalog, pg_temp`. … [An earlier PR]
> protects the function the same way.

- The protection is carried over unchanged from an earlier PR, so it is status
  quo.

> The first call to the function on each connection takes 10–20 ms locally …
> Later calls take 0.2–0.4 ms locally … With `plan_cache_mode =
> force_custom_plan`, every call takes about 4–6 ms.

- The numbers show no problem. Warm lookups are sub-millisecond, and the slow
  case needs a setting nobody uses.

**Test plan.** The draft listed two staging checks: the new view returns the
same rows as the old one, and the new lookup returns the same results. The
author cut both, because the Summary already says both return the same results
as on master and the Why already gives the staging timing.

**Notes.** The draft had four bullets. They said how grants carry over through
`CREATE OR REPLACE`, when a role gets `SELECT` relative to the post-deploy
grants script, which old view stays in place, and that another PR must
renumber its migration. The author cut all four. The first three are
implementation housekeeping, and the renumbering is coordination for the
author, not the reviewer.

**Kept, though it is mechanism.** The design section's table of the four new
views and the sentence on rewriting the function in PL/pgSQL stayed. They
explain where the access rules now live and a change a reviewer would see in
the diff and ask about.

**Corrected.** The author made two factual fixes. "One function call per row"
became "one function call per candidate member/workspace pair". The Why's
placeholder became the staging baseline, which the agent had asked for instead
of guessing.

## 8. Sentence-level rewrites

These illustrations use a made-up service, so they won't be copied literally.

| Draft | Problem | Rewrite |
|---|---|---|
| Adds the combined tenant-scoped source for the quota resolver. | Coined terms the reader has never seen | Adds a view with one row per tenant and region, holding that region's quota. |
| Existing hourly jobs continue to run unchanged. | Reassures about the status quo | *(delete)* |
| The main risk is regressions in existing billing queries. | Vague, and draws "Like what?" | Invoice totals now come from `ledger_entry`. A wrong join would show up as a mismatch against last month's totals. |
| Adds about 40 ms per request. | No baseline or limit | Adds about 40 ms, roughly 15% of today's p50 and well under the 2 s client timeout. |
| Retries are deduplicated per transaction, and fan-out is limited to affected tenants. | Obvious design presented as a feature | *(delete, or keep only if a reviewer would expect otherwise)* |
| Tests: 72 passed; ruff, pyright, and pre-commit pass. | Restates CI | *(delete, or name a behavioral check CI doesn't cover)* |
| Before: 900 ms. After: 40 ms. | "Before" was an intermediate revision, not the base branch | State the cost relative to the base branch only. |
| Adds `retry_after` to `webhook_delivery`. The worker sets it after each failure, and a new index on `(endpoint_uid, retry_after)` keeps the poll query fast. | A Summary that narrates the implementation | Retries failed webhook deliveries on a backoff schedule instead of immediately. |
| About 1,100 of the 1,400 added lines are tests, mostly in `tests/integration/test_webhook_retry.py`. | Counts and paths the diff already shows | Most of the diff is new integration tests. |
| A mistake in the quota views would over- or under-bill a tenant. The tests cover monthly, prorated, and suspended tenants. | Risk that applies to every billing change, plus a test list | *(delete)* |
| The migration and post-migrate both grant `SELECT` on the new views, so lookups keep working in between. | Implementation housekeeping | *(delete)* |
