# Future work — water-quality-feed

Known follow-ups not in scope for v1. Pre-decision items live here; once a decision is made and ticketed, the entry moves to `.tickets/` and is deleted from this file.

## Canonical Mercatus unit mapping stage

**What.** A new pipeline stage that translates WQ-native identifiers in `readings.parquet` to canonical Mercatus UnitIds. Two paths (see [docs/domain/unit-mapping-puzzle.md](../domain/unit-mapping-puzzle.md)):

1. **Pattern 1 (pond-as-unit farms)**: 1:1 `WQUnitId → MercatusUnitId` lookup.
2. **Pattern 2 (cages-in-pond farms)**: site-level reading fans out to all Mercatus child units under that site, using MDF's `units.parquet` hierarchy.

**Why deferred.** Non-trivial mapping logic. Needs an investigation pass first to:
- Classify each farm as Pattern 1 or Pattern 2.
- Choose the mapping registry for Pattern 1 (extend `WQ_Units` SP list with a `MercatusUnitId` column, or maintain a separate mapping file, or fuzzy-match on names).
- Confirm MDF's `units.parquet` exposes the parent-pond relationship needed for Pattern 2 fan-out.
- Define quarantine policy for rows that match neither pattern.

**Contract impact when shipped.** Adds a `MercatusUnitId` column (or replaces `WQUnitId` entirely) on `readings.parquet`. Adds a `<published>/quarantine/unmapped_readings.parquet` for the fail set. Documented as a contract change in `<published>/README.md`.

**v1 stance.** Ship the mirror with WQ-native identifiers only, columns prefixed `WQ` so consumers cannot accidentally join on the wrong key. No `MercatusUnitId` column exists in v1.
