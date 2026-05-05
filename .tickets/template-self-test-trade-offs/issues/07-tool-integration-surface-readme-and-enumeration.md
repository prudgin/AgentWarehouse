**Status:** ready-for-agent
**Category:** enhancement
**Type:** AFK

## Parent

[../PRD.md](../PRD.md). Implements [ADR-0022](../../../docs/adr/0022-surface-readme-and-finish-enumeration-for-tool-integration.md).

## What to build

Document the surface-README convention for tool-integration projects, and add a `/finish` step that enumerates per-artifact dirs and verifies `*-meta.json` integrity.

Specifically:

1. In `templates/tool-integration/CLAUDE.md`:
   - In the "Documentation map" section, add a line: *"`<surface>/README.md` — surface-specific conventions (display-name normalisation, meta-field semantics, push-vs-pull policy). One per declared surface dir."*
   - In the "Update rules" section, add: *"New surface added → create `<surface>/README.md` documenting the surface's conventions."*
   - Note that surface READMEs do **not** list specific artifacts (artifact churn would drift them); they document conventions only.
2. Surface dirs are project-specific and not pre-created in the template (the existing `tasks/` / `flows/` references in the template's directory-layout block are illustrative). Leave the template structure as-is — projects create surface dirs when they integrate a new surface.
3. Add a new step to `skills/finish/SKILL.md`. Insert as **Step 5b — Verify per-artifact-dir integrity (tool-integration projects only)** (or extend the existing analysis-tree step if cleaner). Procedure:
   - Detect tool-integration shape: CLAUDE.md mentions `_tools/` in the doc map (the canonical signal).
   - For each top-level directory referenced in the doc map that is not already covered by the standard sweep (i.e., not `docs/`, not `analysis/`, not `.tickets/`, not `_tools/`, not `.claude/`), treat it as a candidate surface dir.
   - For each candidate surface dir:
     - Verify `<surface>/README.md` exists. If not, surface as "missing surface README".
     - Walk every `<surface>/<Name>/` subdir and verify `<surface>-meta.json` is present and parseable JSON. Surface missing or malformed.
   - In auto mode, only surface — do not auto-create or repair.
4. Renumber subsequent steps in `/finish` accordingly. Update step 10's report fields to include surface-integrity findings.

## Acceptance criteria

- [ ] `templates/tool-integration/CLAUDE.md` documents the surface-README convention in doc map + update rules.
- [ ] `skills/finish/SKILL.md` has a per-artifact-dir enumeration step gated on tool-integration shape detection (presence of `_tools/` in doc map).
- [ ] The step verifies surface README existence and per-artifact `*-meta.json` presence.
- [ ] No regression to non-tool-integration templates (the new step is no-op when `_tools/` is absent).
- [ ] Subsequent step numbers in `/finish` SKILL.md renumber correctly.

## Blocked by

None — can start immediately.

## Comments

(empty)
