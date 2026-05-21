# ADR-0001: Canonical SGR(T, W) surface lives in `growth_models`, not in this project

- **Status:** accepted
- **Date:** 2026-05-21
- **Provenance:** intake session (`target-projects/modelling-fish-growth/_warehouse/intake-notes.md`).

## Context

This project produces a fitted Murray cod `SGR(T, W)` surface from operational pond data via the per-cycle iterative fit (see `idea.md`). Two sibling packages already exist:

- `growth_models` — owns the `growth_models.sgr` surface callable, the `0.0067 %·d⁻¹` floor, and the SGR formula conventions for downstream consumers.
- `FishGrowthFittingSGRpackage` — owns the per-cycle fitter (`alpha`, `log_alpha`, `SplineFit`, `simulation.py`).

The question: where does the **converged surface itself** live once we have it?

## Decision

The canonical Murray cod surface lives in `growth_models`, not in this project. This project's role is to *produce* refits and hand them over; `growth_models` is the single home for surface callables that downstream consumers (including this project's own per-cycle fit in the next iteration round) import.

## Alternatives considered

1. **This project owns the surface.** ModellingFishGrowth exports `modelling_fish_growth.sgr_murray_cod`; downstream consumers import from here. Rejected: would invert the existing dependency direction (downstream depends on a research project), would make this project a permanent runtime dependency for anything that wants the surface, and would force `growth_models` to be retrofitted to import from a sibling research project.
2. **Each project owns its own surfaces.** Rejected: forces downstream consumers to know which project produced a given species' surface, and the floor / convention rules would drift between projects.
3. **Coefficients in a shared standalone repo / data package.** Rejected: adds a third package for what's currently two; doesn't justify itself until there are surfaces for multiple species fitted by multiple projects.

## Consequences

- This project's per-cycle fit imports `growth_models.sgr` (initially Glencross / barramundi) and writes refit coefficients out to `growth_models`. Round N+1 then imports the round-N coefficients back via `growth_models`.
- A defined **handoff protocol** is needed (file format, where the coefficients land in `growth_models`, how the callable is exposed). Open question — see `_warehouse/intake-notes.md`. Provisional default: a coefficients file (JSON or TOML) committed into `growth_models` and a variant callable that loads from it.
- During an active fitting round, the in-progress / candidate surfaces live in this repo as intermediate artefacts (under `analysis/<dated>/artifacts/` or a project-level `artifacts/` later). Only the converged surface gets promoted to `growth_models`.
- The convention rules — `%·d⁻¹` units, the `0.0067` floor, the daily step formula — stay enforced by `growth_models`. This project does not re-implement them; it produces coefficients consistent with those rules.

## References

- `idea.md` — per-cycle iterative fit process.
- `docs/sgr_conventions.md` (in source) — SGR conventions enforced by `growth_models`.
- `~/PycharmProjects/GrowthModels` — canonical surface package.
