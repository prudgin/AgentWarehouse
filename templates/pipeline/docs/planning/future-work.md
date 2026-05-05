# Future Work

Open backlog. Top of file = next up. As work ships, the entry moves out: shipped behaviour goes into `docs/reference/`; rationale and decision history go into `docs/adr/` or `analysis/analysis-landscape.md`.

This file holds **proposals, watching-points, open questions, and refinement candidates only**. Nothing about what's already done — that lives in the codebase, the reference docs, and the analysis tree.

See [`README.md`](README.md) for the boundary rule (vs. `.tickets/`), the entry format, and the four `**Type:**` values.

## Backlog

<!-- PLACEHOLDER — replace with real entries.

## Investigate slow ledger publish step

**What:** profile the publish stage and identify the bottleneck.
**Type:** proposal
**Why:** publish is currently 40% of total pipeline time; suspect the staging copy.
**Open questions:** is the bottleneck I/O, parquet serialisation, or the atomic rename?
**Links:** [analysis/2026-01-14-publish-timing/INVESTIGATION.md] (if started).

## Watch for stage-A retry storms in production

**What:** watch whether the new exponential-backoff in stage A produces visible retry storms when the upstream API hiccups.
**Type:** watching
**Why:** the previous fixed-interval retries hid the problem; the new backoff makes it observable. Want to see the shape before deciding if a circuit breaker is warranted.
**Open questions:** none until evidence accumulates.
**Links:** [ADR-0008](../adr/0008-exponential-backoff-stage-a.md).

## Where do schema migrations live?

**What:** decide whether schema migrations live alongside the stage that produces the data, in a top-level `migrations/` dir, or are versioned via the parquet schema only.
**Type:** open-question
**Why:** all three have trade-offs around discoverability vs locality; no decision yet.
**Open questions:** how does each option behave under multi-stage schema changes?
**Links:** none yet.

## Tighten stage-naming conventions

**What:** the stage names mix verbs (`ingestion`) and nouns (`ledger`). A sweep to normalise once the stage list stabilises.
**Type:** refinement-candidate
**Why:** inconsistency makes greps and onboarding noisier than they need to be.
**Open questions:** verbs or nouns as the canonical form?
**Links:** CLAUDE.md "Pipeline areas" table.

-->
