**Status:** ready-for-agent
**Category:** prd

## What to build

Adopt Matt Pocock's `.out-of-scope/<concept>.md` pattern: when `/triage` marks an enhancement as `wontfix`, write a durable record to `.out-of-scope/<concept>.md` capturing why the feature was rejected. Subsequent similar requests get matched against existing entries and deduped rather than re-litigated each time.

Graduated from `docs/planning/future-work.md` "Out-of-scope knowledge base → Adopt `.out-of-scope/` pattern from Matt Pocock's skills" entry per `/finish` step 6 surfacing it as a `proposal`-tagged graduation candidate.

## Why

Solo-mode use surfaces `wontfix` enhancements rarely, but each one has a real reason ("we tried X; it pulls in Y; the cost-benefit isn't there"). Without a durable home, the reason gets re-derived every time someone proposes X again. Matt's pattern says: write it once, link future similar requests to the existing entry, and let the entry accumulate "we said no for these N reasons across these M requests" over time.

The matching mechanism is the open design question — title similarity is fragile, manual lookup is friction, agent judgment is the most flexible but adds a step. This work picks an approach and ships it.

## Why now

The build chain has been exercised end-to-end (the trade-offs batch produced 8 implementation tickets from ADRs; the self-test-fixes batch produced 13 from a REPORT). No `wontfix` enhancements have surfaced yet, but the pattern is small enough to ship before one does, so the first `wontfix` lands cleanly rather than triggering a "wait, we should have a place for this" detour.

## Acceptance criteria

- [ ] Issue 01 closed (status `done`).
- [ ] `/triage` skill body extended to write `.out-of-scope/<concept>.md` on `wontfix` of an `enhancement`-category ticket.
- [ ] `.tickets/README.md` (template) documents the `.out-of-scope/` directory.
- [ ] Templates' `.tickets/README.md` files mention the convention so projects scaffolded post-this know about it.
- [ ] `bash skills/finish/scripts/check-docs.sh --all` still passes.

## Blocked by

None.

## Comments

(empty)
