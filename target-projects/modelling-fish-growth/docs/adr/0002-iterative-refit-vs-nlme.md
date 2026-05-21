# ADR-0002: Iterative per-cycle refit instead of a joint NLME-ODE fit

- **Status:** accepted
- **Date:** 2026-05-21
- **Provenance:** `idea.md` §Process, §Open questions; `docs/literature_review.md` §2.

## Context

Two structurally different ways to fit `SGR(T, W)` to operational pond data:

1. **Iterative per-cycle refit (this project).** Initialise a population surface; for each cycle fit a per-cycle deviation α (constant, then spline α(t)); back out a smooth daily W(t) per cycle; aggregate daily `(T, W, SGR)` triples with per-day quality weights; refit the surface coefficients on the weighted aggregate; iterate to convergence.
2. **Joint NonLinear Mixed-Effects ODE fit (NLME).** State a hierarchical Bayesian model with population-level surface coefficients (fixed effects), per-cycle α-like random effects, measurement error on weight samples (and optionally on restocking counts), and let an MCMC or variational scheme fit all of it together. Tools: nlmixr2 (R), Stan / NumPyro / PyMC.

Both approaches address the core problem: pairwise SGR between two weight samples spans months during which both T and W move, so pairwise SGR can't honestly be pinned to any single `(T, W)` point. The mechanism differs:

- Iterative refit handles this by *separating* the population surface from per-cycle deviation and re-attributing daily contributions via the spline α(t).
- NLME handles it by *joint inference* — the model integrates the ODE through each cycle and the random effects absorb cycle-specific deviation automatically.

## Decision

Use the **iterative per-cycle refit** for the first milestone of this project. Defer the joint NLME-ODE fit to future-work as a cross-validation pass once the iterative approach produces a transparent baseline.

## Alternatives considered

1. **Joint NLME-ODE from day one.** Cleanest statistical story (everything shrinks naturally, measurement error handled, identifiability surfaces explicitly in posteriors). Rejected for now: heavy implementation cost (Stan/NumPyro fluency, prior elicitation, sampler tuning), opaque debugging surface (a posterior is harder to sanity-check than a coefficient table per iteration), and no transparent baseline to validate the NLME against. Methodologically more elegant; pragmatically the wrong first step.
2. **Free-form 3D smoother on raw pairwise SGRs.** Was the original plan (per `idea.md` §"What changed vs the original idea"). Rejected: pairwise SGR over months can't honestly be pinned to a single `(T, W)`, and a free-form smoother absorbs cycle-specific deviation into the surface.
3. **Glencross-style block aggregation with no per-cycle deviation.** What Glencross actually did (geometric-mean weight per block, then nonlinear regression). Rejected: throws away the per-cycle structure that explains a lot of operational variance and obscures the surface in the process.

## Consequences

- The iterative scheme gives intermediate, inspectable artefacts (surface coefficients per iteration, α(t) per cycle, residual heat maps) — important for sanity-checking and for the user's working style on this project.
- Convergence is tracked as RMS surface change across a `(T, W)` grid (`idea.md` §Step 4). Damping (e.g. `new = 0.5·old + 0.5·refit`) used if oscillation rather than convergence is observed.
- Per-day quality weights (`idea.md` §Step 2) explicitly down-weight extrapolated days, replacing the automatic shrinkage an NLME fit would provide.
- Identifiability watch: α(t) must be flexible enough to absorb cycle-specific deviation but not so flexible that it eats the surface itself.
- The eventual NLME validation (`docs/planning/future-work.md`) will compare population-level Glencross coefficients and per-cycle α distributions across the two methods.

## References

- `idea.md` §"What changed vs the original idea", §Open questions.
- `docs/literature_review.md` §2 — closest precedents (Mayer/Estruch, Dumas critique). The deviation-spline + iterative-refit combination is methodologically novel.
- Helser & Lai (2004), *Ecological Modelling* 178 — Bayesian hierarchical fish-growth meta-analysis (closest NLME-style precedent in this domain).
