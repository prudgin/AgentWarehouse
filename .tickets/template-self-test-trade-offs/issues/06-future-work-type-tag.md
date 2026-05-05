**Status:** done
**Category:** enhancement
**Type:** AFK

## Parent

[../PRD.md](../PRD.md). Implements [ADR-0021](../../../docs/adr/0021-future-work-entries-carry-type-tag.md).

## What to build

Add an explicit `**Type:** watching | open-question | proposal | refinement-candidate` field to every future-work entry, update the entry-format documentation accordingly, and collapse `/finish` step 6 (graduation sweep) from heuristic-based judgment to a deterministic grep.

Specifically:

1. Update the **Entry format** section in each planning README to include the new field (parallel to existing `**What:**`, `**Why:**`, `**Open questions:**`, `**Links:**`):
   - `docs/planning/README.md` (warehouse)
   - `templates/library/docs/planning/README.md`
   - `templates/pipeline/docs/planning/README.md`
   - `templates/tool-integration/docs/planning/README.md`
   - `templates/analysis/docs/planning/README.md`
   The four type values:
   - **`proposal`** — the only graduating type. Concrete shape, decision implied, AC-able. Step 6 surfaces these for ticket conversion.
   - **`watching`** — "watch how X plays out in real use; revisit if Y." No deliverable.
   - **`open-question`** — undecided trade-off, design tension waiting for evidence. Becomes an ADR or domain doc once decided, not a ticket.
   - **`refinement-candidate`** — "this might want sharpening once we use it more." Resolved by use, not by a worked ticket.
2. Tag every existing entry across all 5 future-work.md files. The warehouse's own `docs/planning/future-work.md` has these sections to tag:
   - "Migrations queued" entries → likely `proposal` (concrete migration targets) or `refinement-candidate` (small projects waiting to activate).
   - "Skills to refine" entries → `refinement-candidate` (resolved by use).
   - "Templates to refine" entries → `refinement-candidate`.
   - "Out-of-scope knowledge base" → `proposal` (concrete pattern to adopt).
   - "Open questions" → `open-question`.
   The four template `future-work.md` files are mostly placeholder examples — update their illustrative entries to model the new format.
3. Rewrite `skills/finish/SKILL.md` step 6 (future-work graduation sweep). The new procedure:
   - Run `grep -nE '^\*\*Type:\*\* proposal' docs/planning/future-work.md` (or equivalent).
   - For each match, surface the entry to the user as a graduation candidate.
   - In auto mode without a user, list candidates in the final report and stop short of moving them.
   - Drop the heuristics-based classification from step 6 (it's no longer needed once entries are tagged). Keep the dropped-h4 commit's renumbering intact.

## Acceptance criteria

- [x] All five planning READMEs document the `**Type:**` field with the four values.
- [x] Every entry in every `future-work.md` (warehouse + 4 templates) carries a `**Type:**` line.
- [x] `skills/finish/SKILL.md` step 6 collapses to a grep + surface flow.
- [x] No regression: the warehouse's own future-work entries still classify correctly under the new system (proposal-marked entries surface; others stay).

## Blocked by

None — can start immediately.

## Comments

(empty)
