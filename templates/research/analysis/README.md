# Analysis

**The primary work surface for this project.** One subdirectory per investigation. Each subdir holds the scripts that produced the result and a canonical `INVESTIGATION.md` writeup. Cross-cutting narrative across all investigations lives in [analysis-landscape.md](analysis-landscape.md).

For a research project, this is where work happens. The build-chain workflow (`/grill` → `/to-prd` → tickets) is available but not central; the analyse chain (`/start-analysis` → investigate → `/finish-analysis`) runs the show.

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

TODO: what did we set out to find out?

## Method

TODO: scripts, data sources, assumptions used.

## Findings

TODO: what we learned, with concrete evidence.

## Implications

TODO: what should land in glossary.md / docs/domain/ / docs/adr/ / future-work.md — and any **report-worthy** figure or number → promote to Reports/report-backbone.md.

## Open ends

TODO: what's left unresolved.
```

## Workflow

1. Start: `/start-analysis <topic>` (or manual: create the dir, copy the INVESTIGATION template, add a stub entry to `analysis-landscape.md`).
2. Investigate: scripts go in the dir, outputs in `outputs/`.
3. Finish: `/finish-analysis` (or manual: finalise INVESTIGATION, update the landscape entry, promote findings to `glossary.md` / `docs/domain/` / `docs/adr/` / `future-work.md` as applicable).

## Findings provenance

Every claim that lands outside this directory (in `glossary.md`, `docs/domain/`, `docs/adr/`) should link the INVESTIGATION that produced it. The provenance link is what lets a future agent verify the claim against original evidence rather than treating it as folklore.

## Promotion to the report backbone

When an investigation produces a figure or number worth putting in the final report, it is a **keeper** — promote it to [`../Reports/report-backbone.md`](../Reports/report-backbone.md) ("aha → backbone"): a figure-register row (stable `R-xx`, provenance, `report:` status) and/or a headline-numbers entry, plus a one-command regenerator in `pipeline/`. `/finish-analysis` prompts this from the Implications section. The scatter — including dead ends — stays here in `analysis/`; only keepers reach the backbone. See [`../Reports/README.md`](../Reports/README.md) for the register format.

## No-orphan rule

Every subdir must be linked from `analysis-landscape.md`. The `/finish` skill sweeps for orphan analysis dirs.
