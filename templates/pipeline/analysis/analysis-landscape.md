# Analysis Landscape

Cross-cutting narrative across all investigations in `analysis/`. Tells the discovery thread: question → method → finding → what landed → open ends. Each beat links to its `analysis/<dir>/INVESTIGATION.md`.

Every investigation subdir must be linked from this file. See [analysis/README.md](README.md) for conventions.

## How to read this file

Sections below group investigations by theme, not strictly by date. The same theme can have multiple beats, each one extending or revising the previous. The landscape is the single point of truth for "how we ended up here." Individual INVESTIGATIONs stay topic-scoped; this file stitches them together.

## How to update this file

When you start a new investigation: append a stub beat in the relevant section, link the new INVESTIGATION (which may not yet exist).

When you finish an investigation: flesh out the beat with the finding (one or two sentences) and what landed downstream (glossary updates, ADRs, reference doc changes, follow-up work).

When an investigation is superseded by a later one: link forward (`→ superseded by [analysis/...]`) but keep the original entry. Discovery thread is append-only at the entry level.

## Themes

<!-- PLACEHOLDER — example structure, replace with real themes.

### <Theme: e.g. "Growth model fitting accuracy">

- **2026-01-14 — local deviation residuals.** Question: why does the constant-α fit show systematic residuals on Stanbridge ponds? Method: fit per-pond, plot residuals against day-of-cycle. Finding: residuals correlate with temperature swing windows. Landed: ADR-0007 (use spline-α for cycles with high temperature variance); follow-up in `2026-02-03-spline-knot-placement`. → [INVESTIGATION](2026-01-14-local-deviation-residuals/INVESTIGATION.md)

- **2026-02-03 — spline knot placement.** Question: how many knots and where? Method: grid search over knot count and spacing on 12 cycles with known truth. Finding: 5 knots, evenly spaced, beats both fewer and more. Landed: `growth-model.md` updated with default. → [INVESTIGATION](2026-02-03-spline-knot-placement/INVESTIGATION.md)

### <Theme: ...>

-->

## Open ends

<!-- PLACEHOLDER — investigations explicitly flagged as having unresolved
     follow-ups. Linked from INVESTIGATION "Open ends" sections.

- From [2026-01-14-local-deviation-residuals]: behaviour at extreme low temperatures (<8°C) not yet investigated.

-->
