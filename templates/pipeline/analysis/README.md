# Analysis

One subdirectory per investigation. Each subdir holds the scripts that produced the result and a canonical `INVESTIGATION.md` writeup. Cross-cutting narrative across all investigations lives in [analysis-landscape.md](analysis-landscape.md).

## Subdirectory naming

```
analysis/YYYY-MM-DD-<kebab-topic>/
```

The date is when the investigation **started**. The topic is short, kebab-cased, descriptive.

## Required contents per subdir

```
YYYY-MM-DD-<topic>/
├── INVESTIGATION.md            # canonical writeup — required
├── <scripts>.{py,sh,...}  # whatever produced the result
├── outputs/             # gitignored — large artefacts, plots, parquets
└── plots/               # committed only if user-facing or referenced from INVESTIGATION
```

## INVESTIGATION.md format

```md
# <Investigation title>

**Date:** YYYY-MM-DD (started) → YYYY-MM-DD (last update)
**Status:** in-progress | complete | superseded by analysis/<other-dir>

## Question

What did we set out to find out?

## Method

What did we actually do? Scripts, data sources, assumptions.

## Findings

What did we learn? Concrete, evidenced. Plot links, table excerpts.

## Implications

What does this change about the project? Anything that should land in
glossary.md, docs/domain/, docs/adr/, or future-work.md?

## Open ends

What's left unresolved? What follow-up investigations does this suggest?
```

## Workflow

1. Start: `/start-analysis <topic>` (or manual: create the dir, copy the INVESTIGATION template, add a stub entry to `analysis-landscape.md`).
2. Investigate: scripts go in the dir, outputs in `outputs/`.
3. Finish: `/finish-analysis` (or manual: finalise INVESTIGATION, update the landscape entry, promote findings to `glossary.md` / `docs/domain/` / `docs/adr/` / `future-work.md` as applicable).

## No-orphan rule

Every subdir must be linked from `analysis-landscape.md`. The `/finish` skill sweeps for orphan analysis dirs.
