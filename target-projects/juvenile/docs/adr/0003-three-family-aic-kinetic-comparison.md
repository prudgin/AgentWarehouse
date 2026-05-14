# ADR-0003 — Per-cohort AIC comparison of three kinetic families

**Status**: accepted
**Date**: 2026-05-14 (drafted from `Proposal/Bilbul_GER_trial_proposal.md`)

## Context

The April 2026 gut-clearance work on adult harvest stock assumed a single sigmoid form and ended up fitting a two-meal hump model to absorb structural error from a contaminated t=0. With t=0 fixed (see [ADR-0001](0001-t0-anchor-via-prefast-and-sentinel.md)), this trial can be more direct about the kinetic question — but doing so requires not assuming a kinetic form in advance, because:

- **Exponential / first-order** (`y = a · exp(−Kt)`) assumes the evacuation rate is proportional to current stomach contents. Standard. Easy to fit. Often wrong for fish.
- **Square-root** (`y = (√a − Kt)²`) assumes evacuation is proportional to bolus surface area — bolus erodes from the outside. Common in piscine GER literature (e.g. Talbot 2001, in `Articles/`).
- **Power / Andersen** (`y = a · (1 − bt)^c`) is a three-parameter flexible form that nests several special cases. Most flexible, most prone to over-fit on 6 timepoints.

Per cohort we have six (`t`, `batch_dry`) datapoints — barely enough to choose between three families, but enough to reject one by AIC if its fit is clearly worse.

## Decision

For each cohort, fit all three families to the normalised `y_rel(t)` series and compare by **AIC**. Report the AIC table per cohort and pick the lowest-AIC model for that cohort's headline t-at-20-%-residual estimate. Acknowledge model uncertainty by reporting the t-at-20% for all three families when their AICs are within 2 of each other.

In parallel, compute the **K_local diagnostic** from successive timepoint intervals: `K_local = −ln(y_{t+Δ} / y_t) / Δ`. A flat K_local across intervals confirms first-order kinetics; a trending K_local does not. The diagnostic is a structural check independent of the AIC comparison.

Compute bootstrap CIs by resampling the six batch points (parametric bootstrap on the chosen kinetic family).

## Consequences

- **Three fits per cohort instead of one.** A small cost; the fits are cheap.
- **Cohort-specific model choice.** Each cohort can have a different best-fit family. This is the correct outcome if cohort size genuinely changes evacuation kinetics (e.g. surface-area scaling matters more in cohort C than cohort A). It does complicate cross-cohort reporting — adopt the convention of reporting cohort-by-cohort and noting any cross-cohort kinetic pattern.
- **Report responsibility for ambiguity.** When AICs are within 2 the data does not discriminate. The headline number must report all three estimates in that case, not pick arbitrarily.
- **Six points limit power.** A formal test for non-exponential kinetics is weak with 6 timepoints. Treat AIC differences below 2 as "no preference" and rely on the K_local diagnostic as the second opinion.

## Alternatives considered

- **Assume first-order (single exponential fit).** What the April 2026 work effectively did. Rejected — the whole methodological tightening of this trial is to not bake in kinetic assumptions.
- **Bayesian model averaging.** Tighter handling of model uncertainty but with six points the priors dominate. AIC + within-2 reporting is honest enough.
- **Compare more families** (e.g. Weibull, Hill curve). Not worth it — three families already span the relevant biological hypotheses (current-contents vs surface-area vs flexible).

## Provenance

- `Proposal/Bilbul_GER_trial_proposal.md` §Analysis, stomach evacuation step 4–6.
- `Articles/Aquaculture Research - 2001 - Talbot - Pattern of feed intake in four species of fish under commercial farming conditions.pdf` — surface-area reasoning.
- `Articles/YTK_methodological_critique.pdf` — methodological framing for kinetic-form comparison.
