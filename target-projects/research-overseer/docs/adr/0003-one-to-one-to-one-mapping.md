# ADR-0003 — One register row = one per-project repo = one `entry.yaml`

**Status**: Accepted (intake 2026-05-21)

## Context

The existing data shows mixed precedent: "Chlorella and PSB ST1" and "ST2" are two register rows (sequential trials, each a distinct project); "Feeding frequency" is one register row but `target-projects/` has two intakes (`feeding-frequency-2023` and `feeding-frequency-juvenile`); "Gut evacuation" is one register row but there are two intakes (`gutevac` and `stanbridge-gutevac`).

The overseer needs a clear cardinality model to know how to map intent across surfaces.

## Decision

**1:1:1 mapping**: one register row corresponds to exactly one per-project repo under `~/ResearchProjects/<Project Name>/`, which contains exactly one `.register/entry.yaml`. If a research theme has multiple discrete trials (different farms, different scopes, different campaigns), each gets its own register row + repo + `entry.yaml`.

When the overseer's sweep detects a violation (e.g. two `entry.yaml.id` values pointing at the same `register.Slug`, or one slug in the register with no `entry.yaml` and a sibling repo with a draft slug nearby), it flags the clash and asks the human to either:
- Merge into one project (delete one of the repos, consolidate work).
- Split into two register rows (create a new slug for the second repo).

## Consequences

**Positive:**
- Clear mental model: each project is a row, a folder, a file.
- The drift report becomes useful: orphans on either side are real, not artifacts of an ambiguous data model.
- New trials of an old theme get proper accountability instead of being subsumed into a generic row.

**Negative:**
- Some current intakes need to be retconned at first sweep: `gutevac`/`stanbridge-gutevac` and `feeding-frequency-2023`/`feeding-frequency-juvenile`. Each pair gets either merged or split, with human input.
- Some operational decisions (e.g. is "Gut evacuation" one trial spanning Bilbul + Stanbridge or two trials?) become explicit instead of implicit.

## Alternatives considered

- **One row, multiple repos** (parent-child). Rejected: register schema doesn't model it, and the manager UX would be confusing ("which Status is the row showing if there are three sub-trials?").
- **One repo, multiple rows.** Rejected: the per-project agent can only write one `entry.yaml`, so this would break the canonical model from ADR-0001.

## Related

- [[0001-entry-yaml-canonical]]
- [[0002-slug-column-for-stable-identity]]
- [[register-shape]]
