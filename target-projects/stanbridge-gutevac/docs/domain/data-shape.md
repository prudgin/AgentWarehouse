# Data shape

Where the trial data lives, where the upstream operational data lives, the columns each consumes, and the hard rules for handling them.

For per-term definitions see [`../../glossary.md`](../../glossary.md). For the pond-selection procedure (to be authored) that will produce the cohort ponds see [`../reference/pond-selection.md`](../reference/pond-selection.md). For methodological decisions see the ADRs in [`../adr/`](../adr/).

---

## 1. Trial recording — the data files that live on SharePoint

The trial's primary outputs live under `Data/` (synced bidirectionally to SharePoint).

### `Data/Stanbridge <YYYY-MM-DD>.xlsx` — long-form per-fish records

One row per (pond × timepoint × fish). One file per trial date, growing as timepoints are dissected.

Shape mirrors the sibling Bilbul project's `Data/Bilbul <date>.xlsx`. Adjustments for Stanbridge:

| Bilbul column | Stanbridge column | Notes |
|---|---|---|
| `Farm = "Bilbul"` | `Farm = "Stanbridge"` | constant |
| `Pond` (1–12, Bilbul SiteId) | `Cell` (1–6) | Stanbridge sites are *cells* containing ponds |
| `Cage` (1–8 within a pond) | `Pond` (within a cell) | Stanbridge units are *ponds* within a cell |
| (rest unchanged) | (rest unchanged) | |

Carried verbatim from Bilbul: `Date last fed`, `Time last fed`, `Date harvested`, `Time harvested`, `Date dissected`, `Time dissected`, `Fish number` (1–15), `Length, cm`, `Weight, g`, `K index`, `Pellets count in stomach`, `Wet weight in stomach`, `Feed in stomach, YES/NO`, `Batch wet weight`, `Batch dry weight`, `Feed in intestine, YES/NO`, `Nematode count`, `pellet size mm`, `pellet weight`.

### `Data/Form template.xlsx` — the field-recording form

Per-cohort × timepoint paper form. Same template shape as Bilbul; substitute Stanbridge cell/pond identifiers in the header. Body unchanged (30 fish rows × Length / Weight / Feed in stomach / Distinct pellets count / Only distinct pellets? / Feed in intestine / Red worms count).

### File naming

- One long-form Excel per **trial date**: `Stanbridge YYYY-MM-DD.xlsx`. Append cohorts and timepoints as they are dissected. Successive trial dates get separate files; merge in code.
- One form template per cohort × timepoint: `Form template.xlsx` (reused).

### Hard rule: pellet-count and wet-stomach columns null after mush

Pellet counts and per-fish wet stomach weights are recorded **only while pellets remain distinct** (no mush). Once mush appears in a batch, both columns are null for that batch onwards. See `glossary.md` → "Mush" and "Pellet-count cross-check".

### Hard rule: batch wet/dry weights repeat across the 15 rows

`Batch wet weight` and `Batch dry weight` are batch-level — one measurement per (pond × timepoint × 15-fish pool). The Excel writes the same value into all 15 rows. In code: group by (pond, timepoint) and take `.first()` for these columns.

---

## 2. Mercatus data streams (upstream context for pond selection)

The pond-selection procedure (to be authored at `docs/reference/pond-selection.md`) consumes data streams from the user's MercatusDataFeed pipeline. These do **not** drive the GER fit directly — they pick which ponds become the cohorts.

### 2.1 Canonical Stanbridge scope: 78 ponds

| Hierarchy level | Value |
|---|---|
| Operation | `OperationCode='OG'` (Ongrowing) |
| Region    | `RegionCode='OR'` (Ongrowing region) |
| **Area**  | `AreaCode='STA'`, `AreaName='Stanbridge'` |
| Sites (Cells) | `SC1`–`SC6` (Stanbridge Cell 1 – Stanbridge Cell 6) |
| Units (Ponds) | UnitIds 1636–1673 and 1853–1895 (two non-contiguous blocks) |

Every Stanbridge row has `StructureType == 'pond_in_cell'` and `HasCycleHistory == True`. The published `cycle_ledger/units.parquet` is pre-curated — `AreaCode == 'STA'` yields exactly 78 production ponds.

```python
import pandas as pd
units = pd.read_parquet("/mnt/data/mercatus/cycle_ledger/units.parquet")
scope = units[units["AreaCode"] == "STA"].copy()
assert len(scope) == 78, "Stanbridge scope must be 6 cells totalling 78 ponds"
```

Friendly labels for display: `UnitFriendlyName` (`"Stanbridge Cell 1 Pond 05"`), `SiteFriendlyName` (`"Stanbridge Cell 1"`). All business dates are **Sydney local time** (`Australia/Sydney`).

### 2.2 Temperature — per pond, daily

**Source:** `/mnt/data/mercatus/cycle_ledger/cycle_days.parquet`
**Grain:** one row per `(CycleId, UnitId, LocalDate)`.

| Column | Meaning |
|---|---|
| `Temperature` | Pond water °C for that day. |
| `TemperatureSmoothed` | Rolling-smoothed version; preferred for growth modelling. |

Stanbridge scope (audited 2026-05-18): 34,063 rows covering all 78 ponds, 34,062 with non-null `Temperature`, current through 2026-05-17. Span 2024-03-27 → 2026-05-17.

```python
import pandas as pd

UNITS_PARQUET = "/mnt/data/mercatus/cycle_ledger/units.parquet"
DAYS_PARQUET  = "/mnt/data/mercatus/cycle_ledger/cycle_days.parquet"

def load_pond_temperature() -> pd.DataFrame:
    units = pd.read_parquet(UNITS_PARQUET,
        columns=["UnitId", "SiteCode", "SiteFriendlyName", "UnitFriendlyName", "AreaCode"])
    sta = units[units["AreaCode"] == "STA"]
    days = pd.read_parquet(DAYS_PARQUET,
        columns=["UnitId", "LocalDate", "Temperature", "TemperatureSmoothed"])
    df = days[days["UnitId"].isin(sta["UnitId"])].dropna(subset=["Temperature"])
    return df.merge(sta[["UnitId", "SiteCode", "UnitFriendlyName"]], on="UnitId") \
             .sort_values(["UnitId", "LocalDate"]).reset_index(drop=True)
```

### 2.3 Oxygen — per pond, daily

**Source:** `/mnt/data/mercatus/raw/odata_exports/vReportingBaselineInventoryByDay.csv` — column `Oxygen`, grain `(UnitId, Date)`.

Stanbridge scope (audited 2026-05-18): 34,268 rows covering all 78 ponds; 34,062 with non-null `Oxygen`. Span 2024-03-27 → 2026-05-17 (~770 days per pond). Values appear well-behaved within `[0, 25.5]` mg/L — apply a `[0, 25]` sanity bound for safety.

```python
import pandas as pd

INV_CSV = "/mnt/data/mercatus/raw/odata_exports/vReportingBaselineInventoryByDay.csv"

def load_pond_oxygen(scope_unit_ids: set[int]) -> pd.DataFrame:
    df = pd.read_csv(INV_CSV, low_memory=False,
                     usecols=["UnitId", "Date", "Oxygen"],
                     parse_dates=["Date"])
    df = df[df["UnitId"].isin(scope_unit_ids)
          & df["Oxygen"].between(0, 25)].copy()
    df["LocalDate"] = df["Date"].dt.tz_convert("Australia/Sydney").dt.normalize()
    return (df.rename(columns={"Oxygen": "O2_mgL"})
              [["LocalDate", "UnitId", "O2_mgL"]]
              .sort_values(["UnitId", "LocalDate"])
              .reset_index(drop=True))
```

> **Don't be tempted by the OM5 cluster-level feed.** There is *also* a cluster-grain oxygen series in `/mnt/data/mercatus/raw/odata_exports/vReportingBaselineEnvironment.csv` (`EnvironmentParamCode == 'OM5'`, `Level == 'Cluster'`) where each Stanbridge cluster covers a whole cell (9–15 ponds) rather than a single pond. That's a **different aggregation**, not the right source for pond-grain selection. The Bilbul project's data-shape doc points at the environment CSV because at Bilbul cluster=pond; that source mapping doesn't transfer. Use `InventoryByDay.Oxygen` here.

### 2.4 Treatments — per pond dosing events

**Source:** `/mnt/data/mercatus/raw/odata_exports/vReportingBaselineTreatment.csv` (UnitId grain — *not* curated into `cycle_ledger/`).

To audit before relying on it: confirm Stanbridge UnitIds appear in the treatment export, profile the product mix, and flag whether the treatment cadence differs materially from Bilbul. (TODO during first investigation that needs it.)

### 2.5 Feeding — per pond per day

**Source (preferred):** `/mnt/data/mercatus/cycle_ledger/cycle_feedings.parquet` — curated, already attributed to cycles. UnitId grain.

For a daily-aggregated view (one row per UnitId × LocalDate), use `cycle_ledger/cycle_days.parquet` columns `DailyFeedKg` and `DailyFeedKgSmoothed`. Feed dimension (supplier, type, size, energy, medicated flag) is in `raw/odata_exports/vReportingBaselineFeed.csv`.

**All Stanbridge cohorts are on floating feed.** No sinking-vs-floating asymmetry. The pond-selection SFR-band thresholds therefore apply uniformly across cohorts (single band — see [glossary "SFR band"](../../glossary.md#sfr-band)).

```python
import pandas as pd

CYCLE_FEEDINGS = "/mnt/data/mercatus/cycle_ledger/cycle_feedings.parquet"

def load_feedings(scope_unit_ids: set[int]) -> pd.DataFrame:
    df = pd.read_parquet(CYCLE_FEEDINGS)
    df = df[df["UnitId"].isin(scope_unit_ids)].copy()
    return df.sort_values(["UnitId", "LocalDate"]).reset_index(drop=True)
```

---

## 3. What's tracked vs gitignored

| Path | Status | Why |
|---|---|---|
| `Data/Stanbridge <date>.xlsx` | tracked (and **synced to SharePoint**) | Canonical trial data. Small. |
| `Data/Form template.xlsx` | tracked (and synced) | Recording template. |
| `Articles/*.pdf` | tracked (synced) | Reference literature. |
| `Proposal/*` | tracked (synced) | Canonical methods document. |
| `Reports/*` | tracked (synced) | Stakeholder deliverables. |
| `Expenses/*` | tracked (synced) | Finance. |
| `output/` | gitignored (`.gitkeep`) | Regenerated each run. Not synced. |
| `src/`, `scripts/`, `analysis/<dated>/scripts/` | tracked, **not synced** | Code (excluded by `.rclone-filter`). |
| `.venv/`, `__pycache__/`, `.git/`, `.claude/`, `.env` | gitignored, not synced | Standard. |

---

## Provenance

- `/mnt/data/mercatus/README.md` — published cycle-ledger schema (auto-generated 2026-05-17).
- `/mnt/data/mercatus/cycle_ledger/units.parquet` — Stanbridge scope (audited 2026-05-18 during intake).
- `/mnt/data/mercatus/cycle_ledger/cycle_days.parquet` — Stanbridge temperature coverage (audited 2026-05-18).
- `/mnt/data/mercatus/raw/odata_exports/vReportingBaselineEnvironment.csv` — Stanbridge cell-level oxygen (audited 2026-05-18; cluster=cell discovered during intake).
- `/mnt/data/mercatus/raw/odata_exports/vReportingBaselineUnits.csv` — Stanbridge cell→cluster mapping.
- Sibling `2026 Juvenile gut evac` project, `docs/domain/data-shape.md` — structural template.
