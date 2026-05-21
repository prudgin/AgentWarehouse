# ADR-0003: Per-cycle α as a multiplicative deviation on the percent rate, with stage 1 scalar and stage 2 spline α(t)

- **Status:** accepted
- **Date:** 2026-05-21
- **Provenance:** `idea.md` §Step 1; `docs/sgr_conventions.md` §"Per-cycle α".

## Context

The iterative refit (see ADR-0002) needs a per-cycle deviation parameter that lets each cycle deviate from the population surface without contaminating the surface itself. Three orthogonal choices:

1. **What does α multiply?** The percent rate `SGR(T, W)` (in `%·d⁻¹`), or the log-rate `g = (ln W₂ − ln W₁)/Δt` (in `d⁻¹`)?
2. **Constant or time-varying?** A single scalar α per cycle, or a smooth function α(t)?
3. **If time-varying, what parameterisation?** Spline with N knots; what curvature penalty?

This choice is load-bearing: every cycle's optimisation, the daily-step formula, the iterative refit, and the surface package's `growth_models.sgr` callable all share the same α composition rule. Diverging here divides the codebase.

## Decision

- **α multiplies the percent rate.** `SGR_effective(T, W) = α · SGR(T, W)`. Daily step: `W_{i+1} = W_i · (1 + α · SGR(T_i, W_i) / 100)^Δt`. Same convention as `~/PycharmProjects/FishGrowthFittingSGRpackage` (`alpha`, `simulation.py` line 320: `growth_factor = (sgr/100 + 1) ** delta_days`).
- **Two-stage fit per cycle.**
  - **Stage 1: constant α.** Single scalar per cycle. Stable, robust, baseline.
  - **Stage 2: spline α(t).** Cubic B-spline initialised at the stage-1 scalar, re-optimised with a curvature / second-difference penalty. 3–5 knots to start; add knots only if residuals demand it.
- **α = 1 = unmodified biology.** Convention.
- **Optimiser space.** `log_alpha = log(α)` (a log-space reparameterisation for the optimiser, matching the fitting package). The physical α still multiplies SGR linearly.

## Alternatives considered

1. **α multiplies the log-rate `g`.** Composition `SGR_effective = 100·(exp(α·g) − 1)`. Mathematically equivalent in the small-α limit but diverges for non-trivial deviations, and breaks the daily-step formula's clean form. Rejected: would force a different daily step than the fitting package, fragmenting the convention across this project, `FishGrowthFittingSGRpackage`, and `growth_models`.
2. **Additive α: `SGR_effective = SGR + α`.** Loses the multiplicative-noise structure (a +0.1 deviation means very different things at 0.5 %·d⁻¹ vs 2 %·d⁻¹). Rejected.
3. **Free α(t) with no constant-α warm-up.** Optimisation surface is much harder; spline coefficients are not identifiable without a sensible initialisation. Rejected on practical grounds: the constant-α stage is cheap and gives the spline a good starting point.
4. **Per-cycle covariate model directly (α as a regression on feed/density/disease).** The covariate model is real future-work but requires per-cycle metadata that doesn't exist as structured data yet. Rejected for now; α(t) is the placeholder for "we don't yet know which covariates explain the deviation".

## Consequences

- The daily step is identical to `FishGrowthFittingSGRpackage`'s `simulation.py` loop. No re-implementation needed; the fitter can be called directly.
- The convention `α=1 = unmodified biology` lets `α<1`, `α>1` read as "slower than the surface predicts", "faster than" — directly interpretable when the user looks at per-cycle plots.
- The curvature penalty in stage 2 is the lever that prevents α(t) from absorbing population-level shape. **Identifiability watch:** if α(t) starts absorbing structure that should live in the surface, the curvature penalty needs tightening or fewer knots.
- The `0.0067 %·d⁻¹` biological floor on SGR (enforced inside `growth_models.sgr`) interacts with α: `α·0` is still `0`, so if the surface returns the floor, α has no power to push growth below the floor. This is intentional.
- Outlier cycles surface as `α` far from 1 or `α(t)` with strong systematic patterns (e.g. mid-cycle dips signalling density effects). This is a *diagnostic*, not a failure mode.

## References

- `idea.md` §Step 1 — two-stage warm-up, identifiability watch.
- `docs/sgr_conventions.md` §"Per-cycle α" — formula, sign convention, mapping to the fitting package.
- `~/PycharmProjects/FishGrowthFittingSGRpackage/src/.../simulation.py` — canonical implementation of the daily step with α.
