# ADR-0006 — `/update-register-entry` is auto-invoked from `/finish` in research-template projects

**Status**: Accepted (intake 2026-05-21)

## Context

The overseer is only useful if per-project `.register/entry.yaml` files are kept up to date. If updating them is purely opt-in ("remember to run `/update-register-entry` before you call it a day"), entries will drift, and the register will silently lag reality.

The `/finish` skill is the canonical end-of-work ritual in every project. In research-template projects it also runs `/sharepoint-sync push` so the entry.yaml lands on SharePoint. Hooking entry maintenance into the same place is the natural integration point.

## Decision

The warehouse `/finish` skill, when invoked in a research-template project, calls `/update-register-entry` before the `/sharepoint-sync push` step. The skill follows the intentional-blank protocol: known-blanks are skipped, unknowns prompt the human, then it writes `.register/entry.yaml` and bumps `_meta.last_populated` + `_meta.populated_by`. The sync step then pushes the updated entry.yaml to SharePoint.

This affects:
- `~/AgenticEngineering/skills/finish/SKILL.md` — add a research-template-detection branch that calls `/update-register-entry` before push.
- `~/AgenticEngineering/skills/update-register-entry/` — new canonical skill.
- `~/AgenticEngineering/templates/research/CLAUDE.md` — document the new auto-call in the Skills section.
- `~/AgenticEngineering/templates/research/.rclone-filter` — add a carve-out so `.register/` syncs.

## Consequences

**Positive:**
- Register stays current with minimal user effort.
- Every `/finish` in a research project is a natural checkpoint for "what changed about this project's metadata?".
- The overseer's sweep finds fresh data, not stale.

**Negative:**
- Adds friction to `/finish` (more prompts, especially first run when many fields are unset).
- Failure modes: if `/update-register-entry` errors, does `/finish` halt or continue? Decision: halt with a clear error; the human can re-run `/finish` after fixing.

## Alternatives considered

- **Opt-in only.** Rejected: drift inevitable.
- **Separate `/update-register-entry` invocation hooked at session-start.** Rejected: too noisy; the data changes most at session-end.
- **Hook into `/sharepoint-sync push` directly.** Rejected: violates separation of concerns; sync is mechanical, entry maintenance is interactive.

## Related

- [[0001-entry-yaml-canonical]]
- [[finish]] (warehouse skill, modification required)
- [[update-register-entry]] (new skill)
- [[research-template]]
