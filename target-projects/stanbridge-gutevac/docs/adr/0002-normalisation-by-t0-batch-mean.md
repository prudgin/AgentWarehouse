# ADR-0002 — Stomach evacuation normalised by t=0 batch mean

**Status**: accepted (carried verbatim from sibling Bilbul project)
**Date**: 2026-05-18 (intake; ratify against final `Proposal/Stanbridge_GER_trial_proposal.md`)

## Context

At every timepoint, a 15-fish batch is sampled from the cohort pond and the pooled stomach dry matter is weighed. Some fraction of fish in any 15-fish sample are **non-feeders** — they did not feed at the t=0 satiation event. Their stomachs contribute zero dry matter to every batch including t=0.

Two ways to handle non-feeders:

1. **Explicit per-fish classification.** Score each fish individually as fed or not-fed (presence/absence of stomach contents), then estimate the cohort's non-feeder fraction π and subtract π × 0 from each batch. This requires deciding, per fish, whether stomach emptiness at sampling reflects "non-feeder" or "fed-but-cleared". Late in the curve those two cases become indistinguishable.
2. **Normalisation by t=0 batch mean.** Express each batch as the ratio `y_rel(t) = batch_dry(t) / batch_dry(0)`. Non-feeders contribute zero to numerator and denominator identically and cancel out — the ratio is the evacuation curve of fed fish, no per-fish classification needed.

Option 2 is structurally simpler. The catch: it assumes π is roughly stable across timepoint samples (i.e. that random sampling from the pond draws representative mixtures of feeders and non-feeders at each timepoint).

The Stanbridge variant of this assumption has an extra wrinkle: at grow-out weights (200 g – 1.5 kg) in static ponds, π is not yet measured. If π is large or unstable, the assumption bites harder than at Bilbul juveniles (where π was a small minority).

## Decision

Use **normalisation by t=0 batch mean** for the primary GER curve. Compute `y_rel(t) = batch_dry(t) / batch_dry(0)` per cohort, fit on the resulting `y_rel(t)` series. Do **not** subtract a non-feeder term; the cancellation makes it redundant.

For the **binary stomach clearance curve** (a side metric, % fish with feed in stomach), use `P(empty | t) = π + (1 − π) · F_evac(t)`, with π fixed at the t=0 estimate. The binary curve cannot use the y_rel cancellation because at late timepoints non-feeders and cleared-feeders are observationally identical — π must be subtracted explicitly there.

Estimate π per cohort from the t=0 binary data only — fraction of t=0 fish with empty stomachs.

## Consequences

- **No per-fish feed/no-feed classification required for the primary curve.** Reduces dissection-bench protocol and post-processing complexity.
- **Diagnostic check is mandatory at Stanbridge.** π behaviour in static ponds with grow-out fish is unknown. Compare the binary-empty fraction across timepoints (should hover near π); if a timepoint sample drifts far from the cohort mean, flag it. The diagnostic gates whether the y_rel cancellation is trustworthy.
- **Fallback path.** If the diagnostic fires, re-fit raw (un-normalised) batch_dry curves and accept wider CIs. The proposal should list this as the explicit fallback under "Open questions and risks".
- **The "fed-fish curve" interpretation.** `y_rel` is the evacuation curve **conditional on having fed** — the right thing for the feeding-frequency downstream consumer.

## Alternatives considered

- **Explicit π subtraction.** Requires accurate π and per-fish classification. More complex; not better.
- **Per-fish dry matter, not batch.** Drying 15 individual stomachs is slow and error-prone at the low mass end. Pooled bulk weighing gives the mean more reliably than individual drying. The pellet-count cross-check covers the early-timepoint sanity check on individual variation.

## Provenance

- `Proposal/Stanbridge_GER_trial_proposal.md` §Analysis, stomach evacuation (to draft).
- Sibling `2026 Juvenile gut evac` project, `docs/adr/0002-normalisation-by-t0-batch-mean.md` (methodology source).
