# Intake notes — water-quality-feed

Raw notes from the intake conversation. Captures user phrasing and unresolved threads.

## Anchor

Cold-start standalone pipeline. Mirrors MDF's shape (systemd timer, `/mnt/data/` publish root, MDF-compatible parquet conventions for downstream joins).

## Known upstream sources

- **Power Automate flow**: `~/MicrosoftFlowsApps/flows/WQ_Reader_Proxy`. HTTP-triggered. Inputs: `op` (`items` or `lists`), `list` (GUID or display name), `filter`, `top`, `orderby`, `view`. Hits SharePoint site `https://murraycod.sharepoint.com/sites/WaterQuality` via the shared SPO connector.
- **PowerApp**: `~/MicrosoftFlowsApps/apps/WQ_WaterQuality_sp` writes the data the flow reads.

## Sibling-project conventions to inherit (from MDF)

- Published root convention: `/mnt/data/<project>/` with atomic publish from `<published>/.staging/`.
- Sydney TZ, `_syd` column suffix after cleaning.
- Parquet outputs keyed by `(UnitId, LocalDate)` for join compatibility.
- CSV reads: `dtype=str`, `low_memory=False`.
- Fail-fast invariants.
- Shared venv pattern (MDF hosts `.venv` for 4 projects).

## Resolved decisions

- **Template**: `pipeline` (cold-start from `templates/pipeline/`). Inferred — not asked.
- **Pipeline scope (Q1)**: thin mirror with one mandatory normalisation. Fetch from `WQ_Reader_Proxy` → translate WQ UnitId → canonical Mercatus UnitId → Sydney TZ → write parquet keyed by `(MercatusUnitId, ReadingDateTime)` plus dimension parquets. No QA, no aggregation, no cycle joining. Aggregation/QA layered on later as new stages once downstream demand is concrete.
- **Fetch strategy (Q2)**: full refresh every run. Atomic-publish all parquets together to `<published>/.staging/` → rename. SP-side edits, deletes, back-dated entries auto-handled. Switch to incremental only if list growth makes full-pull painful.
- **Lists to mirror (Q3)**: all 6 non-AI lists — `WQ_Readings`, `WQ_Units`, `WQ_Sites`, `WQ_Farms`, `WQ_ParameterRanges`, `WQ_Flags`. Skip `WQ_AI_Config`, `WQ_AI_Requests`.
- **Publish root + atomicity (Q4)**: `/mnt/data/water_quality/` (env override `WQ_DATA_ROOT`). Atomic publish via `<published>/.staging/` → rename, same pattern as MDF's cycle_ledger.
- **UnitId rule (added Q4, refined Q5)**: canonical Mercatus normalisation is a separate, future stage — not in v1. v1 ships the mirror with WQ-native identifiers ONLY, columns prefixed `WQ` (`WQFarm`, `WQSite`, `WQUnit`, `WQUnitId`) so downstream cannot accidentally join on Mercatus keys. See [docs/domain/unit-mapping-puzzle.md](../docs/domain/unit-mapping-puzzle.md) and [docs/planning/future-work.md](../docs/planning/future-work.md).
- **Two farm patterns surfaced in Q5** (drives the deferred mapping stage):
  - Pattern 1 — pond-as-unit. `Farm = Site`, `Pond = Unit`. `WQ_Readings.UnitId` populated, 1:1 maps to a Mercatus unit.
  - Pattern 2 — cages-in-pond. `Farm → Area → Site (pond) → Unit (cage)`. Multiple cages share a pond; WQ reads are taken at site (pond) level. `WQ_Readings.UnitId` is NA, `WQ_Sites.IsSiteLevelReading = true`. Site-level reading must fan out to all child cages under that pond, using MDF's `units.parquet` hierarchy.
- **Cadence (Q6)**: daily 03:00 Sydney. `RandomizedDelaySec=300`, `Persistent=true`. One hour ahead of MDF (04:00) so a future canonical-mapping stage could consume MDF's morning publish in-run if/when coupling is wanted.
- **Python env (Q7, REVISED)**: share MDF's `.venv/` at `/home/rndmanager/PycharmProjects/MercatusDataFeed/.venv/`. WaterQualityFeed becomes a 5th tenant of MDF's shared venv (alongside MDF, GrowthModels, PowerBI, FishGrowthFittingSGRpackage). Knock-on impacts:
  - No `.venv/` inside the WaterQualityFeed repo (gitignored and absent).
  - WaterQualityFeed has a `pyproject.toml` declaring deps by **bare name only** (no version pins — inherits MDF's no-pins rule, which the user-memory notes explain is to surface staleness loudly across the multi-repo setup).
  - Installation: `pip install -e ~/PycharmProjects/WaterQualityFeed` into MDF's venv. Editable, like the other siblings.
  - Three-namespace match enforced: `WaterQualityFeed` (repo) → `water_quality_feed` (Python import) → `water-quality-feed` (pip distribution). Staging dir name already matches the distribution form.
  - systemd `ExecStart`: `/home/rndmanager/PycharmProjects/MercatusDataFeed/.venv/bin/python /home/rndmanager/PycharmProjects/WaterQualityFeed/run_pipeline.py`. No `ExecStartPre` needed for v1 (WQ has no fish_growth_model-style volatile git dep).
- **Repo + name (Q9)**: `~/PycharmProjects/WaterQualityFeed/`, git remote `https://github.com/prudgin/WaterQualityFeed.git`, main branch `master` (matches MDF).

## Discovered schema (WQ_Readings SP list — wide observation rows)

Columns from `~/MicrosoftFlowsApps/apps/WQ_WaterQuality_sp/src/DataSources/WQ_Readings.json`:

- Identifiers: `Farm`, `Site`, `Unit`, `UnitId`, `EnteredByInitials`
- Time: `ReadingDate`, `ReadingTime`, `ReadingDateTime`
- Parameters: `pH`, `TAN`, `Nitrite`, `Chloride`, `Alkalinity`, `CaHardness`, `FreeCopper1`, `FreeCopper2`, `TurbidityNTU`, `Nitrate`, `Phosphorus`, `GHardness`, `Temperature`, `Salinity`
- Annotation: `Notes`
- SP system: `ID`, `Created`, `Modified`, `Author`, `Editor`

Related dimension lists in the same SharePoint site: `WQ_Farms`, `WQ_Sites`, `WQ_Units`, `WQ_Flags`, `WQ_ParameterRanges`. Out of scope (probably): `WQ_AI_Config`, `WQ_AI_Requests`.

## Open threads

(to fill as the walk proceeds)
