# ADR-0001 — t=0 anchored by pre-trial fast + sentinel-fish validation

**Status**: accepted
**Date**: 2026-05-14 (drafted from `Proposal/Bilbul_GER_trial_proposal.md`)

## Context

The sibling project `2026 Gut Clearance` (April 2026 warm-band fit on adult harvest stock) used an **opportunistic harvest-window** design: sampling whatever the farm was already doing, with whole-pond fasts of indeterminate duration. The April 2026 report concluded that **the t=0 intercept was contaminated by yesterday's meal**, and the project had to absorb that contamination by replacing a simple sigmoid with a two-meal hump model. The contaminated t=0 was that work's single biggest source of error.

This trial is methodologically the same shape (a stomach-evacuation curve from sequential 15-fish batch samples) but conducted on juveniles for an unrelated downstream purpose (feeding-frequency design — see [`../../CLAUDE.md`](../../CLAUDE.md)). Inheriting the contaminated-t=0 problem is avoidable here because we control the schedule.

## Decision

t=0 is anchored by a **deliberate pre-trial fast with sentinel validation**:

1. Cease feeding the cohort cage. Starting fast estimates: ~48 h (Cohort A), ~72 h (B), ~96 h (C), scaled longer at lower water temps. Iterate from here.
2. **~24 h before** the planned test feed, dissect 3–5 sentinel fish per cage and confirm stomach contents are below the **operational empty threshold** (< 0.05 % BW dry matter, or < 2 intact-pellet equivalents).
3. If sentinels carry residue, extend the fast by 24 h and re-sample. **Build a day of slack into the trial schedule for this.**
4. When sentinels pass, the cohort is fed once to apparent satiation at t=0. The 15-fish t=0 sample is taken immediately after feeding finishes.

## Consequences

- **Schedule slack required.** Every cohort needs a one-day buffer in the trial schedule for sentinel-driven fast extension. If the buffer is consumed and the threshold is still not met, slip the cohort by another day rather than proceeding with a contaminated t=0. Cohort A is most likely to need extension (smallest fish, fastest digestion but also fastest re-population from cage cohabitants).
- **Sentinel fish are sacrificed.** ~3–5 fish per cohort lost to validation — accept this as a fixed cost.
- **Clean normalisation downstream.** With a clean t=0, the residual-fraction analysis (see [ADR-0002](0002-normalisation-by-t0-batch-mean.md)) becomes a one-step normalisation. No two-meal combination needed.
- **Threshold is operational, not theoretical.** "Empty" means below a measurable bar, not literally zero. The bar (0.05 % BW DM, or < 2 intact-pellet equivalents) was chosen to be measurable on-site and is loose enough that 24 h sentinel sweeps are practical.

## Alternatives considered

- **Opportunistic harvest-window design** (the April 2026 method). Cheaper logistically but inherits the contaminated-t=0 problem the April work had to absorb structurally. Rejected — the whole point of this trial is to fix that error.
- **No sentinel — fixed-duration fast with no validation.** Reduces logistical complexity to "wait 96 h then feed", but loses the per-cohort calibration that catches species or temperature surprises. Rejected.
- **Continuous oxygen / behavioural monitoring instead of sentinels.** More elaborate, indirect, and dependent on instruments that are not installed at Bilbul. Rejected — sentinels are concrete and reproducible.

## Provenance

- `Proposal/Bilbul_GER_trial_proposal.md` §Pre-trial fast and t=0 validation.
- Sibling `2026 Gut Clearance` project — `docs/domain/known-issues.md` (where the contaminated-t=0 problem is documented as the motivating prior).
