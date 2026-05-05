**Status:** ready-for-agent
**Category:** prd

## What to build

Unify the placeholder marker style across all warehouse template files. Currently `<!-- FIXED -->`, `<!-- PLACEHOLDER ... -->`, and `<PLACEHOLDER: ...>` coexist inconsistently — sometimes within the same file.

Graduated from `docs/planning/future-work.md` "Templates to refine → Placeholder marker convention" entry per `/finish` step 6 surfacing it as a `proposal`-tagged graduation candidate.

## Why

Inconsistency is friction at two moments: (1) when scaffolding a new project, the user has to recognise three different marker shapes and know which to delete vs. keep vs. fill; (2) when updating a template, the maintainer has to remember which form is "right" for which kind of section. A single canonical form per role eliminates both frictions.

The roles are real and probably need different markers — they're not redundant:

- **FIXED** means "do not edit between projects; this is part of the philosophy". Section-level marker.
- **PLACEHOLDER block** means "this section needs project-specific content; here's a hint about what". Section-level marker.
- **Inline `<PLACEHOLDER: ...>`** means "substitute this token at scaffold time". Token-level marker. Already used by `/create-project` step 6.

So the goal isn't to collapse three roles into one — it's to pick a canonical form per role and apply it consistently.

## Acceptance criteria

- [ ] Issue 01 closed (status `done`).
- [ ] All template files use the canonical marker per role.
- [ ] Sweep: `git grep -E '<!-- (FIXED|PLACEHOLDER)' templates/` returns the same shape everywhere.
- [ ] No regression: `bash skills/finish/scripts/check-docs.sh --all` still passes.

## Blocked by

None.

## Comments

(empty)
