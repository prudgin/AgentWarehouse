# Reference

How the code works. The **canonical list of stages lives in CLAUDE.md's Pipeline-areas table** — these per-stage docs are *detail* that links back to that table for the authoritative roster. **One doc per pipeline stage** (matching the Pipeline-areas table), plus a cross-cutting `conventions.md`. Source of truth for behaviour is the code itself; these docs describe what the code currently does, not what it should do.

*Orchestration* lives only in CLAUDE.md (it's a row in the Pipeline-areas table without its own code dir) and has no per-stage doc here. Every other row in the table must have a matching `<stage>.md` in this directory, and every `<stage>.md` here must correspond to a row in the table. `/finish` cross-checks both directions.

## Rules

- Update **after** implementing or significantly changing a stage.
- Link to `glossary.md` and `docs/domain/` for context — never duplicate domain knowledge here.
- Link to `docs/adr/` for decisions that shaped the design — never restate the rationale here.
- Describe behaviour, interfaces, and invariants of each stage. Don't paste code; link to it.
- One file per stage. Cross-cutting conventions go in `conventions.md`.

## Index

<!-- PLACEHOLDER — list each reference doc with a one-line summary. The
     /finish skill checks that every file in this directory is listed here.

- [conventions.md](conventions.md) — coding rules, naming, validation, error handling, CSV/parquet conventions, timezone handling.
- [ingestion.md](ingestion.md) — ingestion stage: source, fetch logic, schema.
- [stage_a.md](stage_a.md) — stage A: inputs, outputs, transformations, QA invariants.
- [stage_b.md](stage_b.md) — stage B: ...
- [orchestration.md](orchestration.md) — how the stages fit together; entry point; deployment.

-->
