# Glossary — 2023 Feeding Frequency

Project-specific vocabulary for the 2023 McFarlane's Murray cod feeding-frequency re-analysis. Read this before naming anything new in the repo.

Each entry: canonical term, synonyms to **avoid**, one-sentence definition, relationships, an example dialogue line, and any flagged ambiguities.

---

## McFarlane's

**Avoid**: Aquna site (Aquna runs multiple sites; McFarlane's is the specific one), the farm (ambiguous across projects).

The McFarlane's pond farm site at which the 2023 feeding-frequency trials were run. Identified in the Mercatus cycle ledger as `SiteName == "McFarlane's"`. Four ponds are in scope for this project: M01, M03, M05, M06 (referred to colloquially as Pond 1, Pond 3, Pond 5, Pond 6).

**Relationships**: distinct from the sibling project's Bilbul juvenile farm (`AreaCode == 'BIL'`). McFarlane's is an outdoor pond grow-out site; Bilbul is the juvenile-stage tank farm. Different fish, different conditions, different ledger areas.

**Example**: "All four McFarlane's ponds had the same pre-trial regime — see `methodology-pretrial.md`."

**Provenance**: README.md §Cohort and trial design.

---

## Trial 1 (T1)

**Avoid**: "the twice-daily trial" alone (ambiguous — better: T1 / Trial 1).

The first of the two parallel 2023 trials. **Ponds 1 and 3.** Treatment regime: **twice/day** feeding. Control regime: **once/day**. Trial window: 2023-07-20 → 2023-09-20 (**63 days, 9 weeks**).

**Relationships**: paired with T2 (alt-day). T1 control and T2 control share the same regime (once/day) but were in different ponds and so are not pooled. T1's week-9 has an annotated staff feed-intensity drop — see [`docs/domain/methodology-sfr.md`](docs/domain/methodology-sfr.md) §7.

**Example**: "T1 treatment over-feeds slightly and modestly out-grows control."

**Provenance**: `Final report McFarlane's_DS.docx` / README.md §Trials.

---

## Trial 2 (T2)

**Avoid**: "the alt-day trial" alone (ambiguous).

The second of the two parallel 2023 trials. **Ponds 5 and 6.** Treatment regime: **every-second-day** feeding. Control regime: **once/day**. Trial window: 2023-07-20 → 2023-09-06 (**49 days, 7 weeks**).

**Relationships**: paired with T1 (twice/day). T2's headline finding is more dramatic than T1's — but the pre-trial baseline shows roughly half the T2 treatment deficit is **inherited cohort weakness**, not regime effect. See [`docs/domain/methodology-pretrial.md`](docs/domain/methodology-pretrial.md).

**Example**: "T2 alt-day under-feeds AND under-grows; pre-trial baseline absorbs about half the gap."

**Provenance**: `Final report McFarlane's_DS.docx` / README.md §Trials.

---

## Trial window

**Avoid**: trial period (vague), the experiment (too broad — there's also a pre-trial window).

The dates over which a trial's treatment vs control regime was applied. **Per-trial**:

- T1: `2023-07-20 → 2023-09-20` (63 days).
- T2: `2023-07-20 → 2023-09-06` (49 days).

**Relationships**: distinct from the **pre-trial window** (`2023-05-20 → 2023-07-19`, 61 days, identical for both trials). All four analyses (SGR, SFR, Cross) use the trial window by default; the pretrial analysis swaps in the pre-trial window. The `analyses/_common.build_cage_day()` helper takes the window as a parameter.

**Example**: "Trajectory-implied SGR is computed at the trial-window endpoints, not the workbook-recorded sample dates."

**Provenance**: `docs/methodology_sgr.md` §Per-cage realised SGR.

---

## Books-clean cohort

**Avoid**: "the clean cohort" alone, "the 32 cages" without context.

The canonical analysis cohort: **32 cages** out of 48 in the trial design, after applying the filter ladder in [`docs/domain/filters-and-drops.md`](docs/domain/filters-and-drops.md). Used by default in every analysis (SGR, SFR, Cross, Pretrial).

**Relationships**: built by `analyses/_common.default_drops()` at runtime from `pipeline/audits/cycle_books.csv` (self-syncing — if the live ledger or 9% threshold changes, the cohort updates automatically). The full per-cage roster including the 16 excluded cages is in `analyses/cages_used.csv`.

**Example**: "Pooled SFR ratios reported in the README are books-clean — see filters-and-drops for the full ladder."

**Flagged**: there's no parallel "unfiltered" output set in the current project state (deleted during the 2026-05-07 tidy-up — only the books-clean set survives).

**Provenance**: `docs/decisions_log.md` 2026-05-07 entry; `docs/filters_and_drops.md`.

---

## Books-noisy filter

**Avoid**: "the 9% filter" alone (insufficient context).

A filter that drops cages whose **bookkeeping drift attributed to the trial period exceeds 9% of trial-mean inventory**. Formally: `|adj_daily_pct × trial_days| > 9.0%`. Excludes 6 cages from the cohort.

**Relationships**: implemented as `analyses/_common.books_noisy_drops()` which reads `pipeline/audits/cycle_books.csv` at runtime. The 6 cages dropped: **P1C1, P1C6, P1C7, P3C5, P6C4, P6C12**. See [ADR-0002](docs/adr/0002-books-clean-filter-at-nine-percent.md) for the threshold-choice rationale.

**Example**: "P6C12 trips books-noisy at 13% — only 1 000 of 5 350 fish landed at harvest."

**Provenance**: `docs/filters_and_drops.md` §Filter 4.

---

## adj_daily_pct

**Avoid**: "the adjustment %", "the drift rate" (both ambiguous).

The metric driving the books-noisy filter: `adj_daily_pct = (A_count + CA_count) / Σ(daily_open_count) × 100`. Constant cycle-wide daily rate; multiplied by `trial_days` to get the trial-attributed drift. Units: %/day.

**Relationships**: `A_count` = operator manual count adjustments; `CA_count` = system close-day reconciliation. Both can be positive (fish written off) or negative (fish added back). Alternative bases (% of stocking, % of throughput) are tabulated in `pipeline/audits/cycle_books_pct_compare.csv`.

**Example**: "P1C7 adj_daily_pct = 0.201 %/day × 63 trial days = +12.7% trial-attributed drift."

**Provenance**: `docs/filters_and_drops.md` §Filter 4.

---

## Realised SGR

**Avoid**: "the actual SGR" (loaded — depends on estimator), "report SGR" (specifically the 2023 report's formula — different).

**Endpoint-implied** specific growth rate computed from the **spline-fitted simulated weight trajectory** at the trial-window boundaries: `SGR_realised = (ln(W_sim_end) − ln(W_sim_start)) / days × 100` (units %/day). The spline anchors on multiple sample sources, so this is robust to single-check sampling noise.

**Relationships**: distinct from the 2023 report's "Table 1 SGR" which used the workbook's two weight checks `(ln W_interim − ln W_initial) / days`. The report's formula has two problems: the "initial" check was pre-trial (2023-05-03/31 or 06-07) and the "interim" check was only 12 days into the trial, so it mostly measured pre-trial growth; and ~1% sampling noise produced negative apparent SGRs for several cages. See [ADR-0001](docs/adr/0001-trajectory-anchored-endpoint-sgr.md).

**Example**: "T1 cohort realised SGR is 0.18–0.30 %/day where the report had negatives — that's the spline anchoring on the trial-window endpoints."

**Provenance**: `docs/methodology_sgr.md`.

---

## Model SGR

**Avoid**: "the model" alone, "the prediction", "expected SGR".

Reference SGR from the **Nov-2024 `growth_models.sgr(weight, temp)` surface**, evaluated daily on the simulated trajectory + daily temperature, then averaged over the trial window per cage. Aggregated by initial-biomass-weighted mean across cages within `(pond, group)` and `(trial, group)`.

**Relationships**: `Realised SGR / Model SGR × 100 %` is the **SGR ratio** — the headline performance metric per group. Same conceptual pattern as Model SFR.

**Example**: "T2 treatment SGR ratio of 68% means realised growth was 68% of what the model predicts for the achieved temperature trajectory."

**Provenance**: `docs/methodology_sgr.md` §Per-cage model SGR.

---

## Realised SFR

**Avoid**: "feed rate" (vague), "feeding intensity" (informal).

Specific feed rate per cage-day: `sfr_real_pct = feed_kg × 100 / biomass_kg`. Aggregated to (trial, group, week) buckets via `Σ feed_kg × 100 / Σ biomass_kg` (biomass-weighted, mathematically identical to a biomass-weighted mean of cage-day SFRs).

**Relationships**: feed source is `data/feed_daily.csv` by default (workbook record within trial window); pretrial uses MDF's `DailyFeedKg` (workbook only covers trial window). Hybrid stitching is encoded in [ADR-0004](docs/adr/0004-hybrid-feed-source-workbook-and-mdf.md). Blanks in `feed_daily.csv` are treated as 0 kg (genuine non-feed days for T2 treatment).

**Example**: "T1 treatment pooled realised SFR was 136% of the Nov-2024 model — over-fed."

**Provenance**: `docs/methodology_sfr.md`.

---

## Model SFR

**Avoid**: "expected SFR".

Reference SFR from the **Nov-2024 `growth_models.sfr(weight, temp)` surface**. Validity envelope 1–4000 g, 8–28 °C — trial values fall well inside. Evaluated day-by-day, then biomass-weighted aggregation.

**Relationships**: `Realised SFR / Model SFR × 100 %` is the **SFR ratio**. The Cross analysis plots SFR ratio vs SGR ratio together.

**Provenance**: `docs/methodology_sfr.md` §4.

---

## SFR ratio

**Avoid**: "feed efficiency" (overloaded; "SFR ratio" is more precise).

`SFR_realised / SFR_model × 100 %` for a given scope (cage / pond / trial / subset). The **horizontal axis of the cross plot**.

**Relationships**: companion to SGR ratio. Quadrant readings in [`docs/domain/methodology-cross.md`](docs/domain/methodology-cross.md) §Visual decoding.

**Example**: "P6 treatment subset sits at ~75% SFR ratio — under-fed even after dropping the weird-close cages."

**Provenance**: `docs/methodology_cross.md`.

---

## SGR ratio

**Avoid**: "growth efficiency".

`SGR_realised / SGR_model × 100 %` for a given scope. The **vertical axis of the cross plot**.

**Relationships**: companion to SFR ratio. Together they decode into the four quadrants (over-fed/over-growing, efficient, inefficient, under-fed/under-growing).

**Provenance**: `docs/methodology_cross.md`.

---

## Forecasting mode

**Avoid**: "extrapolation mode", "spline extension".

A spline-fit mode that **holds α at α(last_sample) past the last measurement** and re-simulates so the trajectory covers the whole cycle window. Contrasts with **modelling mode** which truncates each trajectory at the last sample weight.

**Relationships**: required because four T2 cages (P5C7, P5C9, P5C11, P6C10) have no sample-weight measurements after the trial interim check — modelling mode left 14–35 days of NaN at the trajectory tail for them. Patched at runtime in `pipeline/run_fits.py` (sets `mode="forecasting"` on `fish_growth_model.fit_alpha_spline`). See [ADR-0003](docs/adr/0003-spline-forecasting-mode.md).

**Example**: "Forecasting mode is the only reason P6C10's full trial-window trajectory has values past its single interim sample."

**Provenance**: `docs/decisions_log.md` 2026-05-07 entry "left-censored unblock + spline forecasting mode".

---

## Initial-biomass weighting

**Avoid**: "weighted mean" alone (which weight?), "biomass-weighted" (also ambiguous — initial vs daily).

The cohort-aggregation convention used in this project: per-cage weight = `W_sim_start × n_fish_start / 1000` (kg), evaluated **at the trial start**. Used to combine cage-level SGR estimates into pooled `(pond, group)` and `(trial, group)` aggregates.

**Relationships**: contrasts with cage-day-weighted aggregation (Σ over cage-day cells) used for SFR. Both are correct per their domain; the asymmetry exists because SGR is a per-cage quantity over a window, while SFR is naturally a per-cage-day quantity. The pooled SFR formula `Σ feed_kg × 100 / Σ biomass_kg` is mathematically the **daily-biomass-weighted** mean of cage-day SFRs.

**Example**: "Pooled SGR weights big cages more, which matches the operational question (whole-cohort growth)."

**Provenance**: `docs/methodology_sgr.md` §Aggregation; `docs/methodology_sfr.md` §5.

---

## Subset

**Avoid**: "the special set" (vague), "subgroup" (used elsewhere).

In `analyses/cross/run.py`, a **hand-picked overlay** rendered as diamond markers in the same group colour. Used to sanity-check the cohort's headline numbers against an alternative cage selection.

Currently one subset:
- **`P6 T (5,6,11)`** — the three Pond-6 treatment cages that completed a clean harvest in 2023. Excludes P6C12 (only 1 000/5 350 fish landed) and P6C3, P6C4 (transfer-closed Jan 2024 with large CA write-offs — already books-noisy-filtered).

**Relationships**: defined in the `SUBSETS` constant at the top of `cross/run.py`. The diamond marker on the cross plot shows whether removing the operationally-weird cages changes the headline reading. For P6, the answer is "no — still under model on both axes".

**Provenance**: `docs/methodology_cross.md` §Subsets.

---

## Pre-trial window

**Avoid**: "the baseline", "before the trial".

The **2-month pre-trial baseline window**, `2023-05-20 → 2023-07-19` (61 days). Identical for T1 and T2 (both trials started 2023-07-20).

**Relationships**: feed source must come from MDF's `DailyFeedKg` because the workbook only covers the trial window onward. Used by `analyses/pretrial/run.py` to produce a "pre vs trial" comparison and an extended-window plot. The extended plot stitches workbook feed inside the trial window with MDF feed outside (see [ADR-0004](docs/adr/0004-hybrid-feed-source-workbook-and-mdf.md)).

**Example**: "Pre-trial T2 control vs treatment SGR was 0.117 vs 0.096 — treatment was already slower before alt-day feeding started."

**Provenance**: `docs/methodology_pretrial.md`.

---

## P3C4

**Avoid**: "the bad cage" (project has several problem cages), "cage 4 in pond 3" verbose.

A specific cage in Pond 3 that has **multiple data corruption issues** and is hardcoded-dropped from every analysis:

- Recorded `initial_date` is 2023-03-30 (~4 months before T1 start).
- Initial weight 285 g, interim weight 143 g — a 50% drop the 2023 report acknowledged as a sampling artefact.
- An MDF stocking row at 500 g (~10× expected for fingerlings).

**Relationships**: hardcoded in `_common.HARDCODED_DROPS = {(3, 4)}`; the 500 g stocking row is also explicitly excluded in `pipeline/build_snapshot.py`'s `EXCLUDE_ROWS`. Tracked upstream as MDF open question **OQ-011** ("stocking-day mercatus weight outliers slip past 02b's residual-centred MAD"). P3C4 generates two overlapping cycles in MDF; the second cycle (`926_2023-05-17`) is degenerate (no day-0 anchor — see the May 2026 session notes in `docs/decisions_log.md`).

**Example**: "P3C4 is dropped before any books-noisy filter even runs — it's a `HARDCODED_DROPS` member."

**Provenance**: `docs/filters_and_drops.md` §Filter 3.

---

## P6C10

**Avoid**: "the slow cage" (others are also slow).

A Pond 6 control cage with **genuinely slow growth** that was originally left-censored by MDF's SGR step 02 (no plot, no fit). After MDF dropped the upstream skip on 2026-05-07, P6C10 fits cleanly via the **spline branch** (mean FittedSGR ~0.04 %/day in trial vs ~0.22 for the sibling P6 control P6C9). The parametric branch hits the `log_alpha` lower bound (alpha=0.333); the spline fit is what's used (`FitMode='spline'`).

**Relationships**: sits at 7.26% on the books-noisy filter (under the 9% threshold), so it's IN the cohort. The fit is honest, not broken — the underlying older measurements confirm genuine slow growth.

**Example**: "P6C10 stays in the cohort and reads as a slow-growing cage, not an outlier."

**Provenance**: `docs/filters_and_drops.md` §P6C10; `docs/decisions_log.md` 2026-05-07.

---

## Raw weight samples

**Avoid**: "the per-fish data" alone.

**32,595 per-fish rows** extracted from **44 monthly McFarlane's workbooks** spanning January 2023 → November 2023 + October McFarlane's 23-10-24. Lives under `data/raw_weight_samples_2023/` (post-migration: `Data/raw_weight_samples_2023/`).

**Relationships**: aggregated to 600 cage-date averages (152 inside the trial window). Comparison report `comparison_vs_mdf_sharepoint.md` showed **152/152 trial-window matches agree with MDF SharePoint within 1%** — a validation of the legacy SharePoint export. Injected into the snapshot as `mcfarlane_raw_2023` (tier priority: raw > sharepoint > mercatus).

**Example**: "All 78 trial-window points overlap raw within 1%, so the dedup choice is purely about SEM, not value."

**Provenance**: `docs/decisions_log.md` 2026-05-06 entry.

---

## MDF (MercatusDataFeed)

**Avoid**: "the data feed" alone, "Mercatus" (the platform vs. our wrapper around it).

The sister Python repo at `/home/rndmanager/PycharmProjects/MercatusDataFeed`. Provides the SGR step modules (`processing.sgr_growth_modelling.step02_*`), the cleaned IBD parquet, and the SGR fitting infrastructure that this project reuses **via runtime monkey-patches** in `pipeline/run_fits.py`. MDF source is not modified by this project.

**Relationships**:
- The MDF venv (`MercatusDataFeed/.venv/bin/python`) is the Python this project runs with.
- The cycle ledger lives at `/mnt/data/mercatus/cycle_ledger/` and MDF maintains it.
- This project's `pipeline/build_snapshot.py` builds a **clipped, trial-injected** local copy at `pipeline/ledger_snapshot/`.

**Example**: "Reproduce the fits by activating the MDF venv and running run_fits.py — patches happen at import time."

**Provenance**: README.md §External dependencies.

---

## growth_models

**Avoid**: "the growth model" (ambiguous — there are many model surfaces).

The Python package at `/home/rndmanager/PycharmProjects/GrowthModels/src/growth_models` providing the **Nov-2024 SFR/SGR model surfaces**. Used in this project as `growth_models.sfr(weight, temp)` and `growth_models.sgr(weight, temp)`. Validity envelope: weight 1–4000 g, temp 8–28 °C.

**Relationships**: separate sister repo. Imported into pipeline/analysis scripts via `sys.path` insert at script load.

**Example**: "Model SGR is `growth_models.sgr(W_sim_today, T_today)` averaged over the trial window."

**Provenance**: README.md §External dependencies.
