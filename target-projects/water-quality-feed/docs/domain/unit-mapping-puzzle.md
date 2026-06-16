# Unit mapping puzzle: WQ → canonical Mercatus

## Two farm patterns in WQ_Readings

WQ readings are stored at different grains depending on farm structure:

**Pattern 1 — pond-as-unit.** Some farms have a flat hierarchy: `Farm = Site`, `Pond = Unit`. One WQ reading corresponds 1:1 to one production unit. `WQ_Readings.UnitId` is populated. `WQ_Sites.IsSiteLevelReading = false`.

**Pattern 2 — cages-in-pond.** Other farms have a deeper hierarchy: `Farm → Area → Site (pond) → Unit (cage)`. Multiple cages share a pond. Water quality is a property of the pond, not the cage — so one reading is taken at the pond (site) level. `WQ_Readings.UnitId` is NA. `WQ_Sites.IsSiteLevelReading = true`.

## Implication for canonical mapping

A naive 1:1 `WQUnitId → MercatusUnitId` dict doesn't cover Pattern 2. A site-level WQ reading must **fan out** to every Mercatus child unit (cage) under that site. The fan-out requires MDF's unit hierarchy (`/mnt/data/mercatus/cycle_ledger/units.parquet`, which carries the StructureType taxonomy and parent relationships).

So canonical mapping is not a dim join — it's its own stage with two logical paths:

1. **Pattern 1 readings**: `WQUnitId → MercatusUnitId` 1:1 lookup (probably from an extension of `WQ_Units` with a `MercatusUnitId` column).
2. **Pattern 2 readings**: `(WQFarm, WQSite) → set of MercatusUnitIds` via MDF's hierarchy, then row-multiply.

## Status

**Deferred to a future stage.** v1 of the pipeline ships the mirror with WQ-native identifiers only (columns prefixed `WQ` to make it loud that they are not canonical) — see [future-work entry](../planning/future-work.md). Downstream consumers must not join WQ readings on Mercatus UnitId until the canonical-mapping stage ships.

## Investigation needed before the stage can be built

- For each farm in `WQ_Farms`, classify as Pattern 1 or Pattern 2.
- For Pattern 1 farms: confirm the source of `MercatusUnitId` (extend `WQ_Units` SP list? separate file? lookup by name?).
- For Pattern 2 farms: confirm MDF's `units.parquet` carries the parent-pond relationship needed to fan a site → its cages. If not, surface back to MDF.
- Confirm WQ row volume per pattern (so we know which path is the bulk of the work).
- Define a quarantine policy for readings that match neither pattern (unknown farm, missing site, etc.).
