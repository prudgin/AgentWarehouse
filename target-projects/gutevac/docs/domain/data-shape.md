# Data shape

What the raw data looks like, where it comes from, how to read it, and the hard rules for handling it.

For per-term definitions see [`glossary.md`](../../glossary.md). For the model that consumes this data see [`model.md`](model.md).

---

## The master Excel: `data/raw/Data trimmed.xlsx`

The single Excel file the analysis fits against. One row per pond × timepoint sample. Blank rows separate ponds (drop on load — `Farm` or `Unit` null).

### Columns the analysis uses

| Column (verbatim) | Type | Meaning |
|---|---|---|
| `Batch number` | int | Sequence within a pond. `0` is *not* a reliable t=0 marker — see "Time-zero detection" below. |
| `Farm` | str | Farm identifier (e.g. `Whitton`, `MCF`). |
| `Unit` | str | Pond identifier within the farm (e.g. `P7C5`). Combine with `Farm` to form `pond_id`. |
| `Total fish sampled` | int | Typically 15. |
| `Water temperature at harvest` | float (°C) | Used to set `d_y` (yesterday's-meal age) per pond as the pond mean × 24. |
| `Hours passed` | float (h) | Wall-clock hours since the last feed. |
| `Degree * hours` | float (DH) | **PRECOMPUTED degree-hours since last feed. Use this column directly.** See hard rule below. |
| `%Feed in stomach` | float [0,1] | Fraction of sampled fish with any feed in stomach. Total stomach occupancy. |
| `% Today feed in stomach` | float [0,1] | Non-null only at t=0 rows. The marker for time-zero detection. Source for per-pond `c`. |
| `% old feed in stomach` | float [0,1] | Non-null only at t=0. Flimsy data (typically 0–2 fish out of 15); used for soft validation, **not** in the fit. |
| `%Feed in intestine` | float [0,1] | Fraction of sampled fish with any feed in intestine. The primary observable. |
| `Average weight, g` | float | Optional, descriptive only. |

### Columns the analysis ignores

`Date of last feed`, `Time of harvest`, `K-factor`, `firm pellets`, `model SFR`. Present in the file for trial-management context; not consumed by the fit.

---

## Hard rules

### Never recompute degree-hours from `temp × hours`

The `Degree * hours` column is precomputed using **hourly-grained temperature data** from oxygen-sensor loggers (see Temperature pipeline below). Recomputing as `Water temperature at harvest × Hours passed` uses a single point-estimate of temperature and silently degrades accuracy on ponds where the trial spanned a temperature swing.

If you find code or analysis claiming to "verify" degree-hours by recomputing them this way, it is wrong. The precomputed values are authoritative.

### Time-zero detection

A row is a time-zero observation **iff** `% Today feed in stomach` is non-null. That column is empty at every other timepoint by sampling protocol; it's the unambiguous data-driven marker. Do not infer t=0 from `Batch number == 0` or from `Degree * hours ≈ 0` — both are unreliable (t=0 rows can have small non-zero DH up to about 14 because sampling occurs slightly after the nominal feed cutoff).

A pond may have multiple t=0 rows (e.g. `Whitton/P7C5` has two — average them when computing `c`). A pond may have **no** t=0 row (e.g. `MCF/P8C8` in the current dataset); in that case `c` is imputed from the mean of observed ponds and the report flags the imputation prominently.

### Pond identifier construction

`pond_id = "{Farm}/{Unit}"` — slash-separated. The current dataset:

| `pond_id` | Mean temp (°C) | Timepoints | Mean weight (g) | t=0 row(s)? |
|---|---|---|---|---|
| `MCF/P8C8` | 27.3 | 5 | 3037 | **none** — `c` imputed |
| `Whitton/P7C5` | 23.1 | 7 | 1136 | two |
| `Whitton/P7C2` | 19.9 | 8 | 1959 | one |
| `Whitton/P10C8` | 19.5 | 6 | 1805 | one |

Ponds in oxygen-report data carry a different naming scheme (`Cell`, `Dam`); see the temperature pipeline section below. The two namespaces don't collide inside the analysis — always use `Farm/Unit` as the pond identifier in the gut-clearance work.

---

## Temperature pipeline (upstream of the master Excel)

The `Degree * hours` values in the master Excel come from a separate upstream step that runs whenever new oxygen-logger data arrives:

1. Raw monthly oxygen reports live in `data/raw/Farm 04 Oxygen Reports/*.xlsx` and per-dam ChartData CSVs. **The xlsx files are gitignored** (large, regenerable from the source system); the CSVs are tracked.
2. `scripts/process_temperature.py` reads the relevant date ranges, cleans rolling-z-score outliers, averages duplicate probe readings, resamples to hourly granularity, and writes `data/raw/Farm 04 Oxygen Reports/processed/*hourly.csv`. These hourly CSVs **are tracked**.
3. The hourly temperatures are integrated against trial timepoints to produce DH values that then go into the `Degree * hours` column of `Data trimmed.xlsx` — currently a manual paste step. End-to-end Python integration is on the future-work list (see [`docs/planning/future-work.md`](../planning/future-work.md)).

Note the naming mismatch: the temperature-source data uses `Cell`/`Dam` (physical infrastructure identifiers), while the gut-clearance analysis uses `Farm/Unit` (analysis-level pond identifiers). They are different namespaces; the mapping between them is recorded in the trial book-keeping, not in either dataset.

---

## What's tracked vs. gitignored

| Path | Status | Why |
|---|---|---|
| `data/raw/Data trimmed.xlsx` | tracked | Canonical fit input. Small. |
| `data/raw/degree_hours_recalculated.csv` | tracked | Small derived artefact. |
| `data/raw/Farm 04 Oxygen Reports/*.xlsx` | **gitignored** | 35+ files, grows monthly, regenerable from source system. |
| `data/raw/Farm 04 Oxygen Reports/*.csv` | tracked | One-off ChartData exports. |
| `data/raw/Farm 04 Oxygen Reports/processed/*.csv` | tracked | Small (kB), needed to reproduce DH. |
| `output/` | gitignored (`.gitkeep` placeholder) | Regenerated each run. |
| `reports/*.docx`, `reports/*.pptx` | tracked | Stakeholder deliverables; small enough; want history. |
| `docs/proposal/*.docx` | tracked | Reference artefact (Stage 1 proposal). |
| `archive/old_analysis/` | tracked | Superseded methods; kept for provenance. |
| `.venv/`, `__pycache__/` | gitignored | Standard. |

---

## Provenance

- [`docs/reference/model-spec.md`](../reference/model-spec.md) §"Inputs" — column-level spec the code reads.
- `data/raw/Data trimmed.xlsx` — the file itself.
- `scripts/process_temperature.py` — the temperature-pipeline source.
