**Status:** done
**Category:** enhancement
**Type:** AFK

## Parent

[../PRD.md](../PRD.md). Implements [ADR-0019](../../../docs/adr/0019-pipeline-areas-table-canonical-in-claude-md.md).

## What to build

Make the "Pipeline areas" table in `templates/pipeline/CLAUDE.md` the canonical source for "what stages exist", with `docs/reference/<stage>.md` as per-stage detail that links back to the table.

Specifically:

1. In `templates/pipeline/CLAUDE.md`, immediately above the Pipeline-areas table, add a one-line note:
   > *Canonical list of stages. If you change this table, run `/finish` — it cross-checks against `docs/reference/`.*
2. In `templates/pipeline/docs/reference/README.md`, update the "Pipeline-style: typically one doc per stage..." paragraph to clarify that per-stage docs are *detail* and link back to CLAUDE.md's Pipeline-areas table for the canonical list. Add a note that *Orchestration* lives only in CLAUDE.md (no per-stage doc) since it's not a stage with its own code dir.
3. In `skills/finish/SKILL.md` step 4 (Verify CLAUDE.md is still accurate), add a sub-bullet for pipeline projects: "If a Pipeline-areas table is present in CLAUDE.md, verify each stage in the table has a corresponding `docs/reference/<stage>.md` (except Orchestration), and verify each `docs/reference/<stage>.md` corresponds to a row in the table. Surface mismatches."
4. Verify the change is template-only (not warehouse-cwd) — the warehouse itself isn't a pipeline.

## Acceptance criteria

- [x] `templates/pipeline/CLAUDE.md` has the canonical-source note above the Pipeline-areas table.
- [x] `templates/pipeline/docs/reference/README.md` clarifies the back-link relationship.
- [x] `skills/finish/SKILL.md` step 4 cross-checks the table against `docs/reference/` for pipeline projects.
- [x] No edits to non-pipeline templates.

## Blocked by

None — can start immediately.

## Comments

(empty)
