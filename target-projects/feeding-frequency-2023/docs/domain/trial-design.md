# Trial design — McFarlane's 2023

Two parallel feeding-frequency trials run at McFarlane's site, 2023-07-20 → 2023-09-20 (T1) and → 2023-09-06 (T2).

## Trials

| Trial | Ponds | Regime — treatment vs control | Window | Weeks | Days |
|---|---|---|---|---|---|
| **T1** | 1, 3 | twice/day vs once/day | 2023-07-20 → 2023-09-20 | 9 | 63 |
| **T2** | 5, 6 | every-second-day vs once/day | 2023-07-20 → 2023-09-06 | 7 | 49 |

## Group assignments (48 cages — full trial design)

| Pond | Treatment cages | Control cages | Excluded |
|---|---|---|---|
| 1 | 7–12 | 1–6 | — |
| 3 | 1–6 | 7–12 | — |
| 5 | 1, 2, 10, 11 | 3, 6, 7, 9 | 4, 5, 8, 12 |
| 6 | 3, 4, 5, 6, 11, 12 | 9, 10 | 1, 2, 7, 8 |

Verified against the per-cage SGR rollups in the source workbook's `Average weight` sheet — exact agreement.

## Books-clean cohort (32 cages)

After all filters (see [`filters-and-drops.md`](filters-and-drops.md)):

| Trial | Pond | Treatment | Control |
|---|---|---|---|
| 1 | 1 | 5 | 4 |
| 1 | 3 | 4 | 5 |
| 2 | 5 | 4 | 4 |
| 2 | 6 | 4 | 2 |

Full per-cage status (including the 16 excluded for various reasons) is in `analyses/cages_used.csv` post-migration (`src/feeding_frequency_2023/analyses/cages_used.csv`).

## Pre-trial window

`2023-05-20 → 2023-07-19` (61 days). **Identical for T1 and T2** — both trials started 2023-07-20. Used by `pretrial/` to establish a cohort-difference baseline; see [`methodology-pretrial.md`](methodology-pretrial.md).

## Weight-check dates

Workbook records two per-cage weight checks:

- **Initial check**: mostly 2023-05-31 (T1) or 2023-06-07 (T2). One exception: P3C4 at 2023-03-30 (~4 months pre-trial — sampling artefact, see `glossary.md` §P3C4).
- **Interim check**: 2023-08-01/02 for T1; mix of 2023-08-02 and 2023-08-11 for T2. **Note**: only 12 days into the T1 trial, 13–23 days into T2.

Neither weight check sits at the trial boundaries. This is why per-cage realised SGR is computed from the **spline trajectory** at the trial-window endpoints rather than from the two checks directly — see [ADR-0001](../adr/0001-trajectory-anchored-endpoint-sgr.md).

## Cycles and the cycle ledger

Each cage maps to a Mercatus **cycle** identified by `CycleId`. `pipeline/build_manifest.py` resolves each cage in `cage_weights.csv` to a `UnitId` and then to the cycle whose `[StartDate, EndDate]` overlaps the cage's `[initial_date, interim_date]`. **40 rows** for the trial cohort (39 unique cages — P3C4 spawned two overlapping cycles).

Cycles, sample weights, and daily inventory live in the live ledger at `/mnt/data/mercatus/cycle_ledger/`. The local snapshot at `pipeline/ledger_snapshot/` is a clipped + trial-injected copy used by the fitting pipeline (see [`data-pipeline.md`](data-pipeline.md)). For inventory / mortality / adjustment reconciliation, **read the live ledger directly** — it has columns the snapshot does not carry (`cycle_mortalities.parquet`, `cycle_cullings.parquet`, `cycle_day_balance.parquet`).

## Headline results (books-clean, trial-pooled)

| Group | n | SFR ratio | SGR ratio |
|---|---|---|---|
| T1 control (once/day) | 9 | 127% | 111% |
| T1 treatment (twice/day) | 9 | **136%** | 118% |
| T2 control (once/day) | 6 | 94% | 86% |
| T2 treatment (alt-day) | 8 | 72% | **68%** |

**Reading**: T1 treatment is over-fed and slightly out-grows control. T2 treatment under-feeds (alt-day cuts intake) and clearly under-grows. The pre-trial baseline (see [`methodology-pretrial.md`](methodology-pretrial.md)) shows the T2 treatment cohort was already growing 0.021 %/day slower than its T2 control counterpart **before** alt-day feeding started — so a non-trivial portion of the T2 deficit is inherited cohort weakness, not regime effect.

## Sites and unit naming

The four ponds are identified in the cycle ledger as **SiteName**s `M01`, `M03`, `M05`, `M06` (referred to colloquially as Pond 1, Pond 3, Pond 5, Pond 6). Cages inside each pond are `UnitName`s 1–12. The `(pond, cage)` tuple is the project's primary key throughout the data and code.
