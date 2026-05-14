# ADR-0002 — Stomach evacuation normalised by t=0 batch mean

**Status**: accepted
**Date**: 2026-05-14 (drafted from `Proposal/Bilbul_GER_trial_proposal.md`)

## Context

At every timepoint, a 15-fish batch is sampled from the cohort cage and the pooled stomach dry matter is weighed. Some fraction of fish in any 15-fish sample are **non-feeders** — they did not feed at the t=0 satiation event. Their stomachs contribute zero dry matter to every batch including t=0.

Two ways to handle non-feeders:

1. **Explicit per-fish classification.** Score each fish individually as fed or not-fed (presence/absence of stomach contents), then estimate the cohort's non-feeder fraction π and subtract π × 0 from each batch. This requires deciding, per fish, whether stomach emptiness at sampling reflects "non-feeder" or "fed-but-cleared". Late in the curve those two cases become indistinguishable.
2. **Normalisation by t=0 batch mean.** Express each batch as the ratio `y_rel(t) = batch_dry(t) / batch_dry(0)`. Non-feeders contribute zero to numerator and denominator identically and cancel out — the ratio is the evacuation curve of fed fish, no per-fish classification needed.

Option 2 is structurally simpler. The catch: it assumes π is roughly stable across timepoint samples (i.e. that random sampling from the cage draws representative mixtures of feeders and non-feeders at each timepoint).

## Decision

Use **normalisation by t=0 batch mean** for the primary GER curve. Compute `y_rel(t) = batch_dry(t) / batch_dry(0)` per cohort, fit on the resulting `y_rel(t)` series. Do **not** subtract a non-feeder term; the cancellation makes it redundant.

For the **binary stomach clearance curve** (a side metric, % fish with feed in stomach), use `P(empty | t) = π + (1 − π) · F_evac(t)`, with π fixed at the t=0 estimate. The binary curve cannot use the y_rel cancellation because at late timepoints non-feeders and cleared-feeders are observationally identical — π must be subtracted explicitly there.

Estimate π per cohort from the t=0 binary data only — fraction of t=0 fish with empty stomachs.

## Consequences

- **No per-fish feed/no-feed classification required for the primary curve.** Reduces dissection-bench protocol and post-processing complexity.
- **Diagnostic check needed.** If π is not stable across timepoint samples, the cancellation is not exact. Add a check to the analysis: compare the binary-empty fraction across timepoints (should hover near π); if a timepoint sample drifts far from the cohort mean, flag it.
- **Fallback path.** If the diagnostic fires, re-fit raw (un-normalised) batch_dry curves and accept wider CIs. The proposal lists this as the explicit fallback under "Open questions and risks".
- **The "fed-fish curve" interpretation.** `y_rel` is the evacuation curve **conditional on having fed** — the right thing for the feeding-frequency downstream consumer, which only schedules feeds for fish that are actually going to eat.

## Alternatives considered

- **Explicit π subtraction.** Requires accurate π and per-fish classification. More complex; not better.
- **Per-fish dry matter, not batch.** Drying 15 individual ~10 mg stomachs is slow and error-prone at the low end. The proposal explicitly notes pooled bulk weighing gives the mean more reliably than individual drying. The pellet-count cross-check covers the early-timepoint sanity check on individual variation.

## Provenance

- `Proposal/Bilbul_GER_trial_proposal.md` §Analysis, stomach evacuation.
- `Proposal/Bilbul_GER_trial_proposal.md` §Open questions and risks, "Non-first-order kinetics" entry (the fallback path).
