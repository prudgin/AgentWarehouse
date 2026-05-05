**Status:** ready-for-agent
**Category:** prd

## What to build

A batch of 13 fixes to the warehouse templates and skills, surfaced by the 2026-05-04 template self-test ([INVESTIGATION](../../analysis/2026-05-04-template-self-test/INVESTIGATION.md)).

These are the *no-trade-off* fixes — concrete, scoped, no design decisions to make. The 8 trade-off-shaped findings from the same self-test are not in this batch; they are queued for a separate `/grill` session and will land as their own tickets / ADRs afterwards.

## Why

The self-test spawned four opus subagents against four synthetic dummy projects (one per template). All four flagged TEMPLATE META block survival at scaffold; three flagged the `/finish` orphan-sweep being too narrow; two flagged warehouse-vs-project CLAUDE.md confusion. The fixes here close those gaps and several smaller polish items.

## Scope

13 issues, each independently shippable. See `issues/` for the breakdown. Most touch a single template or skill; a few are cross-cutting (e.g. the WHAT-placeholder hint applies to all four templates).

## Out of scope

- The 8 trade-off-shaped findings (auto-mode policy for `/migrate-project`, glossary heading-style migration, `scripts/check_docs.sh` design, pipeline-areas table canonical home, `REPORT.md` rename, future-work entry tagging, per-artifact-dir convention, warehouse-default settings.json for templates). Queued for `/grill`.
- Migration-specific issues that didn't surface here. The self-test exercised cold-starts, not migrations.

## Acceptance criteria

- [ ] All 13 issue files closed (status `done`).
- [ ] Each issue's AC is checked off in its own file.
- [ ] No new orphan docs introduced.
- [ ] `/finish` sweeps cleanly on the warehouse after the batch lands.

## Blocked by

None.

## Comments

(empty — append as work progresses)
