**Status:** ready-for-agent
**Category:** enhancement
**Type:** AFK

## Parent

[../PRD.md](../PRD.md). Implements [ADR-0016](../../../docs/adr/0016-mixed-mode-for-migrate-and-create.md).

## What to build

Move `/migrate-project` and `/create-project` from "refuses auto mode" to mixed-mode (auto for reversible local actions, pause-and-surface for destructive or shared-state ones — same pattern as `/work-issue` and `/finish`).

Specifically:

1. In `skills/migrate-project/SKILL.md`, replace the "Refuse auto mode" section with a "Mixed mode" section that:
   - Lets the skill run autonomously through `add` (from staging), `move`, `rename` items in Phase 3.
   - Pauses and surfaces before each `convert`, `delete`, or `conflict-resolution` item (the existing per-item confirmation rules already cover most of this — make sure the language now expects auto-mode execution rather than rejecting it).
   - In auto mode without a user, surfaces what's pending and stops short of destructive ops.
2. In `skills/create-project/SKILL.md`, same treatment: replace "Refuse auto mode" with "Mixed mode". Most of `/create-project` is mechanical (template copy, placeholder substitution, git init); the questions in step 3 only run if staging is absent and the user is present. In auto mode without staging, surface and stop.
3. Both skills enumerate their **destructive-op set** explicitly in their SKILL.md (per ADR-0016's mitigation requirement).
4. `/intake-target-project`, `/grill`, `/to-issues`, `/triage`, `/improve-codebase-architecture` are unchanged — they remain refuse-auto per ADR-0011's narrowed scope.

## Acceptance criteria

- [ ] `skills/migrate-project/SKILL.md` no longer refuses auto mode unconditionally; has a "Mixed mode" section with destructive-op set enumerated.
- [ ] `skills/create-project/SKILL.md` same.
- [ ] Each skill's pause-and-surface behaviour matches `/work-issue`'s pattern (auto for reversible local actions; pause for shared-state and destructive).
- [ ] In auto mode without a user, both skills surface pending decisions and stop rather than silently default.
- [ ] No edits to `/intake-target-project` or other purely-interview skills.

## Blocked by

None — can start immediately.

## Comments

(empty)
