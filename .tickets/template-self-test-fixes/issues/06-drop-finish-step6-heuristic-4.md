**Status:** done
**Category:** enhancement

## What to build

Remove heuristic 4 from `skills/finish/SKILL.md` step 6 (future-work-graduation sweep):

> The entry has been in the file across more than one work session without changing.

Renumber the remaining heuristics (3 → 3, just delete 4). Confirm the "if the entry passes 2+ heuristics, surface it" rule still works with 3 heuristics (it does — 2-of-3 is a sensible bar).

## Why

The library subagent flagged that this heuristic requires session-count metadata that nothing produces. There's no commit-pinned timestamp, no skill-managed counter, no `last-edited-in-session-N` annotation. The heuristic is unusable as written.

Dropping it leaves the three usable heuristics (imperative title, AC-shaped sub-bullets, no open-questions line). Subagents confirmed the 2-of-3 classifier works correctly across all 6 future-work entries they produced — no false positives, no false negatives.

## Acceptance criteria

- [x] Heuristic 4 removed from `skills/finish/SKILL.md` step 6.
- [x] The "if entry passes 2+ heuristics, surface it" rule updated to reflect the 3-heuristic count (or the bar is preserved at 2-of-3 explicitly).
- [x] No other warehouse doc references "heuristic 4" in a way that breaks.

## Blocked by

None.

## Comments

(empty)
