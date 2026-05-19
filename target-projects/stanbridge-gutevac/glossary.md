# Glossary — 2026 Stanbridge gut evac

Project-specific vocabulary for the Stanbridge gastric-evacuation-rate trial. Read this before naming anything new in the repo.

Each entry: canonical term, synonyms to **avoid**, one-sentence definition, relationships, an example dialogue line, and any flagged ambiguities. Most methodology terms below are inherited verbatim from the sibling Bilbul project (`2026 Juvenile gut evac`) because the methodology travels site-agnostically. Site-level terms (scope, cohort) are Stanbridge-specific.

---

## GER (gastric evacuation rate)

**Avoid**: gut clearance (this term belongs to the sibling `2026 Gut Clearance` project on adult harvest fasting), digestion rate, emptying rate (bare).

The rate at which a fish's stomach empties after a discrete meal, fitted as a curve `y_rel(t)` from per-cohort batch-dry-matter measurements over six post-feed timepoints.

**Relationships**: distinct from intestinal clearance, which is the slower downstream process measured here as a binary side-output. Primary deliverable: **time to 20 % residual** (clock-hours and degree-hours) per cohort. Downstream consumer of these outputs is feeding-frequency design — **not** harvest fasting (that lives in the `2026 Gut Clearance` project).

**Example**: "Stanbridge Cohort B's GER curve is closer to square-root than to first-order — see the AIC table."

**Flagged**: "gut evac" in the SharePoint folder name is GER, not intestinal/whole-gut clearance. The shared name with the harvest-fasting sibling is a historical coincidence — the methodology differs (see ADR-0001).

**Provenance**: `Proposal/Stanbridge_GER_trial_proposal.md` §Objective (to draft).

---

## Cohort

**Avoid**: group, size class, batch (`batch` is reserved for the 15-fish-pool aggregate at one timepoint).

A single Stanbridge pond selected as the representative for one weight class. Cohort count and exact weight brackets are decided during pond selection, pulled from the fish present at Stanbridge at trial time. Indicative span across cohorts: ~200 g to ~1.5 kg.

| Cohort | Fish weight | Feed | Pellet dry mass |
|---|---|---|---|
| (TBD per cohort) | (TBD) | floating, Biomar grow-out range | (TBD) |

**Relationships**: cohort ponds are selected via the procedure in [`docs/reference/pond-selection.md`](docs/reference/pond-selection.md), with one pond per bracket. The procedure filters from the 78-pond [Stanbridge scope](#stanbridge-scope).

**Example**: "Stanbridge Cohort 2 was sampled on Cell 4 Pond 03 — average weight ~620 g."

**Flagged**: Stanbridge cohorts are **not** the Bilbul A/B/C juveniles — different site, different weight band, different feed sizes. Don't transcribe a Bilbul cohort table into a Stanbridge document.

**Provenance**: `Proposal/Stanbridge_GER_trial_proposal.md` §Cohorts (to draft).

---

## t=0

**Avoid**: time zero, baseline, intercept (bare; "the intercept" is fine in context).

The moment the cohort's single test feed finishes. Anchors the evacuation curve numerator and denominator. Sampled with 15 fish immediately after feeding stops.

**Relationships**: validated **before** t=0 by a sentinel sweep (see next entry) to confirm the pre-trial fast was sufficient. Methodology decision: see [ADR-0001](docs/adr/0001-t0-anchor-via-prefast-and-sentinel.md).

**Example**: "Stanbridge Cohort 2 reached t=0 on YYYY-MM-DD at 08:00."

**Provenance**: `Proposal/Stanbridge_GER_trial_proposal.md` §Pre-trial fast and t=0 validation (to draft); methodology inherited from the sibling Bilbul project.

---

## Sentinel fish

**Avoid**: pilot fish, scout fish.

A 3–5-fish sample taken ~24 h before the planned test feed to confirm the pre-trial fast has emptied stomachs to the operational empty threshold. If the threshold is missed, the fast is extended 24 h and sentinels re-sampled.

**Relationships**: gates t=0. The trial schedule includes a slack day for one sentinel-driven extension; longer extensions push the whole cohort timeline.

**Example**: "Cohort 1's first sentinels showed residue; we extended the fast 24 h before re-sampling."

**Provenance**: methodology inherited from sibling Bilbul project; to land in `Proposal/Stanbridge_GER_trial_proposal.md` §Pre-trial fast and t=0 validation, step 2.

---

## Operational empty threshold

**Avoid**: "empty enough", clean.

The cutoff used by sentinel fish to declare a cohort fast-ready: stomach dry matter **< 0.05 % of body weight**, OR equivalently **fewer than 2 intact-pellet equivalents**.

**Flagged**: the "2 intact-pellet equivalents" threshold uses cohort-specific pellet sizes — at Stanbridge grow-out fish on larger pellets, "2 pellet equivalents" is a higher absolute mass than at Bilbul juvenile cohorts. The dry-matter percentage threshold (< 0.05 %) is the more portable cutoff.

**Provenance**: methodology inherited from sibling Bilbul project.

---

## Residual fraction (y_rel)

**Avoid**: residual mass, residual ratio.

`y_rel(t) = batch_dry(t) / batch_dry(0)`, where `batch_dry(t)` is the dry weight of the 15-fish pooled stomach contents at timepoint `t`. Ranges over [0, 1]. The primary curve fitted to extract GER.

**Relationships**: the cohort's **non-feeder fraction π** cancels in numerator and denominator (see [ADR-0002](docs/adr/0002-normalisation-by-t0-batch-mean.md)), so `y_rel(t)` is the evacuation curve of *fed* fish without per-fish classification.

**Example**: "At ~20 h post-feed Cohort 3's `y_rel` was 0.45 — about halfway down."

**Flagged**: cancellation only works if π is roughly stable across timepoint samples. If random sampling within the pond fails — e.g. a sub-population segregates — the assumption breaks. Diagnostic check in the analysis flags this if it bites.

**Provenance**: methodology inherited from sibling Bilbul project.

---

## Non-feeder fraction (π)

**Avoid**: non-eater fraction, c (this letter belongs to the sibling `2026 Gut Clearance` project's eating fraction, which is the *complement*).

The fraction of fish in a cohort that did not feed at the t=0 satiation feed. Estimated as the fraction of t=0 fish with empty stomachs.

**Relationships**: complement of the sibling `Gut Clearance` project's "eating fraction `c`". π is estimated per cohort from the t=0 binary data; the normalised stomach analysis (see `y_rel`) does not need π because the cancellation in `y_rel` makes it transparent. π is needed only for the **binary stomach clearance curve**: `P(empty | t) = π + (1 − π) · F_evac(t)`.

**Flagged**: at Stanbridge grow-out weights, expected π is unknown — at Bilbul juveniles π was a small minority. If π turns out very large or unstable at Stanbridge (e.g. grow-out fish routinely refuse a satiation feed in static ponds), the π-cancellation assumption in [ADR-0002](docs/adr/0002-normalisation-by-t0-batch-mean.md) needs re-examination. Diagnostic check in the analysis flags this.

**Provenance**: methodology inherited from sibling Bilbul project.

---

## K_local

**Avoid**: local rate constant (bare), K (bare; reserved for the K-index condition factor in the per-fish observations).

A diagnostic computed from successive timepoint pairs: `K_local = −ln(y_{t+Δ} / y_t) / Δ`. Flat across the timepoint sequence ⇒ first-order kinetics confirmed; trending ⇒ not exponential.

**Relationships**: a complement to the AIC model comparison (see [ADR-0003](docs/adr/0003-three-family-aic-kinetic-comparison.md)). If both AIC favours a non-exponential model AND K_local trends, the kinetic form is unambiguously not first-order for that cohort.

**Provenance**: methodology inherited from sibling Bilbul project.

---

## Mush

**Avoid**: paste, slurry.

The point in the digestion sequence at which discrete pellets are no longer distinguishable in the stomach. Pellet-counting stops once mush appears (per-fish counts become noise). Recorded as a yes/no observation at every fish, every timepoint.

**Relationships**: gates the **pellet-count cross-check**, which is only valid while pellets remain distinct. After mush appears, only the batch-dry-weight pathway works.

**Flagged**: at Stanbridge grow-out weights, fish ingest more pellets per fish than Bilbul juveniles do — pellet counts may stay distinct for longer (more pellets to thin out before mush dominates). The mush yes/no observation is still per-fish per-timepoint.

**Provenance**: methodology inherited from sibling Bilbul project.

---

## Pellet-count cross-check

**Avoid**: pellet-count audit.

While pellets remain distinct (no mush), the per-fish pellet count multiplied by the known cohort pellet dry mass gives an independent per-fish dry-matter estimate. Compared with `batch_dry / 15` at the same timepoint.

**Relationships**: agreement is a cross-check on balance/protocol. Disagreement flags either a sampling bias or a balance issue. Used only at early timepoints (pre-mush).

**Provenance**: methodology inherited from sibling Bilbul project.

---

## Binary clearance curve

**Avoid**: presence/absence curve.

The fraction of fish in a 15-fish batch with feed in stomach (or intestine) at each timepoint. Two curves per cohort. Comparable across cohorts and to historic report styles. Stomach curve modelled as `P(empty | t) = π + (1 − π) · F_evac(t)` with π fixed at the t=0 estimate; intestine curve fitted directly.

**Provenance**: methodology inherited from sibling Bilbul project.

---

## Stanbridge scope

**Avoid**: STA filter (bare; this is the row-filter, not the scope), Stanbridge ponds (bare; "the 78 ongrowing ponds" is the specific phrase).

The **78 ongrowing pond-in-cell units** of the Stanbridge site, identified in the cycle ledger as `AreaCode == 'STA'`. Organised into 6 cells (SC1–SC6) holding contiguous-numbered ponds, UnitIds in two non-contiguous blocks: 1636–1673 (SC1–SC3) and 1853–1895 (SC4–SC6).

| Cell | SiteCode | Ponds | UnitId range |
|---|---|---:|---|
| Stanbridge Cell 1 | SC1 | 15 | 1636–1651 |
| Stanbridge Cell 2 | SC2 | 13 | 1652–1664 |
| Stanbridge Cell 3 | SC3 | 9  | 1665–1673 |
| Stanbridge Cell 4 | SC4 | 13 | 1869–1881 |
| Stanbridge Cell 5 | SC5 | 14 | 1882–1895 |
| Stanbridge Cell 6 | SC6 | 14 | 1853–1866 |

`OperationCode == 'OG'` (Ongrowing), `RegionCode == 'OR'` (Ongrowing region), `StructureType == 'pond_in_cell'`. Friendly-name format: `Stanbridge Cell N Pond NN`.

**Relationships**: the published `cycle_ledger/units.parquet` is pre-curated — `AreaCode == 'STA'` yields exactly 78 production ponds. Buffers, retired ponds, and non-production units are removed upstream. The Bilbul scope analogue is the 96 `cage_in_pond` units at `AreaCode == 'BIL'`; the structural difference (cell-of-ponds vs pond-of-cages) is why this project's selection procedure is `pond-selection.md`, not `cage-selection.md`.

**Example**: "Cohort 1 came from Stanbridge Cell 4 Pond 03 — UnitId 1871."

**Provenance**: `/mnt/data/mercatus/cycle_ledger/units.parquet` and the published `/mnt/data/mercatus/README.md` Company-structure section.

---

## Pond oxygen

**Avoid**: OM5 (that's the cluster-level / cell-grain parameter code in `vReportingBaselineEnvironment.csv` — a *different* aggregation, not the right source for this project).

Dissolved oxygen in mg/L, **logged per pond per day** in `/mnt/data/mercatus/raw/odata_exports/vReportingBaselineInventoryByDay.csv` (column `Oxygen`, grain `(UnitId, Date)`). All 78 Stanbridge ponds covered, ~770 days per pond, since 2024-03-27.

**Relationships**: pond O2 over the pond-selection window gates the trial-pond filter (mean ≥ 6.0, min ≥ 4.0 mg/L by default; thresholds inherited from the Bilbul procedure pending Stanbridge-specific tuning).

**Flagged**: there's *also* an OM5 cluster-level feed in `vReportingBaselineEnvironment.csv` that aggregates oxygen to the cell level (one reading per cell per day, covering 9–15 ponds). Do **not** use that for pond-grain selection — use the InventoryByDay per-pond column instead. The Bilbul project's data-shape doc points at the environment CSV because at Bilbul cluster=pond; that source doesn't transfer cleanly here.

**Provenance**: `/mnt/data/mercatus/raw/odata_exports/vReportingBaselineInventoryByDay.csv` `Oxygen` column (audited 2026-05-18). README schema at `/mnt/data/mercatus/README.md` §`raw/odata_exports/`.

---

## SFR band

**Avoid**: feeding bracket.

A weight bracket where the pond-selection procedure (see [`docs/reference/pond-selection.md`](docs/reference/pond-selection.md)) judges feeding behaviour as normal. Stanbridge fish are all on floating feed (no sinking-feed pellet-waste bias), so a single threshold applies across cohorts. Default: SFR ratio in `(0.85, 1.20)` — same upper-band as Bilbul's >50 g cohorts.

**Relationships**: SFR is from `growth_models.sfr(weight, temp)`. The ratio is `actual_feed_kg / expected_feed_kg` over a 14-day window. **Differs from Bilbul**: the Bilbul juvenile cohort A uses a wider band `(0.85, 1.40)` to compensate for sinking-feed bias — that asymmetry is dropped here because Stanbridge has no sinking-feed cohorts.

**Provenance**: `docs/reference/pond-selection.md` §Filter order (to draft).

---

## Degree-hours (DH)

**Avoid**: thermal time (bare), °C·h.

The thermal-time unit used to express GER outputs alongside clock-hours: `DH = ∫ T(t) dt` over the post-feed window. Lets results generalise across temperatures.

**Relationships**: pond temperature is logged through the trial. All kinetic outputs are reported in DH **and** clock-hours. If pond temps drift > 2 °C across the sampling window, flag in the fit.

**Example**: "Cohort 2 reaches 20 % residual at ~720 DH, ≈ 36 h at 20 °C."

**Provenance**: sibling `2026 Gut Clearance` project, glossary entry "Degree-hours (DH)".
