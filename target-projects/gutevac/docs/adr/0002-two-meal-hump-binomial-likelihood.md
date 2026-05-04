# ADR-0002 — Two-meal hump with standard binomial likelihood

**Status**: accepted
**Date**: 2026-05-04

## Context

The clearance-curve model has to predict, at any DH since the last feed, the proportion of fish whose stomach (or intestine) contains feed. Two structural realities shape the choice:

1. Fish that ate today still carry yesterday's residual at sampling time. A model that ignores this systematically overstates clearance because some "feed in stomach" hits are actually old feed from the previous meal, not today's.
2. Many observations are at DH where the predicted proportion is near zero, producing several `k = 0` rows. A naive likelihood can let those rows pull the tail of the curve flat in ways that are unphysical.

Earlier preliminary analyses (preserved in `archive/old analysis/`) used a single sigmoid for stomach decline and explored an asymmetric likelihood for `k = 0` rows to prevent a "long fat tail" pathology. Those approaches were superseded.

## Decision

**Model.** Per-meal intestinal contribution: `f(DH) = c · (σ_arr(DH) − σ_clr(DH))`. Per-meal stomach contribution: `g(DH) = c · (1 − σ_emp(DH))`. Each row's predicted observable combines today's meal and yesterday's residual under independence:

    P_obs = 1 − (1 − f(d_t)) · (1 − f(d_t + d_y))

with `d_y = T_pond_mean × 24` standing in for yesterday's-meal age in DH. The same combination applies to `g`.

**Likelihood.** Standard binomial throughout — both stomach and intestine fits, all rows including those with `k = 0`. No asymmetric handling of zeros.

The rationale for binomial-throughout is that the hump model's structural constraints already prevent the long-fat-tail pathology that motivated asymmetric likelihood for the older single-sigmoid fits: the tail shape is governed by `m_clr` and `w_clr`, which must also fit the rise and middle of the hump, so the tail cannot go arbitrarily flat without distorting the rest of the curve.

**Fit procedure.** Two independent fits in order — stomach first to pin `m_emp`, `w_emp`; then intestine for `m_arr`, `w_arr`, `m_clr`, `w_clr`. Differential evolution for global search, Nelder-Mead for polish. Per-pond `c` is fixed input from `% Today feed in stomach` at t=0, not fitted (see `docs/reference/model-spec.md`).

## Consequences

- Yesterday's residual is reasoned about explicitly. The two-meal combination must be applied uniformly to all rows including t=0; do not special-case t=0 (see `glossary.md` → t=0 row).
- Zero-observation rows enter the likelihood like any other row. Code complexity stays low; the structural constraint of the hump does the work that asymmetric likelihood was trying to do.
- The model is poorly identified in two directions, both flagged in `docs/domain/known-issues.md`:
  - Arrival sigmoid (`m_arr`, `w_arr`) tends to drive `w_arr` toward its lower bound; arrival kinetics are not biologically reportable from this fit.
  - Eating fraction `c` is probably underestimated because fast-clearing eaters look like non-eaters at sampling. Reasonable next step: let `c` be fitted with t=0 stomach data as a soft constraint.
- The independence assumption (today's and yesterday's meal contributions are independent on the same fish) is not formally tested. Plausible failure mode is positive within-fish correlation (a fast-emptying fish empties both meals fast); this would tighten the predicted distribution relative to what we model, but does not bias the central tendencies. Note in any report.

## Alternatives considered

- **Single sigmoid for decline, no two-meal combination.** What the earlier preliminary analyses used. Cleanly fits the decline but cannot explain the early-DH peak when yesterday's residual is still present, and cannot use t=0 data at all. Rejected.
- **Asymmetric likelihood for `k = 0` rows.** Considered for the single-sigmoid fits and inherited as a candidate. Rejected for the hump model on the structural-constraint argument above; the spec records the reasoning in §"On zero observations".
- **Hierarchical / random-effects model on `m_clr` per pond.** Defensible once more ponds (especially across temperature bands) arrive. With the current 4-pond warm-band-only dataset there is no statistical power for pond-level random effects; deferred.
- **Bayesian fit with priors.** Reasonable; not necessary for the headline result, which already has parametric-bootstrap CIs that propagate the data-driven uncertainty without prior choices to defend.

## Provenance

- `docs/reference/model-spec.md` — operative spec including the `On zero observations` section.
- `archive/old analysis/` — superseded methods (`method_a_peasant`, `method_b_hump`, `gut_clearance_final.py`).
- `analysis/2026-04-16-warm-band-fit/REPORT.md` (planned, retrofit) — the first production run under this method.
