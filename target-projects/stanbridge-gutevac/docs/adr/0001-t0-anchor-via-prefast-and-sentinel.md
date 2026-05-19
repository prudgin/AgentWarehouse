# ADR-0001 — t=0 anchored by pre-trial fast + sentinel-fish validation

**Status**: accepted (carried verbatim from sibling Bilbul project)
**Date**: 2026-05-18 (intake; ratify against final `Proposal/Stanbridge_GER_trial_proposal.md`)

## Context

Two upstream projects shape this decision:

- **`2026 Gut Clearance`** (April 2026 warm-band fit on adult harvest stock) used an opportunistic harvest-window design with whole-pond fasts of indeterminate duration. The report concluded that **the t=0 intercept was contaminated by yesterday's meal**, and the project had to absorb that contamination by replacing a simple sigmoid with a two-meal hump model. The contaminated t=0 was that work's single biggest source of error.
- **`2026 Juvenile gut evac`** (sibling Bilbul trial) made the methodological choice to fix the t=0 problem at source via deliberate pre-fast + sentinel validation.

This trial is methodologically the same shape (a stomach-evacuation curve from sequential 15-fish batch samples) but conducted on **Stanbridge ongrowing fish (200 g – 1.5 kg)** in static ponds rather than Bilbul juveniles in cages. The downstream purpose is the same as Bilbul: feeding-frequency design. Inheriting the contaminated-t=0 problem is avoidable here because we control the schedule.

## Decision

t=0 is anchored by a **deliberate pre-trial fast with sentinel validation**:

1. Cease feeding the cohort pond. Starting fast estimates scale with fish size and water temperature — Stanbridge-cohort-specific durations pinned in `Proposal/Stanbridge_GER_trial_proposal.md` when drafted; expect grow-out fish fasts to run longer than Bilbul juveniles (lower mass-specific metabolic rate, larger boluses to clear).
2. **~24 h before** the planned test feed, dissect 3–5 sentinel fish per pond and confirm stomach contents are below the **operational empty threshold** (< 0.05 % BW dry matter, or < 2 intact-pellet equivalents).
3. If sentinels carry residue, extend the fast by 24 h and re-sample. **Build a day of slack into the trial schedule for this.**
4. When sentinels pass, the cohort is fed once to apparent satiation at t=0. The 15-fish t=0 sample is taken immediately after feeding finishes.

## Consequences

- **Schedule slack required.** Every cohort needs a one-day buffer in the trial schedule for sentinel-driven fast extension. If the buffer is consumed and the threshold is still not met, slip the cohort by another day rather than proceeding with a contaminated t=0.
- **Sentinel fish are sacrificed.** ~3–5 fish per cohort lost to validation — accept this as a fixed cost.
- **Pond-wide fast at Stanbridge.** Unlike Bilbul (cage-level fasting within a pond), a Stanbridge cohort fast starves the whole pond. Feasibility was confirmed with operations during intake; no special accommodation needed beyond the schedule slack already required.
- **Clean normalisation downstream.** With a clean t=0, the residual-fraction analysis (see [ADR-0002](0002-normalisation-by-t0-batch-mean.md)) becomes a one-step normalisation.
- **Threshold is operational, not theoretical.** "Empty" means below a measurable bar, not literally zero. The bar (0.05 % BW DM, or < 2 intact-pellet equivalents) was chosen to be measurable on-site and is loose enough that 24 h sentinel sweeps are practical.

## Alternatives considered

- **Opportunistic harvest-window design** (the April 2026 method). Cheaper logistically but inherits the contaminated-t=0 problem. Rejected — the whole point of this trial is to fix that error.
- **No sentinel — fixed-duration fast with no validation.** Loses per-cohort calibration. Rejected.
- **Continuous oxygen / behavioural monitoring instead of sentinels.** More elaborate, indirect, and dependent on instruments not installed at Stanbridge. Rejected.

## Provenance

- `Proposal/Stanbridge_GER_trial_proposal.md` §Pre-trial fast and t=0 validation (to draft).
- Sibling `2026 Juvenile gut evac` project, `docs/adr/0001-t0-anchor-via-prefast-and-sentinel.md` (methodology source).
- Sibling `2026 Gut Clearance` project, `docs/domain/known-issues.md` (where the contaminated-t=0 problem is documented as the motivating prior).
