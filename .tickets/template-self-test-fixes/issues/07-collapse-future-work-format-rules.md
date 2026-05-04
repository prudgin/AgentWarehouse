**Status:** ready-for-agent
**Category:** enhancement

## What to build

Collapse the format-rule duplication between `docs/planning/README.md` and `docs/planning/future-work.md` in each template:

- `docs/planning/README.md` has the boundary table (future-work vs. tickets), the transition rule, and the "what stays" list.
- `docs/planning/future-work.md` has its own (slightly different) "Format" section with an entry template (`## <short title>`, `**What:**`, `**Why:**`, etc.).

Move the entry-format template into `docs/planning/README.md` (in a new "Entry format" section). Remove it from `future-work.md`. Have `future-work.md` start with a one-line note pointing to the README for both the boundary rule and the entry format.

Apply to all four templates and to the warehouse's own `docs/planning/`.

## Why

Library subagent flagged that a reader writing a new entry isn't sure which file's format to follow — they don't conflict, but they're not the same. Single-canonical-home rule applies here too.

## Acceptance criteria

- [ ] `docs/planning/README.md` in each template (and in the warehouse) contains the entry-format section.
- [ ] `docs/planning/future-work.md` in each template (and in the warehouse) starts with a pointer to the README and contains no duplicate "Format" rules.
- [ ] No conflicting wording between the two files.

## Blocked by

None.

## Comments

(empty)
