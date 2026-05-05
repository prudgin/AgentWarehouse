**Status:** ready-for-agent
**Category:** prd

## What to build

Implementation tickets for ADRs 0016–0023, the eight trade-off-shaped findings from the 2026-05-04 template self-test that were resolved in the subsequent `/grill` session.

The ADRs *are* the destination docs — each one specifies the decision and the implementation shape. The tickets here are the work to make the warehouse + templates + skills match the ADRs.

## Why

The 2026-05-04 self-test ([INVESTIGATION](../../analysis/2026-05-04-template-self-test/INVESTIGATION.md)) surfaced 21 findings. Thirteen were no-trade-off mechanical fixes — those landed in [`template-self-test-fixes/`](../template-self-test-fixes/PRD.md) and are all `done`. Eight were design questions with real alternatives — those went through `/grill` and produced [ADRs 0016–0023](../../docs/adr/README.md). This batch implements those ADRs.

## Scope

Eight tickets, one per ADR. All `ready-for-agent`, all AFK, no `Blocked by` cross-links — pickup order is left to whoever runs `/work-issue`. Several tickets touch overlapping files (`skills/finish/SKILL.md`, `skills/create-project/SKILL.md`); take them sequentially or merge in one branch when the time comes.

## Out of scope

- The 13 fixes already shipped in `template-self-test-fixes/`.
- New design decisions not in ADRs 0016–0023.
- Migration of existing scaffolded projects to the new conventions — none exist yet (GutEvac is in flight under another agent).

## Acceptance criteria

- [ ] All 8 issue files closed (status `done`).
- [ ] Each ADR's implementation matches the ADR text.
- [ ] No new orphan docs introduced.
- [ ] `/finish` sweeps cleanly on the warehouse after the batch lands.

## Blocked by

None.

## Comments

(empty)
