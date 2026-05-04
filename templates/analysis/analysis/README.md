# Analysis

**The primary work surface for this project.** One subdirectory per investigation. Each subdir holds the scripts that produced the result and a canonical `REPORT.md` writeup. Cross-cutting narrative across all investigations lives in [analysis-landscape.md](analysis-landscape.md).

For a research project, this is where work happens. The build-chain workflow (`/grill` → `/to-prd` → tickets) is available but not central; the analyse chain (`/start-analysis` → investigate → `/finish-analysis`) runs the show.

## Subdirectory naming

```
analysis/YYYY-MM-DD-<kebab-topic>/
```

The date is when the investigation **started**. The topic is short, kebab-cased, descriptive.

## Required contents per subdir

```
YYYY-MM-DD-<topic>/
├── REPORT.md            # canonical writeup — required
├── <scripts>.{py,sh,...}  # whatever produced the result
├── outputs/             # gitignored — large artefacts, plots, parquets
└── plots/               # committed only if user-facing or referenced from REPORT
```

## REPORT.md format

```md
# <Investigation title>

**Date:** YYYY-MM-DD (started) → YYYY-MM-DD (last update)
**Status:** in-progress | complete | superseded by analysis/<other-dir>

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

## Workflow

1. Start: `/start-analysis <topic>` (or manual: create the dir, copy the REPORT template, add a stub entry to `analysis-landscape.md`).
2. Investigate: scripts go in the dir, outputs in `outputs/`.
3. Finish: `/finish-analysis` (or manual: finalise REPORT, update the landscape entry, promote findings to `glossary.md` / `docs/domain/` / `docs/adr/` / `future-work.md` as applicable).

## Findings provenance

Every claim that lands outside this directory (in `glossary.md`, `docs/domain/`, `docs/adr/`) should link the REPORT that produced it. The provenance link is what lets a future agent verify the claim against original evidence rather than treating it as folklore.

## No-orphan rule

Every subdir must be linked from `analysis-landscape.md`. The `/finish` skill sweeps for orphan analysis dirs.
