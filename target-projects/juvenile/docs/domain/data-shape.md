# Data shape

Where the trial data lives, where the upstream operational data lives, the columns each consumes, and the hard rules for handling them.

For per-term definitions see [`../../glossary.md`](../../glossary.md). For the cage-selection procedure that produced the three cohort cages see [`../reference/cage-selection.md`](../reference/cage-selection.md). For methodological decisions see the ADRs in [`../adr/`](../adr/).

---

## 1. Trial recording — the data files that live on SharePoint

The trial's primary outputs live under `Data/` (synced bidirectionally to SharePoint).

### `Data/Bilbul <YYYY-MM-DD>.xlsx` — long-form per-fish records

One row per (cage × timepoint × fish). One file per trial date, growing as timepoints are dissected.

| Column (verbatim) | Type | Meaning |
|---|---|---|
| `Farm` | str | Always `Bilbul`. |
| `Pond` | int | Site number (1–12). |
| `Cage` | int | Cage number within the pond (1–8). |
| `Date last fed`, `Time last fed` | date, time | t=0 anchor — the test-feed completion. Constant within a cohort. |
| `Date harvested`, `Time harvested` | date, time | When the 15-fish batch was netted out of the cage. One per timepoint. |
| `Date dissected`, `Time dissected` | date, time | When the dissection bench actually opened the fish. |
| `Fish number` | int | 1–15 within a (cage × timepoint) batch. |
| `Length, cm` | float | Per-fish length. |
| `Weight, g` | float | Per-fish weight. |
| `K index` | float | Per-fish condition factor (Fulton's K). |
| `Pellets count in stomach` | int or null | Per-fish discrete-pellet count. Null once **mush** appears in that batch. |
| `Wet weight in stomach` | float or null | Per-fish wet stomach contents — present at early timepoints, null at later ones. |
| `Feed in stomach, YES/NO` | 0/1 | Per-fish binary; feeds the binary stomach clearance curve. |
| `Batch wet weight` | float or null | Pooled wet weight of all 15 stomach contents. **One value per batch**, repeated across the 15 rows of that batch or null if not yet weighed. |
| `Batch dry weight` | float or null | Pooled dry weight of all 15 stomach contents, dried to constant mass. **One value per batch.** Drives `y_rel(t)`. |
| `Feed in intestine, YES/NO` | 0/1 | Per-fish binary; feeds the binary intestine clearance curve. |
| `Nematode count` | int | Per-fish nematode (red worm) count. Side metric. |
| `pellet size mm` | float | Constant per cohort. |
| `pellet weight` | float | Known pellet dry mass (g). Constant per cohort. Used in the pellet-count cross-check. |

### `Data/Form template.xlsx` — the field-recording form

The per-cohort × timepoint paper-form template the dissection team fills in. Header has cage metadata, dish numbers, dish tare, and pre/post-drying weights. Body: 30 fish rows × 8 columns (Length / Weight / Feed in stomach / Distinct pellets count / Only distinct pellets? / Feed in intestine / Red worms count). Mapped into the long-form Excel above by cage + timepoint key.

### File naming

- One long-form Excel per **trial date**: `Bilbul YYYY-MM-DD.xlsx`. Append cohorts and timepoints as they are dissected. Successive trial dates get separate files; merge in code.
- One form template per cohort × timepoint: `Form template.xlsx` (reused — the team duplicates and renames as needed).

### Hard rule: pellet-count and wet-stomach columns null after mush

Pellet counts and per-fish wet stomach weights are recorded **only while pellets remain distinct** (no mush). Once mush appears in a batch, both columns are null for that batch onwards. The pellet-count cross-check is therefore only applicable at early timepoints. See `glossary.md` → "Mush" and "Pellet-count cross-check".

### Hard rule: batch wet/dry weights repeat the value across the 15 rows

`Batch wet weight` and `Batch dry weight` are batch-level — one measurement per (cage × timepoint × 15-fish pool). The Excel writes the same value into all 15 rows for grep-friendliness. In code: group by (cage, timepoint) and take `.first()` for these columns.

---

## 2. Mercatus data streams (upstream context for cage selection)

The cage-selection procedure (see [`../reference/cage-selection.md`](../reference/cage-selection.md)) consumes four data streams from the user's MercatusDataFeed pipeline. These do **not** drive the GER fit directly — they drove which cages became cohorts A/B/C. Keep this section in sync with the procedure.

### 2.1 Canonical Bilbul scope: 96 cages

| Hierarchy level | Value |
|---|---|
| Operation | `OperationCode='JU'` (Juvenile) |
| Region    | `RegionCode='JR'` (Juvenile region) |
| **Area**  | `AreaId=3`, `AreaCode='BIL'`, `AreaName='Bilbul'` |
| Sites (Ponds) | `B01`–`B12` (SiteIds 5–16) |
| Units (Cages) | `UnitName` `01`–`08` per pond, UnitIds **803–898** (contiguous) |

Every Bilbul row has `StructureType == 'cage_in_pond'` and `HasCycleHistory == True`. The published `cycle_ledger/units.parquet` is pre-curated — `AreaCode == 'BIL'` yields exactly 96 production cages.

```python
import pandas as pd
units = pd.read_parquet("/mnt/data/mercatus/cycle_ledger/units.parquet")
scope = units[units["AreaCode"] == "BIL"].copy()
assert len(scope) == 96, "Bilbul scope must be 12 ponds × 8 cages"
```

Friendly labels for display: `UnitFriendlyName` (`"Bilbul B01 Cage 01"`), `SiteFriendlyName` (`"Bilbul B01"`). All business dates in the ledger are **Sydney local time** (`Australia/Sydney`). The pipeline atomically swaps `cycle_ledger/` at the end of each nightly run, so reads are always consistent.

### 2.2 Temperature — per pond, daily

**Source:** `/mnt/data/mercatus/cycle_ledger/cycle_days.parquet`
**Grain:** one row per `(CycleId, UnitId, LocalDate)`.

| Column | Meaning |
|---|---|
| `Temperature` | Pond water °C for that day. Within a pond, every cage shows the same value (broadcast). |
| `TemperatureSmoothed` | Rolling-smoothed version of `Temperature`; preferred for growth modelling. |

For Bilbul scope (audited 2026-05-08): 107,735 rows, 106,988 with non-null `Temperature`, all 12 ponds covered, current through 2026-05-07.

```python
import pandas as pd

UNITS_PARQUET = "/mnt/data/mercatus/cycle_ledger/units.parquet"
DAYS_PARQUET  = "/mnt/data/mercatus/cycle_ledger/cycle_days.parquet"

def load_pond_temperature() -> pd.DataFrame:
    units = pd.read_parquet(UNITS_PARQUET, columns=["UnitId","SiteCode","SiteFriendlyName"])
    bil   = units[units["UnitId"].between(803, 898)]
    days = pd.read_parquet(DAYS_PARQUET,
        columns=["UnitId","LocalDate","Temperature","TemperatureSmoothed"])
    df = days[days["UnitId"].isin(bil["UnitId"])].dropna(subset=["Temperature"])
    # Collapse cage-level to pond-level (Temperature is constant within a pond/day).
    pond = (df.merge(bil, on="UnitId")
              .groupby(["LocalDate","SiteCode"], as_index=False)
              .agg(Temperature=("Temperature","first"),
                   TemperatureSmoothed=("TemperatureSmoothed","first")))
    return pond.sort_values(["SiteCode","LocalDate"]).reset_index(drop=True)
```

For cage-grain joins (e.g. against feed or treatments), keep the `UnitId` column instead of collapsing.

### 2.3 Oxygen (`OM5`) — per pond, daily

Oxygen is **not** in the curated parquets. It lives in the raw OData environment export at the **cluster level**, where one Mercatus cluster corresponds to one Bilbul pond (cluster name `"B0x All Units"`).

**Source:** `/mnt/data/mercatus/raw/odata_exports/vReportingBaselineEnvironment.csv`

Each row has a `Level` (`Cluster` / `Pen`) and an `ObjectId`. **`ObjectId` is the entity identifier** — `LevelID` is just a code for the level *type* (that was the gotcha that originally made it look like only one pond was logged).

For Bilbul: `Level == "Cluster"`, `ObjectId ∈ Bilbul ClusterIds` → one daily series per pond. `Level == "Pen"` rows are only 8 total for Bilbul — ignore.

Bilbul pond → ClusterId mapping (from `vReportingBaselineUnits.csv`, column `ClusterId`, `ClusterName = "B0x All Units"`):

| Pond | ClusterId  |   | Pond | ClusterId  |
|---|---:|---|---|---:|
| B01 |  5,000,000 | | B07 | 11,000,000 |
| B02 |  6,000,000 | | B08 | 12,000,000 |
| B03 |  7,000,000 | | B09 | 13,000,000 |
| B04 |  8,000,000 | | B10 | 14,000,000 |
| B05 |  9,000,000 | | B11 | 15,000,000 |
| B06 | 10,000,000 | | B12 | 16,000,000 |

Coverage (audited 2026-05-08):
- **Parameter:** `OM5` only — dissolved oxygen, mg/L.
- **Span:** 2024-05-03 → 2026-05-07 (~2 years; **no Bilbul oxygen exists before May 2024**).
- **Cadence:** one reading per pond per day; 705–731 days per pond out of 735 possible (96–99 % daily fill).
- **Sanity bound:** filter to `[0, 25]` mg/L. Raw export contains data-entry outliers up to 7387.

```python
import pandas as pd

ENV_CSV = "/mnt/data/mercatus/raw/odata_exports/vReportingBaselineEnvironment.csv"
BIL_POND_CLUSTER = {
    "B01":  5_000_000, "B02":  6_000_000, "B03":  7_000_000, "B04":  8_000_000,
    "B05":  9_000_000, "B06": 10_000_000, "B07": 11_000_000, "B08": 12_000_000,
    "B09": 13_000_000, "B10": 14_000_000, "B11": 15_000_000, "B12": 16_000_000,
}
CLUSTER_TO_POND = {v: k for k, v in BIL_POND_CLUSTER.items()}

def load_pond_oxygen() -> pd.DataFrame:
    df = pd.read_csv(ENV_CSV, low_memory=False, parse_dates=["Date"])
    df = df[(df["EnvironmentParamCode"] == "OM5")
          & (df["Level"] == "Cluster")
          & df["ObjectId"].isin(CLUSTER_TO_POND)
          & df["EnvironmentParamValue"].between(0, 25)].copy()
    df["Pond"]      = df["ObjectId"].map(CLUSTER_TO_POND)
    df["LocalDate"] = df["Date"].dt.tz_convert("Australia/Sydney").dt.normalize()
    return (df.rename(columns={"EnvironmentParamValue": "O2_mgL"})
              [["LocalDate", "Pond", "O2_mgL"]]
              .sort_values(["Pond", "LocalDate"])
              .reset_index(drop=True))
```

### 2.4 Treatments — per cage dosing events

**Source:** `/mnt/data/mercatus/raw/odata_exports/vReportingBaselineTreatment.csv` (cage-grain — *not* curated into `cycle_ledger/`).

In-scope rows (Bilbul 96 cages, audited 2026-05-08): 22,467 from 2022-07-18 to 2026-05-07.

Products in active use (2024–2026):

| Product | 2024 | 2025 | 2026 (YTD) |
|---|---:|---:|---:|
| Copper sulphate            | 1,122 | 1,225 | 302 |
| Epizym PST                 |   222 |   274 | 108 |
| Brown Sugar                |   224 |   271 | 105 |
| Formalin                   |   439 |   234 |  66 |
| Strike                     |   125 |    21 |  39 |
| calcium chloride           |    96 |    30 |  27 |
| Sodium Percarbonate Powder |    44 |     7 |  12 |

Long-tail (occasionally used): Potassium Permanganate, Molasses, A.F.S Trimsul, Sodium Percarbonate Tablet. Drop the `water` product (15 rows — recording artifact). Discontinued (do not include in active specs): Pro-W (2024-only), Epizym BGM (last 2025 trace), Dolomite (one-off 2022).

Useful columns: `UnitID, StartDate, EndDate, TreatmentProduct[ID], TreatmentMethod, Amount, Prescription, ActiveSubstance, O2Start/O210Min/O220Min/O230Min/O240Min` (per-cage O2 around the dose — the only per-cage O2 data), `Batch` (93% fill), `Reason` (34% fill — free text). Ignore for freshwater ponds: `IsNetRaised, IsBottomRaised, TarpaulineType, Veterinary, SuggestedDosis, TransportName, Operator, PrescriptionDate, ExpiryDate`.

```python
import pandas as pd

TREATMENT_CSV = "/mnt/data/mercatus/raw/odata_exports/vReportingBaselineTreatment.csv"

KEEP_COLS = [
    "UnitID", "StartDate", "EndDate",
    "TreatmentProductID", "TreatmentProduct", "ActiveSubstance",
    "TreatmentMethod", "Amount", "Prescription", "Batch", "Reason",
    "O2Start", "O210Min", "O220Min", "O230Min", "O240Min",
]

def load_treatments(scope_unit_ids: set[int]) -> pd.DataFrame:
    df = pd.read_csv(TREATMENT_CSV, low_memory=False,
                     parse_dates=["StartDate", "EndDate"], usecols=KEEP_COLS)
    df = df[df["UnitID"].isin(scope_unit_ids)
          & (df["TreatmentProduct"] != "water")].copy()
    df["StartDate"] = df["StartDate"].dt.tz_convert("Australia/Sydney")
    df["EndDate"]   = df["EndDate"].dt.tz_convert("Australia/Sydney")
    return df.sort_values(["UnitID", "StartDate"]).reset_index(drop=True)
```

### 2.5 Feeding — per cage per day

**Source (preferred):** `/mnt/data/mercatus/cycle_ledger/cycle_feedings.parquet` — curated, already attributed to cycles. UnitId grain.

In-scope rows (Bilbul 96 cages, audited 2026-05-08): 111,829 from 2022-07-01 to 2026-05-07. Total ~784 t fed across the scope.

Columns: `CycleId, FeedingID, UnitId, LocalDate, ProductID, FeedID, FeedName, FeedTypeName, FeedAmount` (kg).

For a daily-aggregated view (one row per UnitId × LocalDate), use `cycle_ledger/cycle_days.parquet` columns `DailyFeedKg` and `DailyFeedKgSmoothed`. Feed dimension (supplier, type, size, energy, medicated flag) is in `raw/odata_exports/vReportingBaselineFeed.csv`.

**Sinking-vs-floating bias.** Cages with fish **below ~50 g** are fed **sinking** feed (non-trivial pellet waste); above 50 g, floating feed (waste minimal). Implication: `actual / expected` SFR ratio is inflated for sub-50 g cages. The cage-selection procedure uses a wider acceptance band (`0.85–1.40` instead of `0.85–1.20`) and a higher SFR target (`1.10` instead of `1.05`) for sub-50 g cages. Above 50 g, no adjustment.

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
| `Data/Bilbul <date>.xlsx` | tracked (and **synced to SharePoint**) | Canonical trial data. Small. |
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

- `Proposal/Bilbul_GER_trial_proposal.md` — trial design, recording schema.
- Original local `~/PycharmProjects/FeedingFrequency/Juvenile/CLAUDE.md` (now retired) — source for §2 Mercatus streams.
- `Data/Bilbul 12-05-2026.xlsx` — first trial-date file; shape audit anchored here.
