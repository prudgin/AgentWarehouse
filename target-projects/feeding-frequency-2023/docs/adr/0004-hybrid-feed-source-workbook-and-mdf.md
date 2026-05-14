# ADR-0004 — Hybrid feed source: workbook inside trial window, MDF outside

**Status**: accepted.
**Date**: 2026-05-07 (decision); 2026-05-14 (ADR captured).
**Provenance**: `docs/methodology_pretrial.md` §Extended SFR ratio plot.

## Context

Two feed sources are available per cage-day:

- **Workbook** (`data/feed_daily.csv`, extracted from `source/Data analysis feeding strategy.xlsx`) — covers only the **trial window** (2023-07-20 → 2023-09-20 for T1 / 2023-09-06 for T2). One row per cage-day with `feed_kg` (blank = 0 kg).
- **MDF** (`DailyFeedKg` column on the cycle_days parquet, from the live cycle ledger) — covers the **whole cycle** including pre-trial and post-trial periods. Continuous.

Across the trial window, the two sources agree to **~1.6% overall** but differ day-by-day on a handful of dates (see `pipeline/audits/feed_compare.csv`). Two cells in `feed_daily.csv` are operator-entry typos (`P3C6 2023-09-08: 91.7 kg`; `P3C11 2023-09-20: 35.9 kg`) — both propagated to MDF as well, so both sources have them; this project drops them via `DROP_FEED_DAYS`.

For the trial-window analyses (`analyses/sfr/`, `analyses/cross/`), either source works. The extended-window pretrial analysis (`analyses/pretrial/` §Extended SFR ratio plot) needs **continuous coverage** that workbook can't provide — it spans pre + trial + post windows.

## Decision

**Feed source is a parameter** on `analyses/_common.build_cage_day(feed_source=...)` with two valid values:

- **`"workbook"`** — uses `data/feed_daily.csv`. **Default** for trial-window analyses (SFR, Cross). This keeps the trial-window numbers consistent across all plots — every plot of the trial window uses the same per-cage-day feed values.
- **`"mdf"`** — uses MDF `DailyFeedKg`. Used by **pretrial** for the pre/trial baseline comparison and the extended-window plot.

The extended-window plot specifically uses a **hybrid stitching strategy**:
- **Inside the trial window**: `workbook` source (so trial-window weeks match `analyses/sfr/plots/plot_model_anchored_ratio.png` exactly).
- **Outside the trial window** (pre and post): `mdf` source (so pre/post-trial coverage extends continuously).

The stitch happens at the trial window boundary on a per-trial basis. T2's post-trial extent runs to the earliest cycle end among its books-clean cages (P6C5 / P6C6 / P6C11, 2023-11-06).

## Consequences

- **Trial-window plots are all consistent** with each other (same feed source).
- **The extended-window plot has a visible source-stitch at the trial boundary** in principle, but in practice the two sources agree well enough (~1.6%) that the stitch is invisible at the plot's resolution.
- **Reproducibility note**: any analysis that uses both pre-trial and trial-window feed in a single weekly aggregate (none currently, but a future one might) needs to make the source choice explicit.
- **DROP_FEED_DAYS** applies regardless of source — both workbook and MDF carry the same two typos for `(P3C6, 2023-09-08)` and `(P3C11, 2023-09-20)`.

## Alternatives considered

- **Use MDF for everything.** Cleanest single-source story. Rejected because the workbook is the **canonical record of what was fed during the trial** (the trial operator entered the numbers in real time; MDF is downstream and includes the same typos plus a few additional drift cells).
- **Use workbook for everything; drop the extended-window plot.** Loses the cleanest visual demonstration that the pre/post-trial behaviour is comparable across treatment and control within each trial — which is the strongest evidence that the pre-trial baseline is a valid control.
- **Manually reconcile workbook vs MDF discrepancies and pick a "best" source per day.** Excessive work for ~1.6% disagreement that doesn't shift any conclusion. The audit lives in `pipeline/audits/feed_compare.csv` for anyone who wants to investigate.
