**Status:** ready-for-agent
**Category:** enhancement
**Type:** AFK

## Parent

[../PRD.md](../PRD.md).

## What to build

Audit every file under `templates/` for placeholder markers and unify per role. Three roles, three canonical forms:

1. **Section-level FIXED** (this section is part of warehouse philosophy; do not edit per project). Canonical: `<!-- FIXED -->` (HTML comment, single line, immediately before the section heading).
2. **Section-level PLACEHOLDER** (this section needs project-specific content; here's a hint). Canonical: `<!-- PLACEHOLDER — <hint text> -->` (HTML comment, may span multiple lines, immediately before the section heading).
3. **Inline token PLACEHOLDER** (substitute at scaffold time). Canonical: `<PLACEHOLDER: <token name>>` (single line, inline, in the body text where the substitution lands). Used by `/create-project` step 6.

Procedure:

1. `git grep -nE 'PLACEHOLDER|FIXED' templates/` to enumerate current usage.
2. For each occurrence, classify by role and reshape if needed.
3. Verify the section-level markers always sit immediately before the section heading (not after, not at end of file, not inside the section body).
4. Verify inline tokens never use the HTML-comment shape (`<!-- PLACEHOLDER: foo -->`) — those are easy to confuse with section-level markers and `/create-project` doesn't substitute inside HTML comments anyway.
5. After the unification pass, run `bash skills/finish/scripts/check-docs.sh --all` to confirm no orphans or broken links introduced.

## Acceptance criteria

- [ ] All section-level FIXED markers use exactly `<!-- FIXED -->` on their own line, immediately above the section heading.
- [ ] All section-level PLACEHOLDER markers use `<!-- PLACEHOLDER — <hint> -->` shape, immediately above the section heading.
- [ ] All inline tokens use `<PLACEHOLDER: <name>>` shape (no HTML-comment wrapping).
- [ ] No occurrences of mixed-form within a single file.
- [ ] `bash skills/finish/scripts/check-docs.sh --all` passes after the change.
- [ ] Tested by reading the affected templates' CLAUDE.md / README.md and visually confirming the markers read consistently.

## Blocked by

None — can start immediately.

## Comments

(empty)
