# ADR-0005: Per-cycle loss uses log-space residuals on weight

- **Status:** accepted
- **Date:** 2026-05-21
- **Provenance:** `idea.md` §Step 1 "Loss function".

## Context

The per-cycle α fit (ADR-0003) compares the predicted weight trajectory `W_pred(t)` to observed weight samples `W_obs(tᵢ)` at sample times. The loss function choice — what residual we minimise — has direct downstream effects on how the optimiser treats large vs small fish:

- **Raw-weight residuals:** `Σᵢ (W_pred(tᵢ) − W_obs(tᵢ))²`. Treats a 100 g error on a 5000 g fish the same as a 100 g error on a 100 g fish.
- **Log-weight residuals:** `Σᵢ (ln W_pred(tᵢ) − ln W_obs(tᵢ))²`. Treats a relative error (e.g. 5%) consistently across the weight range.
- **Relative-error residuals:** `Σᵢ ((W_pred − W_obs) / W_obs)²`. Mathematically close to log residuals in the small-error limit.

Operational weight samples are noisy in a way that scales with size: weighing 5 fish from a 5000 g pond and computing a mean has higher absolute variance than the same procedure on 100 g fish, but the *relative* variance is similar. Growth itself is multiplicative (the daily step `W·(1 + αSGR/100)^Δt` compounds), so residuals in log space are also the natural fit-space for the underlying process.

## Decision

Per-cycle loss uses **log-space residuals on weight**:

```
loss(α | cycle) = Σᵢ (ln W_pred(tᵢ; α) − ln W_obs(tᵢ))² · w_data(tᵢ)
```

where `w_data(tᵢ)` is the sample's data weight (1 by default; could later carry inverse-variance weights if sample-uncertainty estimates become available).

## Alternatives considered

1. **Raw-weight residuals.** Simpler. Rejected: weights a 100 g error at harvest (~5 kg fish) far less than a 100 g error at stocking (~100 g fish), even though those are very different signals.
2. **Relative-error residuals: `((W_pred − W_obs)/W_obs)²`.** Mathematically very close to log residuals in the small-error limit but ill-behaved as `W_obs → 0` and skewed for large positive/negative errors. Rejected as a worse parameterisation of the same idea.
3. **Heteroscedastic Gaussian likelihood with size-dependent variance.** A more principled version of the same idea, but requires estimating the variance model. Rejected as overkill for stage 1; might revisit in the NLME validation pass (ADR-0002 future-work).

## Consequences

- The optimiser sees each sample's contribution scaled by `1/W_obs²` (in the small-residual limit) — small fish at stocking carry roughly the same weight as large fish at harvest. Aligns with how cycle data is informative.
- Combines naturally with the multiplicative daily step: `ln W(t)` evolves additively under the daily step in the small-rate limit, so log-residuals are linear in the integrated α·SGR signal.
- Per-day quality weights (ADR pending; see `idea.md` §Step 2) layer on top: they scale daily *triples* in the surface refit (Step 3), not the per-cycle loss directly. Different mechanism, different stage.
- If sample-uncertainty estimates ever become available (e.g. n_fish_weighed per sample), the loss becomes `Σᵢ (ln W_pred − ln W_obs)² / σ²ᵢ` with `σᵢ ∝ 1/√n` — a drop-in extension.

## References

- `idea.md` §Step 1 "Loss function".
- `docs/sgr_conventions.md` — the multiplicative daily step that makes log-space the natural fit-space.
