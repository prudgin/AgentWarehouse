**Status:** done
**Category:** enhancement

## What to build

Update `skills/finish/SKILL.md` step 2 (orphan sweep) so its target list is **derived from CLAUDE.md's documentation map** rather than the hardcoded 5-dir list (`docs/reference/`, `docs/adr/`, `docs/domain/`, `analysis/`, `.tickets/`).

Procedure: parse the project's CLAUDE.md "Documentation map" section, extract the directory references, run the orphan check on each. Falls back gracefully when CLAUDE.md is missing the section.

## Why

The current hardcoded list misses load-bearing dirs in non-library templates: `_tools/` and `.claude/skills/` (tool-integration), per-artifact dirs like `tasks/<Name>/` (tool-integration), and any newly-created top-level dir like `data/` (analysis). All three of those non-library subagents flagged this gap in the self-test.

A doc-map-derived list is the principled fix: every dir mentioned in CLAUDE.md is a top-level documented dir, by definition.

## Acceptance criteria

- [x] `/finish` SKILL.md step 2 reads CLAUDE.md's documentation map and derives the orphan-sweep target list.
- [x] Falls back to "warn user, do nothing" if the doc map can't be parsed.
- [x] Per-artifact-dir patterns (`<surface>/<Name>/`) are out of scope for this ticket — that's its own design question (in the grill batch).
- [x] Tested against a synthetic project where a new top-level dir was added but not yet in CLAUDE.md — sweep should flag the doc-map omission, not the orphans inside it.

## Blocked by

None.

## Comments

(empty)
