# Intake notes — feeding-frequency-2023

Session: 2026-05-14. Second of three sibling FeedingFrequency projects to migrate (after `juvenile`, before `frequency-ras`).

## Audit of source repo `/home/rndmanager/PycharmProjects/FeedingFrequency/FeedingFrequency2023`

**Tree** (depth 3, abridged):
```
FeedingFrequency2023/
├── README.md                                 (knowledge-dense, ~150 lines, project history + results)
├── extract.py                                (workbook → CSVs)
├── .gitignore
├── source/
│   ├── Data analysis feeding strategy.xlsx   (canonical input)
│   └── Final report McFarlane's_DS.docx      (canonical input)
├── data/
│   ├── feed_daily.csv, cage_weekly.csv, cage_weights.csv, pond_weekly.csv
│   ├── schema.md
│   └── raw_weight_samples_2023/              (per-fish monthly workbook extracts)
├── pipeline/
│   ├── build_manifest.py, build_snapshot.py, run_fits.py
│   ├── manifest.csv, cage_weights_with_unit_ids.csv
│   ├── fits/, audits/, ledger_snapshot/, clean/, working/, state/
├── analyses/
│   ├── _common.py, cages_used.csv
│   ├── sgr/, sfr/, cross/, pretrial/, context/        (each: run.py + outputs + plots/)
└── docs/
    ├── data_pipeline.md
    ├── filters_and_drops.md
    ├── decisions_log.md                      (3 session entries — split candidate)
    ├── methodology_sgr.md, methodology_sfr.md, methodology_cross.md, methodology_pretrial.md
```

No git history. No `glossary.md`, no `docs/adr/`, no `.tickets/`, no `.claude/`.

### What the existing docs cover

**README.md**: project framing (re-analysis of Aquna's 2023 Murray cod feeding-frequency trials at McFarlane's), layout, reproduce instructions, cohort and trial design tables, headline results, external dependencies. High-quality starting state.

**docs/decisions_log.md**: 3 reverse-chronological session entries (2026-05-07 tidy-up, 2026-05-07 CUTOFF_DATE split, 2026-05-07 left-censored unblock + spline forecasting mode, 2026-05-06 overnight session notes). Append-only style. Contains both load-bearing decisions (forecasting mode, CUTOFF_DATE split, raw injection priority) and operational session-by-session changes (`sgr_diagnostics/` + `sgr_rerun/` → `pipeline/` rename, etc.). Split candidates pass 3-of-3 admission test.

**docs/methodology_*.md**: per-analysis methodology (SGR, SFR, Cross, Pretrial). Each ~80-150 lines. These are **canonical** for the project — they describe what the analyses compute. Belongs in `docs/domain/` post-migration (kebab-case rename: `methodology_sgr.md` → `methodology-sgr.md`).

**docs/data_pipeline.md**: 5-stage chain from source workbook through analyses. Canonical. → `docs/domain/data-pipeline.md`.

**docs/filters_and_drops.md**: catalogues the books-clean filter ladder (32 / 48 cages). Canonical. → `docs/domain/filters-and-drops.md`.

**data/schema.md**: extracted-CSV column inventory. → keep at `Data/schema.md` (lives next to the data it documents, in the SharePoint-synced Data dir).

### External dependencies (carry over verbatim — paths are absolute)

- `growth_models` package at `/home/rndmanager/PycharmProjects/GrowthModels/src` (Nov-2024 SFR/SGR surface).
- `MercatusDataFeed` (MDF) at `/home/rndmanager/PycharmProjects/MercatusDataFeed`:
  - venv: `MercatusDataFeed/.venv/bin/python`
  - SGR step modules in `MDF/processing.sgr_growth_modelling`
  - runtime monkey-patches (forecasting mode, custom marker styles, trial-window vlines)
- Live cycle ledger at `/mnt/data/mercatus/cycle_ledger/` (read-only).
- Raw OData exports at `/mnt/data/mercatus/raw/odata_exports/` (used by `analyses/context/`).

All absolute paths → survive the `~/PycharmProjects/...` → `~/ResearchProjects/...` move. The internal references to "MDF venv" stay valid; the project will continue to use the sister repo's venv until/unless it gets its own.

## SharePoint state (as of 2026-05-14)

`sharepoint_planning:PROJECTS/2023 Feeding frequency/`:

```
Root files:
  Data analysis feeding strategy.xlsx        (duplicate of local source/)
  Final report McFarlane's_DS.docx           (duplicate of local source/)
  Final report McFarlane's_DS.pdf            (PDF rendering of the final report)
  Twice daily feeding protocol.docx
  Twice daily feeding protocol DS COPY.docx
  Feeding strategy protocol.docx
  mcfarlane treatment allocation.xlsx
  mcfarlane treatment allocation DS.xlsx

Subfolders:
  2026 review/                               (recent review materials, 6 items)
  Feed sheets strategy trial/                (workbook drafts/intermediates, 6 items)
  Feeding strategy project/                  (earlier-phase project material, 5 items)
  McFarlane's feeding trial_DS data/         (Deepika's primary data archive, 18 items)
```

### Subfolder mapping (decided 2026-05-14, option "Map into template dirs")

| SharePoint subdir | Target template dir | Rationale |
|---|---|---|
| `McFarlane's feeding trial_DS data/` | `Data/raw-mcfarlane-2023/` | Raw data archive — lives next to extracted CSVs |
| `2026 review/` | `Reports/2026-review/` | Recent review materials = report-track artefacts |
| `Feed sheets strategy trial/` | `Proposal/` | Proposal-era trial design artefacts |
| `Feeding strategy project/` | `Proposal/` | Earlier-phase project material, also proposal-era |

Root protocol/treatment docs collapse into `Proposal/`:
- `Twice daily feeding protocol.docx`, `Twice daily feeding protocol DS COPY.docx`, `Feeding strategy protocol.docx` → `Proposal/`
- `mcfarlane treatment allocation.xlsx`, `mcfarlane treatment allocation DS.xlsx` → `Proposal/`

Final reports:
- `Final report McFarlane's_DS.docx`, `Final report McFarlane's_DS.pdf` → `Reports/`

Extraction source:
- `Data analysis feeding strategy.xlsx` → `Data/source/` (matches local `source/` placement)

## Project framing (from README.md and methodology docs)

**WHAT**: Re-analysis of Aquna's 2023 Murray cod feeding-frequency trials at McFarlane's site. Two parallel trials:
- **Trial 1** (Ponds 1, 3): twice-daily vs once-daily feeding, 2023-07-20 → 2023-09-20 (9 weeks).
- **Trial 2** (Ponds 5, 6): every-second-day vs once-daily feeding, 2023-07-20 → 2023-09-06 (7 weeks).

Final cohort: **32 cages** (books-clean filter, see `filters_and_drops.md`). Outputs: SGR (specific growth rate), SFR (specific feed rate), Cross (SFR vs SGR ratio), and a pre-trial baseline + extended-window plots that span pre/trial/post windows.

**Headline finding**: T1 treatment (twice/day) over-feeds slightly and modestly out-grows control. T2 treatment (alt-day) under-feeds and clearly under-grows — but the pre-trial baseline shows roughly half the T2 deficit was inherited cohort weakness (treatment cages were already growing slower than their T2 controls before alt-day feeding started).

**WHY**: Aquna's operational decision — should McFarlane's site adopt a non-once-daily regime? The original 2023 report (Deepika Satchithananthan) found inconclusive results; the re-analysis adds: a single books-clean canonical cohort, trajectory-anchored endpoint SGR (vs two-point ln-form from sample noise), model-anchored SFR/SGR comparisons against the Nov-2024 model surface, and the pre-trial baseline cohort separation.

**HOW** (reproduce, after migration to `~/ResearchProjects/2023 Feeding Frequency/`):

```bash
PY=/home/rndmanager/PycharmProjects/MercatusDataFeed/.venv/bin/python
# 1. Extract source workbook
$PY scripts/extract.py
# 2. Pipeline (re-run only if ledger or filters change)
$PY -m feeding_frequency_2023.pipeline.build_manifest
$PY -m feeding_frequency_2023.pipeline.build_snapshot
$PY -m feeding_frequency_2023.pipeline.run_fits     # ~5 min
# 3. Analyses (cheap)
$PY -m feeding_frequency_2023.analyses.sgr.run
$PY -m feeding_frequency_2023.analyses.sfr.run
$PY -m feeding_frequency_2023.analyses.cross.run
$PY -m feeding_frequency_2023.analyses.pretrial.run
$PY -m feeding_frequency_2023.analyses.context.plot_do
$PY -m feeding_frequency_2023.analyses.context.plot_treatments
```

(Code-loading idiom will need an update post-move — the existing `sys.path` inserts in `pipeline/run_fits.py` and `extract.py` continue to work because they target absolute paths. The `src/feeding_frequency_2023/` package structure should be set up with `pyproject.toml` + `pip install -e .` in the MDF venv, OR retain the current "scripts that just import" idiom — see Open question 1 below.)

**Status**: The re-analysis is **complete** as of 2026-05-07. All four analyses + context plots run end-to-end. Headline numbers are stable. The project is in **maintenance / occasional-extension** mode, not active development.

## Glossary seeds (to draft inline)

**Trial mechanics**:
- **McFarlane's** (the site / 2023 trial). Distinguish from the Bilbul juvenile project's site.
- **Trial 1 (T1)**: twice/day vs once/day, Ponds 1+3, 63 days, 9 weeks.
- **Trial 2 (T2)**: alt-day vs once/day, Ponds 5+6, 49 days, 7 weeks.
- **Trial window** vs **pre-trial window** (2023-05-20 → 2023-07-19; identical for both trials).
- **Books-clean cohort** (32 of 48 cages).
- **Group assignments** by pond (in glossary or domain — likely domain).

**Re-analysis vocabulary**:
- **Realised SGR** (endpoint-implied from spline trajectory; %/day).
- **Model SGR** (Nov-2024 `growth_models.sgr` surface; %/day).
- **Realised SFR** (Σ feed_kg × 100 / Σ biomass_kg over a cage-day window; %).
- **Model SFR** (Nov-2024 `growth_models.sfr` surface; %).
- **SFR ratio** / **SGR ratio** (realised / model × 100 %).
- **Forecasting mode** (spline α held constant past last sample — see ADR).
- **Initial-biomass weighting** (cohort aggregation convention).
- **Subset** (in cross.py: hand-picked overlay like `P6 T (5,6,11)`).
- **Pooled** (trial-pooled, biomass-weighted across ponds).

**Filter mechanics**:
- **Books-noisy** (`|adj_daily_pct × trial_days| > 9%`).
- **adj_daily_pct** (`(A_count + CA_count) / Σ(daily_open_count) × 100`).
- **A_count** (operator inventory adjustments) vs **CA_count** (system close-day reconciliation).
- **HARDCODED_DROPS** (P3C4 by name).
- **DROP_FEED_DAYS** (individual cage-day cells dropped, two of them).

**External-data terms**:
- **MDF ledger** / **cycle ledger** (`/mnt/data/mercatus/cycle_ledger/`).
- **CycleId** (Mercatus cycle identifier — joins cage to growth ledger).
- **UnitId** (Mercatus cage identifier).
- **mcfarlane_raw_2023** / **mcfarlane_trial_2023** (injected snapshot sources).
- **Raw weight samples** (per-fish workbook extracts; 32,595 rows from 44 monthly workbooks).
- **MDF SharePoint comparison** (legacy sample-weights validation step).

**Problem cages** (operational vocabulary that recurs across docs):
- **P3C4** (hardcoded drop — corrupt sampling; MDF OQ-011).
- **P6C10** (left-censored, now accepted as-is, genuinely slow growth).
- **The 6 books-noisy cages**: P1C1, P1C6, P1C7, P3C5, P6C4, P6C12.

## ADR candidates (3-of-3 admission test)

The decisions_log.md contains ~10 substantive decisions; applying 3-of-3 (hard to reverse, surprising without context, real trade-off) yields:

1. **Trajectory-anchored endpoint SGR** (vs the 2023 report's two-point ln-form `(ln W_interim − ln W_initial) / days`). 
   - Hard-to-reverse: ✓ all downstream stats hinge on this estimator.
   - Surprising: ✓ doesn't reproduce report Table 1; trial-1 SGRs flip from negative to positive (0.18-0.30 %/day).
   - Real trade-off: ✓ depends on spline quality and forecasting-mode assumption. → **ADR-0001**.

2. **Books-clean filter at 9% threshold**. 
   - Hard-to-reverse: ✓ changes cohort size (48 → 32).
   - Surprising: ✓ 6 cages drop for non-obvious bookkeeping reasons (P1C1, P1C6, P1C7, P3C5, P6C4, P6C12).
   - Real trade-off: ✓ threshold is a deliberate round number; alternative bases exist (cycle_books_pct_compare.csv). → **ADR-0002**.

3. **Spline forecasting mode** (vs modelling mode in MDF SGR step). 
   - Hard-to-reverse: ✓ trajectory tail differs by 14-35 days for 4 T2 cages.
   - Surprising: ✓ default MDF behaviour is modelling mode; this project monkey-patches.
   - Real trade-off: ✓ forecasting bakes in last-sample dynamics past the last measurement. → **ADR-0003**.

4. **Hybrid feed source** (workbook within trial window, MDF DailyFeedKg outside). 
   - Hard-to-reverse: moderate — extended-window plot is the only consumer.
   - Surprising: ✓ two sources agree to ~1.6% overall but differ day-by-day.
   - Real trade-off: ✓ keeps trial-window numbers consistent across all plots, but stitches feed sources at the trial boundary. → **ADR-0004**.

Operational entries in `decisions_log.md` that **don't** pass 3-of-3 (archived to `docs/adr/_legacy-decisions-log.md` for reference):
- 2026-05-07 project tidy-up (`sgr_diagnostics/` + `sgr_rerun/` → `pipeline/`, file moves, output renames). Mechanical refactor.
- `CUTOFF_DATE` split into `CYCLE_START_CUTOFF` + `DATA_END_CUTOFF`. Operational; both happen to be at 2023-12-31.
- P3C4 hardcoded drop. Stated rationale (corrupt sampling, MDF OQ-011) is fully covered in `filters_and_drops.md` — adding an ADR duplicates content with no decision to defend.
- P6C10 acceptance. Covered in `filters_and_drops.md`.
- Workbook date typo fix in `extract.py`. Trivial.

## Open questions (resolved by user 2026-05-14 — pre-intake-round)

1. **Q1 — Project name casing**: SharePoint to be renamed `2023 Feeding frequency` → `2023 Feeding Frequency`. ✓ confirmed.
2. **Q2 — SharePoint subfolder remap**: map non-standard subdirs into `Data/`, `Reports/`, `Proposal/` (as catalogued above). ✓ confirmed.
3. **Q3 — Code locus**: `extract.py` → `scripts/`; `pipeline/` and `analyses/` → `src/feeding_frequency_2023/`. ✓ confirmed.
4. **Q4 — `source/` files**: xlsx → `Data/source/`; docx → `Reports/`. ✓ confirmed.

## Open questions (post-migration; user can decide later, no blocking)

1. **Package install model**. Currently scripts use direct `sys.path` inserts to import `growth_models` and MDF internals. After moving code into `src/feeding_frequency_2023/`, do we:
   - **(a)** Add a `pyproject.toml` and `pip install -e .` into the MDF venv (clean, modular)?
   - **(b)** Keep `sys.path` inserts (no change to import idiom)?
   
   Recommend (b) for the migration itself (minimise breakage), defer (a) to a separate ticket. The `__init__.py` files inside `src/feeding_frequency_2023/` need to exist either way for relative imports to work; the scripts under `scripts/` adjust their `sys.path` inserts to point at the new location.

2. **Whether to write a "re-analysis 2026-05" investigation retroactively**. The four methodology docs + the decisions log together describe a complete reanalysis arc (May 2026). Per warehouse conventions, this would conventionally land at `analysis/2026-05-07-mcfarlane-reanalysis/INVESTIGATION.md` with the methodology docs as finalised promotions. But the work is already done and documented — a retroactive INVESTIGATION may not add value. Default: skip. Document the existing methodology docs as the authoritative writeups, and let any future re-runs trigger a fresh `analysis/<date>/`.

3. **`FrequencyRAS` sibling**. The RAS sibling is the third migration in this batch. It may want to share methodology vocabulary with this project (books-clean cohort approach, model-anchored ratios). When migrating it, watch for opportunities to point its glossary back here rather than re-defining.
