# Glossary — water-quality-feed

Project-specific vocabulary. Canonical term first, then "Avoid" synonyms, one-sentence definition, relationships, and example dialogue where ambiguity is plausible.

## Reading

- **Avoid:** "observation", "measurement", "sample" (the last collides with MDF's `sample_weights`).
- One row of the `WQ_Readings` SharePoint list: a single timestamped multi-parameter observation entered by an operator via the WQ_WaterQuality_sp PowerApp.
- Carries up to 14 parameter columns (pH, TAN, Nitrite, Chloride, Alkalinity, CaHardness, FreeCopper1, FreeCopper2, TurbidityNTU, Nitrate, Phosphorus, GHardness, Temperature, Salinity) plus `Notes`.
- Keyed by `(WQUnitId, ReadingDateTime)` for unit-level readings or `(WQSite, ReadingDateTime)` for [site-level readings](#site-level-reading).

## WQ-native identifier

- The set of columns `WQFarm`, `WQSite`, `WQUnit`, `WQUnitId` in the published parquets.
- IDs that originate in the `WQ_Units` SharePoint list. **Not** Mercatus-canonical — they correspond to Mercatus units only after the canonical-mapping stage runs (see [ADR-0003](docs/adr/0003-v1-wq-native-identifiers-no-canonical-mapping.md)).
- The `WQ` prefix is deliberate: downstream code that joins on a Mercatus key cannot do so accidentally because the column names don't match.

## Site-level reading

- A reading where `WQ_Readings.UnitId` is NA and `WQ_Sites.IsSiteLevelReading = true`.
- Represents a water-quality measurement taken at pond (site) grain on a farm where multiple cages share a pond. Canonically applies to *every* Mercatus child unit (cage) under that site.
- The fan-out from site-level reading to per-cage rows is the deferred [canonical-mapping stage](docs/planning/future-work.md). v1 ships the row at site grain only.

## WQ Reader Proxy

- The HTTP-triggered Power Automate flow at `~/MicrosoftFlowsApps/flows/WQ_Reader_Proxy/`.
- The pipeline's single entry point to SharePoint — direct SP connections are intentionally not used. Inputs: `op` (`items` or `lists`), `list` (GUID or display name), `filter` (OData), `top`, `orderby`, `view`. Returns JSON.
- Auth: SAS-signed URL stored as `WQ_PROXY_FLOW_URL` in `.env`.

## Canonical-mapping stage

- The deferred pipeline stage that will translate WQ-native identifiers in `readings.parquet` to Mercatus UnitIds.
- Adds a `MercatusUnitId` column and, for [site-level readings](#site-level-reading), produces fan-out rows (one per Mercatus child unit). See [docs/planning/future-work.md](docs/planning/future-work.md) and [docs/domain/unit-mapping-puzzle.md](docs/domain/unit-mapping-puzzle.md).
- Not in v1.

## Pattern 1 / Pattern 2

- Shorthand for the two farm structures the canonical-mapping stage has to handle.
- **Pattern 1 — pond-as-unit.** `Farm = Site`, `Pond = Unit`. `WQUnitId` populated. 1:1 to Mercatus.
- **Pattern 2 — cages-in-pond.** `Farm → Area → Site (pond) → Unit (cage)`. `WQUnitId` NA, site-level reading. 1:N to Mercatus child cages.
- Defined in full in [docs/domain/unit-mapping-puzzle.md](docs/domain/unit-mapping-puzzle.md).

## Mirror

- The act this pipeline performs in v1: pull the six WQ SharePoint lists via the WQ Reader Proxy and write them as parquets under `/mnt/data/water_quality/`. No QA, no aggregation, no joining — just a faithful, timestamped, typed snapshot of the SP state.
