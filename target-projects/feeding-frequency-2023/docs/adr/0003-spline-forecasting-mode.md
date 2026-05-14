# ADR-0003 — Spline forecasting mode

**Status**: accepted.
**Date**: 2026-05-07 (decision); 2026-05-14 (ADR captured).
**Provenance**: `docs/decisions_log.md` 2026-05-07 entry "left-censored unblock + spline forecasting mode".

## Context

The MDF SGR fitting pipeline (`fish_growth_model.fit_alpha_spline`) supports two trajectory-extension modes after a cycle's last sample weight:

- **`modelling`** — truncate the trajectory at the last sample weight. `SimulatedWeight` and `FittedSGR` are NaN after the last sample. Conservative; matches "we don't know what happens after the last measurement".
- **`forecasting`** — hold α at α(last_sample) and re-simulate through the cycle end. Produces a forward trajectory under the assumption that the most recent growth dynamics continue.

The default in upstream MDF is `modelling`.

For this project, **four Trial-2 cages — P5C7, P5C9, P5C11, P6C10 — have no sample-weight measurements after the trial interim check (2023-08-02)**. Under modelling mode, their trajectories truncate 14–35 days **before the trial end of 2023-09-06**, leaving NaN tails that propagate into:

- Per-cage realised SGR (NaN endpoint → can't compute).
- Pooled SFR (NaN biomass → can't aggregate).
- The trial-pooled headline numbers (would have to drop these 4 cages from T2).

## Decision

**Force `mode="forecasting"`** in `run_fits.py` via runtime monkey-patch:

```python
fish_growth_model.fit_alpha_spline = functools.partial(
    fish_growth_model.fit_alpha_spline, mode="forecasting"
)
```

(Patch is applied before any cycle is fit. MDF source is not modified.)

## Consequences

- **All 38 trial cages now have full daily coverage** across their trial windows. T2 pooled aggregates include all 14 books-clean T2 cages, not just the 10 with complete sampling.
- **The forecasted tail bakes in last-sample dynamics.** If a cage's α was elevated at its last sample (e.g. summer growth), it stays elevated through the forecast window. This is honest about the assumption (it's the most-recent measurement, projected forward) but is **not** an estimate of what actually happened — there are no measurements there.
- **The four affected cages get more weight in trial-pooled aggregates than they would under modelling mode.** Their pooled biomass is larger because they're contributing all 49 days, not only the days they actually have samples covering.
- **P6C10 specifically** — see [`glossary.md`](../../glossary.md) §P6C10 — gets a flat forecast (~0.04 %/day) consistent with its genuinely slow growth profile. The flatness is the "honest" answer, not an artefact.

## Alternatives considered

- **Stay on `modelling` and drop the 4 cages from T2 pooling.** Rejected — sacrifices the T2 cohort substantially (especially given T2 only has 7 weeks vs T1's 9, and the dropped cages skew toward treatment).
- **Linear extrapolation from the last sample.** Less principled than holding α; the spline α is what defines "the growth dynamics here", linear extrapolation in weight space ignores temperature dependence.
- **Use observed temperature in a fresh model evaluation past the last sample.** Possible but conflates "what would the model predict" (Model SGR) with "what is the realised trajectory" (Realised SGR). The forecasting mode preserves the separation — Realised SGR is the spline (with forecast); Model SGR is `growth_models.sgr(W, T)` evaluated daily.
- **Patch MDF source instead of monkey-patching.** Rejected — MDF is a shared sister repo with other consumers; this project should not impose its mode default on them. The runtime monkey-patch is local and explicit.
