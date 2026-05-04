# Analysis Landscape

Cross-cutting narrative across all investigations in `analysis/`. Tells the discovery thread: question → method → finding → what landed → open ends. Each beat links to its `analysis/<dir>/REPORT.md`.

For a research project, this file is the **single point of truth for "how we ended up here"**. New readers should be able to read this and follow the discovery thread without opening every individual REPORT.

Every investigation subdir must be linked from this file. See [analysis/README.md](README.md) for conventions.

## How to read this file

Sections below group investigations by theme, not strictly by date. The same theme can have multiple beats, each one extending or revising the previous. Individual REPORTs stay topic-scoped; this file stitches them together.

## How to update this file

When you start a new investigation: append a stub beat in the relevant section, link the new REPORT (which may not yet exist).

When you finish an investigation: flesh out the beat with the finding (one or two sentences) and what landed downstream (glossary updates, ADRs, domain doc changes, follow-up work).

When an investigation is superseded by a later one: link forward (`→ superseded by [analysis/...]`) but keep the original entry. Discovery thread is append-only at the entry level.

## Themes

<!-- PLACEHOLDER — example structure, replace with real themes.

### Model identification

- **2026-01-14 — sigmoid vs hump model.** Question: does a single sigmoid suffice or is the residual hump real? Method: fit both on full dataset, compare AIC and residual structure. Finding: hump is real and stable across ponds. Landed: `docs/domain/model.md` (the form), ADR-0001 (the choice). → [REPORT](2026-01-14-sigmoid-vs-hump/REPORT.md)

- **2026-02-03 — yesterday-stomach validation gap.** Question: why does the model under-predict the residual at t=0? Method: diff predictions vs. observed across ponds, decompose by pond. Finding: graders systematically under-score "old" pellets; flag as soft-validation only. Landed: `docs/domain/known-issues.md`. → [REPORT](2026-02-03-yesterday-stomach-validation/REPORT.md)

### Data quality

- ...

-->

## Open ends

<!-- PLACEHOLDER — investigations explicitly flagged as having unresolved
     follow-ups. Linked from REPORT "Open ends" sections.

- From [2026-01-14-sigmoid-vs-hump]: cold-band (8–13 °C) data not yet collected; cannot extrapolate.

-->
