**Status:** done
**Category:** enhancement
**Type:** AFK

## Parent

[../PRD.md](../PRD.md). Implements [ADR-0018](../../../docs/adr/0018-glossary-entries-as-headings.md).

## What to build

Convert every glossary entry from `**Term**:` bold-paragraph labels to `### Term` headings so deep-links resolve via standard markdown anchors.

Files to migrate:

1. `glossary.md` (warehouse)
2. `templates/library/glossary.md`
3. `templates/pipeline/glossary.md`
4. `templates/tool-integration/glossary.md`
5. `templates/analysis/glossary.md`

For each file:

- Convert each entry. Pattern: `**Term**:\n<definition>\n_Avoid_: ...` → `### Term\n\n<definition>\n\n_Avoid_: ...` (blank lines around heading and around `_Avoid_:` for clean rendering).
- Update the file's "Format rules" section to specify `### Term` heading-style (replace any reference to bold-paragraph labels).
- Preserve the rest of each entry verbatim (definition text, `_Avoid_`, `_Provenance_` if present).

Verification:

- After migration, search the warehouse for any `glossary.md#` deep-links and confirm each anchor now resolves (the slug is the lower-cased, hyphen-joined heading text).
- The warehouse's existing chained-provenance example in `templates/analysis/glossary.md` should now have a working `glossary.md#linear-gaussian-baseline` deep-link.

## Acceptance criteria

- [x] All five glossary files use `### Term` heading style.
- [x] Each file's "Format rules" section reflects the new convention.
- [x] No `**Term**:` bold-paragraph entries remain in any glossary.
- [x] Existing deep-links into glossaries (if any) resolve.
- [x] No content lost (definitions, `_Avoid_`, `_Provenance_` all preserved).

## Blocked by

None — can start immediately.

## Comments

(empty)
