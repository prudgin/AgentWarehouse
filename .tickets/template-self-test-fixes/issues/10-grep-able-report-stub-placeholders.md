**Status:** done
**Category:** enhancement

## What to build

In `templates/analysis/analysis/README.md`, the REPORT.md template/format block has prose-shaped placeholders ("What did we set out to find out? One paragraph."). Replace these with literal `TODO` tokens that `finish-analysis` step 2 ("verify REPORT.md has real content") can grep for mechanically.

Suggested change:
```md
## Question

TODO: what did we set out to find out?

## Method

TODO: scripts, data sources, assumptions used.

## Findings

TODO: what we learned, with concrete evidence.

## Implications

TODO: what should land in glossary.md / docs/domain/ / docs/adr/ / future-work.md.

## Open ends

TODO: what's left unresolved.
```

Update `skills/finish-analysis/SKILL.md` (if it's not already this way) to grep `TODO:` and refuse to mark the analysis complete while any TODO remains.

If the `start-analysis` skill ships a stub REPORT.md, ensure it uses the same TODO-token pattern.

## Why

Analysis subagent flagged that prose-shaped placeholders are easy to leave in by accident — `finish-analysis`'s "is this still placeholder text" check is currently a fuzzy semantic comparison rather than a grep. Grep-able tokens make the check mechanical and fail-loudly.

## Acceptance criteria

- [x] `templates/analysis/analysis/README.md` REPORT format block uses `TODO:` tokens.
- [x] `start-analysis` skill (if it scaffolds a REPORT stub) uses the same tokens.
- [x] `finish-analysis` skill greps for `^TODO:` (or equivalent) and surfaces remaining ones during cleanup.

## Blocked by

None.

## Comments

(empty)
