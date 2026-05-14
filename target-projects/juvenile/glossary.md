# Glossary — 2026 Juvenile gut evac

Project-specific vocabulary for the Bilbul juvenile gastric-evacuation-rate trial. Read this before naming anything new in the repo.

Each entry: canonical term, synonyms to **avoid**, one-sentence definition, relationships, an example dialogue line, and any flagged ambiguities.

---

## GER (gastric evacuation rate)

**Avoid**: gut clearance (this term belongs to the sibling `2026 Gut Clearance` project on adult harvest fasting), digestion rate, emptying rate (bare).

The rate at which a fish's stomach empties after a discrete meal, fitted as a curve `y_rel(t)` from the per-cohort batch-dry-matter measurements over six post-feed timepoints.

**Relationships**: distinct from intestinal clearance, which is the slower downstream process measured here as a binary side-output. Primary deliverable: **time to 20 % residual** (clock-hours and degree-hours) per cohort.

**Example**: "Cohort B's GER curve is closer to square-root than to first-order — see the AIC table."

**Flagged**: "gut evac" in the SharePoint folder name is GER, not intestinal/whole-gut clearance. The shared name with the sibling project is a historical coincidence — the methodology differs (see ADR-0001).

**Provenance**: `Proposal/Bilbul_GER_trial_proposal.md` §Objective.

---

## Cohort

**Avoid**: group, size class, batch (`batch` is reserved for the 15-fish-pool aggregate at one timepoint).

A single Bilbul cage selected as the representative for one size class. Three cohorts in this trial:

| Cohort | Fish weight | Feed | Pellet dry mass |
|---|---|---|---|
| A | 10–45 g  | Biomar Efico Zeta 20, 3 mm   | ~16 mg |
| B | 45–80 g  | Biomar Efico Zeta 30, 4.5 mm | ~73 mg |
| C | 80–150 g | Biomar Efico Zeta 60, 4.5 or 6.5 mm | TBD on day |

**Relationships**: cohort cages are selected via the procedure in [`docs/reference/cage-selection.md`](docs/reference/cage-selection.md), with one cage per bracket. The weight brackets match the bracket knob in that procedure exactly.

**Example**: "Cohort C was sampled on Pond 8 Cage 1 — average weight ~104 g."

**Flagged**: Cohort C's pellet size is decided on the day depending on what the cage is actually being fed at the 80 g transition; the cage may be split into two sub-cages if it straddles the cutoff.

**Provenance**: `Proposal/Bilbul_GER_trial_proposal.md` §Cohorts.

---

## t=0

**Avoid**: time zero, baseline, intercept (bare; "the intercept" is fine in context).

The moment the cohort's single test feed finishes. Anchors the evacuation curve numerator and denominator. Sampled with 15 fish immediately after feeding stops.

**Relationships**: validated **before** t=0 by a sentinel sweep (see next entry) to confirm the pre-trial fast was sufficient. This is the central methodological tightening over the April 2026 work — see [ADR-0001](docs/adr/0001-t0-anchor-via-prefast-and-sentinel.md).

**Example**: "Cohort C reached t=0 on 2026-05-12 at 08:00."

**Provenance**: `Proposal/Bilbul_GER_trial_proposal.md` §Pre-trial fast and t=0 validation.

---

## Sentinel fish

**Avoid**: pilot fish, scout fish.

A 3–5-fish sample taken ~24 h before the planned test feed to confirm the pre-trial fast has emptied stomachs to the operational empty threshold. If the threshold is missed, the fast is extended 24 h and sentinels re-sampled.

**Relationships**: gates t=0. The trial schedule includes a slack day for one sentinel-driven extension; longer extensions push the whole cohort timeline.

**Example**: "Cohort A's first sentinels showed residue; we extended the fast 24 h before re-sampling."

**Provenance**: `Proposal/Bilbul_GER_trial_proposal.md` §Pre-trial fast and t=0 validation, step 2.

---

## Operational empty threshold

**Avoid**: "empty enough", clean.

The cutoff used by sentinel fish to declare a cohort fast-ready: stomach dry matter **< 0.05 % of body weight**, OR equivalently **fewer than 2 intact-pellet equivalents**.

**Provenance**: `Proposal/Bilbul_GER_trial_proposal.md` §Pre-trial fast and t=0 validation, step 2.

---

## Residual fraction (y_rel)

**Avoid**: residual mass, residual ratio.

`y_rel(t) = batch_dry(t) / batch_dry(0)`, where `batch_dry(t)` is the dry weight of the 15-fish pooled stomach contents at timepoint `t`. Ranges over [0, 1]. The primary curve fitted to extract GER.

**Relationships**: the cohort's **non-feeder fraction π** cancels in numerator and denominator (see [ADR-0002](docs/adr/0002-normalisation-by-t0-batch-mean.md)), so `y_rel(t)` is the evacuation curve of *fed* fish without per-fish classification.

**Example**: "At ~20 h post-feed Cohort C's `y_rel` was 0.45 — about halfway down."

**Flagged**: the cancellation only works if π is roughly stable across timepoint samples. If random sampling within the cage fails — e.g. a sub-population segregates — the assumption breaks. Diagnostic check in the analysis flags this if it bites.

**Provenance**: `Proposal/Bilbul_GER_trial_proposal.md` §Analysis, stomach evacuation step 3.

---

## Non-feeder fraction (π)

**Avoid**: non-eater fraction, c (this letter belongs to the sibling `2026 Gut Clearance` project's eating fraction, which is the *complement*).

The fraction of fish in a cohort that did not feed at the t=0 satiation feed. Estimated as the fraction of t=0 fish with empty stomachs.

**Relationships**: complement of the sibling project's "eating fraction `c`". The proposal estimates π per cohort from the t=0 binary data; the normalised stomach analysis (see `y_rel`) does not need π because the cancellation in `y_rel` makes it transparent. π is needed only for the **binary stomach clearance curve**: `P(empty | t) = π + (1 − π) · F_evac(t)`.

**Provenance**: `Proposal/Bilbul_GER_trial_proposal.md` §Analysis, non-feeder fraction π.

---

## K_local

**Avoid**: local rate constant (bare), K (bare; reserved for the K-index condition factor in the per-fish observations).

A diagnostic computed from successive timepoint pairs: `K_local = −ln(y_{t+Δ} / y_t) / Δ`. Flat across the timepoint sequence ⇒ first-order kinetics confirmed; trending ⇒ not exponential.

**Relationships**: a complement to the AIC model comparison (see [ADR-0003](docs/adr/0003-three-family-aic-kinetic-comparison.md)). If both AIC favours a non-exponential model AND K_local trends, the kinetic form is unambiguously not first-order for that cohort.

**Provenance**: `Proposal/Bilbul_GER_trial_proposal.md` §Analysis, stomach evacuation step 5.

---

## Mush

**Avoid**: paste, slurry.

The point in the digestion sequence at which discrete pellets are no longer distinguishable in the stomach. Pellet-counting stops once mush appears (per-fish counts become noise). Recorded as a yes/no observation at every fish, every timepoint.

**Relationships**: gates the **pellet-count cross-check**, which is only valid while pellets remain distinct. After mush appears, only the batch-dry-weight pathway works.

**Example**: "Cohort A's ~6 h timepoint showed mush in 11/15 fish — pellet count column drops out from there."

**Provenance**: `Proposal/Bilbul_GER_trial_proposal.md` §Measurements.

---

## Pellet-count cross-check

**Avoid**: pellet-count audit.

While pellets remain distinct (no mush), the per-fish pellet count multiplied by the known cohort pellet dry mass gives an independent per-fish dry-matter estimate. Compared with `batch_dry / 15` at the same timepoint.

**Relationships**: agreement is a cross-check on balance/protocol. Disagreement flags either a sampling bias or a balance issue. Used only at early timepoints.

**Provenance**: `Proposal/Bilbul_GER_trial_proposal.md` §Analysis, pellet-count cross-check.

---

## Binary clearance curve

**Avoid**: presence/absence curve.

The fraction of fish in a 15-fish batch with feed in stomach (or intestine) at each timepoint. Two curves per cohort. Comparable across cohorts and to the April 2026 report style. Stomach curve modelled as `P(empty | t) = π + (1 − π) · F_evac(t)` with π fixed at the t=0 estimate; intestine curve fitted directly.

**Provenance**: `Proposal/Bilbul_GER_trial_proposal.md` §Analysis, binary clearance curves.

---

## Bilbul scope

**Avoid**: BIL filter, Bilbul cages (bare; "the 96 grow-out cages" is the specific phrase).

The 12 × 8 = **96 grow-out cages** of the Bilbul juvenile farm, identified in the cycle ledger as `AreaCode == 'BIL'`. UnitIds are contiguous 803–898. Sites `B01`–`B12` (SiteIds 5–16) hold cages 01–08 each.

**Relationships**: the published `cycle_ledger/units.parquet` is pre-curated — `AreaCode == 'BIL'` yields exactly 96 production cages. Buffers, retired cages, and non-production units are removed upstream. See [`docs/domain/data-shape.md`](docs/domain/data-shape.md) §Scope.

**Example**: "Cohort C came from Pond 8 Cage 1 — UnitId 859."

**Provenance**: original local CLAUDE.md (now split into glossary + data-shape).

---

## OM5

**Avoid**: dissolved oxygen (bare; OM5 is the *specific* Mercatus parameter code).

The Mercatus environment-parameter code for dissolved oxygen in mg/L. The only environment code in scope for this project. Logged daily at the cluster level (one cluster = one pond, named `B0x All Units`). Raw export: `vReportingBaselineEnvironment.csv`, `Level == "Cluster"`, `ObjectId in {5_000_000 + i*1_000_000 for i = 0..11}`.

**Relationships**: pond O2 over the cage-selection window gates the trial-cage filter (mean ≥ 6.0, min ≥ 4.0 mg/L by default).

**Flagged**: data-entry outliers up to 7387 mg/L appear in the raw export. Always filter to a sanity range like `[0, 25]`. Bilbul oxygen does not exist before 2024-05-03.

**Provenance**: `docs/domain/data-shape.md` §Oxygen.

---

## SFR band

**Avoid**: feeding bracket.

A weight bracket where the cage-selection procedure (see [`docs/reference/cage-selection.md`](docs/reference/cage-selection.md)) judges feeding behaviour as normal. Per the procedure's defaults: SFR ratio in `(0.85, 1.40)` for fish below 50 g (wider, to compensate for sinking-feed bias) and `(0.85, 1.20)` above 50 g.

**Relationships**: SFR is from `growth_models.sfr(weight, temp)`. The ratio is `actual_feed_kg / expected_feed_kg` over a 14-day window.

**Provenance**: `docs/reference/cage-selection.md` §Filter order.

---

## Sinking vs floating feed

**Avoid**: small vs large feed.

A cage-level distinction: cages with fish **below ~50 g** receive **sinking** feed (non-trivial pellet waste); cages above 50 g receive floating feed (waste minimal). The implication for analysis: `actual / expected` SFR ratios are inflated for sub-50 g cages.

**Relationships**: drives the wider SFR acceptance band for Cohort A in the cage-selection procedure. Does not affect the GER measurement itself (cohorts receive a single satiation feed, observed directly).

**Provenance**: original local CLAUDE.md §4 "Sinking vs floating feed".

---

## Degree-hours (DH)

**Avoid**: thermal time (bare), °C·h.

The thermal-time unit used to express GER outputs alongside clock-hours: `DH = ∫ T(t) dt` over the post-feed window. Lets results generalise across temperatures, the way the April 2026 work expressed harvest fasting.

**Relationships**: pond temperature is logged hourly through the trial. All kinetic outputs are reported in DH **and** clock-hours. If pond temps drift > 2 °C across the sampling window, flag in the fit.

**Example**: "Cohort B reaches 20 % residual at ~580 DH, ≈ 29 h at 20 °C."

**Provenance**: sibling `2026 Gut Clearance` project, glossary entry "Degree-hours (DH)".
