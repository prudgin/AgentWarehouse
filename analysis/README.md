# Analysis

One subdirectory per investigation, dated `YYYY-MM-DD-<kebab-topic>/`. Each holds the scripts that produced the result and a canonical `INVESTIGATION.md`. Cross-cutting narrative across investigations lives in [analysis-landscape.md](analysis-landscape.md).

Investigations to date are registered in [analysis-landscape.md](analysis-landscape.md): the 2026-05-04 template self-test and the in-progress 2026-06-12 canonical-setup synthesis (a survey of this PC's agentic setups, philosophy files, and settings, toward a single unified setup). Future investigations specific to the warehouse will land here too.

## Conventions

See the library template's analysis README for the full conventions, INVESTIGATION.md format, and workflow:
- [`templates/library/analysis/README.md`](../templates/library/analysis/README.md)

The same conventions apply here.

## Workflow

1. Start: `/start-analysis <topic>` (or manual: create the dir, copy the INVESTIGATION template, add a stub entry to [analysis-landscape.md](analysis-landscape.md)).
2. Investigate.
3. Finish: `/finish-analysis` (or manual).

## No-orphan rule

Every subdirectory must be linked from [analysis-landscape.md](analysis-landscape.md).
