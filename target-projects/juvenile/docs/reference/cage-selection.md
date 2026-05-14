# Cage selection for GER cohorts

How the three cohort cages (one per size bracket) were selected from the 96 Bilbul grow-out cages. The procedure was developed before this project formalised and is reused here — it is the operational realisation of the proposal's *"one cage per group, selected for stable feeding behaviour and clean recent history"*.

For per-term definitions see [`../../glossary.md`](../../glossary.md). For the data streams this procedure consumes see [`../domain/data-shape.md`](../domain/data-shape.md) §2.

---

## Purpose

Pick one cage per size bracket that is "normally performing": fish are eating, water is fine, and they are not in active treatment.

## Inputs

| Knob | Default | Notes |
|---|---|---|
| `as_of` | today (`Australia/Sydney`) | Reference date for the lookback window. |
| `window_days` | 14 | Length of the lookback window. |
| `brackets` | `[(10, 45), (45, 80), (80, 150)]` g | One cage per bracket (the three cohorts). |
| `exclude_products` | `{"Formalin", "Copper sulphate"}` | Any dose anywhere in the window disqualifies the cage. |
| `o2_mean_min` | 6.0 mg/L | Window-mean threshold on the parent pond's `OM5`. |
| `o2_min_min` | 4.0 mg/L | Window-minimum threshold (no severe drops). |
| `min_feed_days` | 10 of `window_days` | Reject cages with sparse feed records. |
| `sfr_band(weight)` | `(0.85, 1.40)` if `w < 50 g` else `(0.85, 1.20)` | Wider band for sinking-feed bias on sub-50 g cages. |
| `sfr_target(weight)` | `1.10` if `w < 50 g` else `1.05` | What "slightly above average" means for ranking. |

## Filter order

1. **Weight source.** Use the latest **Mercatus sample weight** per cage from `cycle_sample_weights.parquet` (drop `IsOutlier == True`). Require the sample date within `window_days`. *Do not* use `SimulatedWeight` from `cycle_days.parquet` — model fits can drift from sampling reality.
2. **Bracket.** Filter on `bracket_lo ≤ SampleWeightG < bracket_hi`.
3. **No recent treatment.** Drop cages with any `TreatmentProduct ∈ exclude_products` in `[as_of − window_days, as_of]` from `vReportingBaselineTreatment.csv`.
4. **Pond O2 ok.** Compute pond `OM5` mean and min over the window (per [`../domain/data-shape.md`](../domain/data-shape.md) §2.3). Drop cages whose parent pond fails `o2_mean ≥ o2_mean_min` AND `o2_min ≥ o2_min_min`.
5. **Enough feed data.** From `cycle_days.parquet`, keep cages with ≥ `min_feed_days` days of non-null `DailyFeedKg` in the window.
6. **SFR ratio in band.** Compute per cage:
   - `expected_kg = Σ_t FishCount_t · SampleWeightG / 1000 · sfr(SampleWeightG, Temperature_t) / 100`. (Weight held at the latest Mercatus sample — minor under-estimate of expected feed for fast-growing fish.)
   - `actual_kg = Σ_t DailyFeedKg_t`.
   - `SFR_ratio = actual_kg / expected_kg`.
   - Keep cages with `SFR_ratio ∈ sfr_band(weight)`.
7. **Rank** within each bracket by `|SFR_ratio − sfr_target(weight)|` — pick the smallest. Ties → bigger biomass wins (more statistical power).

## Reference implementation

```python
import pandas as pd, numpy as np
from growth_models import sfr

UNITS    = "/mnt/data/mercatus/cycle_ledger/units.parquet"
DAYS     = "/mnt/data/mercatus/cycle_ledger/cycle_days.parquet"
SAMPLES  = "/mnt/data/mercatus/cycle_ledger/cycle_sample_weights.parquet"
TREATS   = "/mnt/data/mercatus/raw/odata_exports/vReportingBaselineTreatment.csv"
ENV      = "/mnt/data/mercatus/raw/odata_exports/vReportingBaselineEnvironment.csv"

CLU2POND = {5_000_000 + i*1_000_000: f"B{i+1:02d}" for i in range(12)}

def select_trial_cages(
    brackets=((10,45),(45,80),(80,150)),
    as_of: pd.Timestamp = pd.Timestamp.today().normalize(),
    window_days: int = 14,
    exclude_products=frozenset({"Formalin","Copper sulphate"}),
    o2_mean_min: float = 6.0,
    o2_min_min:  float = 4.0,
    min_feed_days: int = 10,
) -> dict[tuple[int,int], pd.DataFrame]:
    win_start = as_of - pd.Timedelta(days=window_days-1)

    # --- Bilbul scope ---
    units = pd.read_parquet(UNITS)
    bil = units[units["AreaCode"] == "BIL"][["UnitId","SiteCode","UnitFriendlyName"]]
    BIL = set(bil["UnitId"])

    # --- Latest Mercatus sample (non-outlier, within window) ---
    sw = pd.read_parquet(SAMPLES)
    sw = sw[sw["UnitId"].isin(BIL) & ~sw["IsOutlier"].fillna(False)].copy()
    sw["LocalDate"] = pd.to_datetime(sw["LocalDate"])
    samp = (sw.sort_values("LocalDate").groupby("UnitId").tail(1)
              [["UnitId","LocalDate","AvgWeightG","Source"]]
              .rename(columns={"LocalDate":"SampleDate","AvgWeightG":"SampleWeightG"}))
    samp = samp[samp["SampleDate"] >= win_start]

    # --- Daily ledger over the window ---
    cd = pd.read_parquet(DAYS, columns=["UnitId","LocalDate","UnitCloseCount",
                                        "Temperature","DailyFeedKg"])
    cd = cd[cd["UnitId"].isin(BIL)].copy()
    cd["LocalDate"] = pd.to_datetime(cd["LocalDate"])
    win = cd[(cd["LocalDate"] >= win_start) & (cd["LocalDate"] <= as_of)
           & cd["UnitCloseCount"].notna() & cd["Temperature"].notna()
           & (cd["UnitCloseCount"] > 0)].merge(samp[["UnitId","SampleWeightG"]], on="UnitId")
    win["SFR_pct"]    = sfr(win["SampleWeightG"].to_numpy(), win["Temperature"].to_numpy())
    win["ExpectedKg"] = (win["UnitCloseCount"] * win["SampleWeightG"] / 1000.0
                         * win["SFR_pct"] / 100.0)
    agg = (win.groupby("UnitId")
              .agg(days=("LocalDate","nunique"),
                   feed_actual_kg=("DailyFeedKg","sum"),
                   feed_expected_kg=("ExpectedKg","sum"),
                   temp_mean=("Temperature","mean"))
              .reset_index())
    agg["SFR_ratio"] = agg["feed_actual_kg"] / agg["feed_expected_kg"]

    # --- Treatments to exclude ---
    tr = pd.read_csv(TREATS, low_memory=False, parse_dates=["StartDate"])
    tr["StartDate"] = tr["StartDate"].dt.tz_localize(None)
    treated = set(tr[(tr["UnitID"].isin(BIL))
                  & (tr["StartDate"] >= win_start)
                  & (tr["TreatmentProduct"].isin(exclude_products))]["UnitID"])

    # --- Pond O2 over the window ---
    env = pd.read_csv(ENV, low_memory=False, parse_dates=["Date"])
    o2 = env[(env["EnvironmentParamCode"] == "OM5") & (env["Level"] == "Cluster")
           & env["ObjectId"].isin(CLU2POND)
           & env["EnvironmentParamValue"].between(0, 25)].copy()
    o2["Pond"] = o2["ObjectId"].map(CLU2POND)
    o2["Date"] = o2["Date"].dt.tz_localize(None)
    o2_summary = (o2[o2["Date"] >= win_start].groupby("Pond")["EnvironmentParamValue"]
                  .agg(o2_mean="mean", o2_min="min").reset_index())

    # --- Latest fish count per cage ---
    cnt = (cd.dropna(subset=["UnitCloseCount"]).query("UnitCloseCount > 0")
             .sort_values("LocalDate").groupby("UnitId").tail(1)
             [["UnitId","UnitCloseCount"]].rename(columns={"UnitCloseCount":"FishCount"}))

    # --- Assemble + filter ---
    df = (samp.merge(agg, on="UnitId")
              .merge(bil, on="UnitId")
              .merge(cnt, on="UnitId", how="left")
              .merge(o2_summary, left_on="SiteCode", right_on="Pond", how="left"))
    df["BiomassKg"] = df["SampleWeightG"] * df["FishCount"] / 1000.0

    def band(w):    return (0.85, 1.40) if w < 50 else (0.85, 1.20)
    def target(w):  return 1.10 if w < 50 else 1.05

    rows = df.to_dict("records")
    for r in rows:
        lo, hi = band(r["SampleWeightG"])
        r["Eligible"] = (
            r["UnitId"] not in treated
            and r["o2_mean"] >= o2_mean_min and r["o2_min"] >= o2_min_min
            and r["days"] >= min_feed_days
            and lo <= r["SFR_ratio"] <= hi
        )
        r["score"] = abs(r["SFR_ratio"] - target(r["SampleWeightG"]))
    df = pd.DataFrame(rows)

    out = {}
    for lo, hi in brackets:
        sub = df[df["Eligible"] & df["SampleWeightG"].between(lo, hi)]
        out[(lo, hi)] = sub.sort_values(["score", "BiomassKg"],
                                        ascending=[True, False]).head(5)
    return out
```

## Notes

- The procedure picks **per bracket independently** — there is no constraint that the three picks come from different ponds. If pond independence matters for a trial design, add it as a post-step (drop duplicates on `SiteCode` greedily by `score`).
- For longer-window selection (e.g. 30 days), "weight held at sample" becomes a worse approximation. If needed, model within-window growth via `growth_models.sgr` and integrate, or fall back to `cycle_days.SimulatedWeight` for the SFR computation while still bracket-filtering on the Mercatus sample.
- **Output is a shortlist, not a single pick.** Domain judgment selects the final cage from the top 5 — e.g. preferring larger biomass, mid-bracket weight, or pond pairings that suit operations.

## Provenance

- Original local `~/PycharmProjects/FeedingFrequency/Juvenile/CLAUDE.md` §5 (now retired) — the verbatim source of this procedure.
- `Proposal/Bilbul_GER_trial_proposal.md` §Cohorts — the trial's bracket definitions.
- `Data/Bilbul 12-05-2026.xlsx` — first trial-date file; the cohort C cage (Pond 8 Cage 1) was picked using this procedure.
