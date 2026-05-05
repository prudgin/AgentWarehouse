# Analysis

One subdirectory per investigation, dated `YYYY-MM-DD-<kebab-topic>/`. Each holds the scripts that produced the result and a canonical `INVESTIGATION.md`. Cross-cutting narrative across investigations lives in [analysis-landscape.md](analysis-landscape.md).

This directory is currently empty — the warehouse design itself was the result of conversation-based research, not script-driven investigation. Future investigations specific to the warehouse (e.g. comparative review of an additional reference repo, performance characterisation of the migration playbook on a real codebase) will land here.

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
