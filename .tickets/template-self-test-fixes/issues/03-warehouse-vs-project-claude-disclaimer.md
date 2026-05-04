**Status:** ready-for-agent
**Category:** enhancement

## What to build

Add a one-line disclaimer at the top of each project template's CLAUDE.md (immediately after the H1 title, before the FIXED/PLACEHOLDER sections):

> *This project was scaffolded from the [AgenticEngineering](https://github.com/...) warehouse. The warehouse's own `CLAUDE.md` describes the warehouse, not this project — do not load it as authoritative; this file is.*

Apply to all four templates: `library/`, `pipeline/`, `tool-integration/`, `analysis/`.

If the warehouse has no remote URL configured, drop the link and just say "the AgenticEngineering warehouse".

## Why

Two self-test subagents (library, analysis) flagged genuine confusion potential: the warehouse's CLAUDE.md and a project's CLAUDE.md share the same skeleton (FIXED/PLACEHOLDER markers, doc map, no-orphan rule, identical sentence shapes). A sloppy agent who loads both could conflate them. One disclaimer line mitigates this.

## Acceptance criteria

- [ ] The disclaimer line is present in `templates/library/CLAUDE.md`, `templates/pipeline/CLAUDE.md`, `templates/tool-integration/CLAUDE.md`, `templates/analysis/CLAUDE.md`.
- [ ] The line wording is identical across templates (or the wording difference is justified by template purpose).
- [ ] No fix needed in the warehouse's own `CLAUDE.md` — this is a project-template change, the warehouse is the warehouse.

## Blocked by

None.

## Comments

(empty)
