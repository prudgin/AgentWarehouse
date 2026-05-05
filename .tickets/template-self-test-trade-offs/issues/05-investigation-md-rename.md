**Status:** ready-for-agent
**Category:** enhancement
**Type:** AFK

## Parent

[../PRD.md](../PRD.md). Implements [ADR-0020](../../../docs/adr/0020-investigation-md-not-report-md.md).

## What to build

Rename the analysis primary deliverable from `REPORT.md` to `INVESTIGATION.md` across the warehouse, all four templates, and the warehouse's existing analysis tree.

Files to update (replace every `REPORT.md` reference with `INVESTIGATION.md` in the analysis context):

1. `skills/start-analysis/SKILL.md` — stub content + filename references.
2. `skills/finish-analysis/SKILL.md` — verification grep + filename references.
3. `skills/finish/SKILL.md` — analysis-tree references in step 5.
4. `templates/library/analysis/README.md` — REPORT format block + workflow references.
5. `templates/library/analysis/analysis-landscape.md` — placeholder example links.
6. `templates/pipeline/analysis/README.md` — same.
7. `templates/pipeline/analysis/analysis-landscape.md` — same.
8. `templates/tool-integration/analysis/README.md` — same.
9. `templates/tool-integration/analysis/analysis-landscape.md` — same.
10. `templates/analysis/analysis/README.md` — same. (This is the analysis template; touches more than just the format block.)
11. `templates/analysis/analysis/analysis-landscape.md` — same.
12. `templates/analysis/CLAUDE.md` — documentation-map line and any other REPORT.md references.
13. `templates/{library,pipeline,tool-integration}/CLAUDE.md` — documentation-map line referencing `analysis/YYYY-MM-DD-<topic>/REPORT.md`.

Also rename the actual file:

14. `analysis/2026-05-04-template-self-test/REPORT.md` → `analysis/2026-05-04-template-self-test/INVESTIGATION.md`.
15. `analysis/analysis-landscape.md` — update the link to point at the new filename.

Update `glossary.md` (warehouse) and `templates/analysis/glossary.md` if either has an entry referencing `REPORT.md` by name (currently neither does, but verify).

## Acceptance criteria

- [ ] `git grep -l 'REPORT\.md'` from the warehouse root returns zero hits in skill bodies, template files, and the warehouse's own `analysis/` (excluding any commit-message references in `.git/`).
- [ ] All references now use `INVESTIGATION.md`.
- [ ] The file `analysis/2026-05-04-template-self-test/INVESTIGATION.md` exists; the old filename does not.
- [ ] `analysis/analysis-landscape.md` link target points at the new filename.
- [ ] No content lost in the rename — file contents preserved.

## Blocked by

None — can start immediately.

## Comments

(empty)
