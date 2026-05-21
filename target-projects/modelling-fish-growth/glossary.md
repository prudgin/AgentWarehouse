# Glossary — modelling-fish-growth

Project-specific vocabulary for the Murray cod SGR(T, W) modelling project. One canonical term per concept; synonyms listed as "Avoid". General programming or aquaculture concepts only appear here when this project uses them in a specific sense.

## Format rules

- One sentence per definition. Define what it IS, not what it does.
- Bold related term names; express cardinality where obvious.
- "Avoid" lists synonyms that should not appear in code, docs, or commit messages.
- Findings-provenance rule (per the analysis template): claims promoted from an investigation cite the `analysis/<dated>/INVESTIGATION.md` that produced them.

## SGR conventions

### SGR

Specific Growth Rate, in `%·d⁻¹`. The Crane-correct percent change in weight per day. Computed from two weight samples as `SGR = 100·(exp(g) − 1)` where `g = (ln W₂ − ln W₁)/Δt`. All surfaces, all per-cycle parameters, and the daily step live in SGR space — never in `100·g` (the Crane et al. (2020) misuse).

_Avoid_: `100·g`, log-rate-as-SGR, bare-percent SGR (always report units `%·d⁻¹`).

_Provenance_: `docs/domain/sgr-conventions.md` (ported from source `docs/sgr_conventions.md`).

### `g` (log-rate)

Instantaneous log-scale growth rate per day, `g = (ln W₂ − ln W₁)/Δt`, units `d⁻¹`. Used as an intermediate when computing **SGR** from pairwise weight samples; not used as the working quantity anywhere else.

_Avoid_: Treating `100·g` as SGR.

### Daily step

The discrete weight-update formula `W_{i+1} = W_i · (1 + α · SGR(T_i, W_i) / 100)^Δt`. Identical to `FishGrowthFittingSGRpackage/simulation.py`'s loop. See ADR-0003.

### α (per-cycle deviation)

A dimensionless multiplicative scalar (stage 1) or smooth function α(t) (stage 2) that scales the **SGR** for one cycle: `SGR_effective = α · SGR`. α=1 ↔ unmodified biology; α>1 grew faster than the surface predicts, α<1 slower. See ADR-0003. The optimiser uses `log_alpha = log(α)`.

_Avoid_: Multiplying `g` instead of `SGR` (different daily step), additive deviation `SGR + α` (loses multiplicative-noise structure).

## Surfaces and forms

### Population surface

The fitted `SGR(T, W)` function returning `%·d⁻¹`, refit at each iteration of the iterative loop. Lives canonically in `growth_models.sgr` (ADR-0001); intermediate / candidate surfaces during an active fitting round live in this project.

_Avoid_: "The model" (too generic — this project produces several intermediates).

### Glencross-2012 form

`SGR(T, W) = (K + xT + yT² + zT³) · W^(aT + b − 1)`. The starting parametric shape; coefficients refit from Murray cod operational data. 6 parameters. See ADR-0004 and `docs/domain/sgr-conventions.md`.

_Avoid_: "Glencross model" (ambiguous between 2008 fixed-`k` and 2012 T-dependent forms — always specify the year).

### Cross-validation baselines

Three alternative `SGR(T, W)` parametric forms fitted alongside Glencross-2012 once the primary refit has converged: **Björnsson-Steinarsson** (5 params, quadratic T), **Brière-2** (4-param T kernel × W^k), **Sharpe-Schoolfield high-only** (mechanistic Arrhenius-style T kernel × W^k). Substantial disagreement signals identifiability is the limiting factor, not the form.

_Provenance_: `docs/literature_review.md` §3.

## Per-cycle structure

### Growth cycle (cycle)

The production period for one pond, from a stocking event to the harvest event (or end of observation). Carries: weight samples, temperature time-series, feed records, count `N(t)`, restocking events, harvest yield, **cycle quality flags**.

_Avoid_: Run, batch (overloaded with farm operations vocabulary).

### Restocking jump

A discrete biomass-conserving event applied after the daily growth step: `W(t⁺) = (N_old·W(t⁻) + N_added·W_added)/(N_old + N_added)`, `N(t⁺) = N_old + N_added`. Not part of the daily step itself.

### Cycle quality flag

Per-cycle metadata used for filtering and weighting: total weight-sample count, average inter-sample gap, max inter-sample gap, presence/absence of a harvest weight as endpoint anchor. Distinct from **per-day quality weight** (which is finer-grained, per-day).

### Per-day quality weight

A scalar `w(t)` for each day of each cycle indicating how informed the fit is at that day — a kernel sum over time-distances to nearest weight samples in that cycle. Attached to every daily `(T, W, SGR)` triple and carried into the surface refit (Step 3) as the bin's effective sample size. This is the explicit mechanism that down-weights extrapolated days.

_Avoid_: "Sample weight" (overloaded with regression-weight terminology).

### Representative cycle

A cycle judged usable for population-level surface fit — i.e. free of confounding events (disease, treatment, hypoxia) that would make its α absorb effects that shouldn't be in the surface. Selection criteria are explicitly out of scope for the first milestone (see `docs/planning/future-work.md`); will eventually need water-quality, disease-incidence, treatment-window, and stocking-density data.

_Provenance_: `idea.md` §Scope; `docs/literature_review.md` §4.

## Iteration

### Iteration round

One pass through the five-step process: per-cycle α fit → smooth daily W(t) → per-day weights → re-bin and refit Glencross coefficients → convergence check. Successive rounds feed the refit surface back as the new starting surface.

### Convergence

Surface-to-surface change between rounds, measured as RMS difference of predicted SGR across a grid of `(T, W)` points covering the operational range. Stop when below threshold. **Watch for oscillation** rather than convergence — dampen the update if it appears (`new = 0.5·old + 0.5·refit`).

## Operational vocabulary

### Black loss

Chronic unaccounted disappearance of fish between samplings — mortality, cannibalism, escapes, miscounts. Not a named term in the formal aquaculture literature (per `docs/literature_review.md` §4); defined in this project as the catch-all for the gap between expected and observed `N` at the next sampling. Distinct from **waste feed** (uneaten / leached pellets) and **weighting error** (uncertainty in how much feed actually reached the fish vs the pond).

_Provenance_: `idea.md` §Scope; `docs/literature_review.md` §4 (flagged as unnamed in literature).

### Waste feed

Uneaten pellets and feed leached into the pond water column before consumption. Baked into the empirical FCR (see **farm-realised FCR**); not modelled separately.

### Weighting error

Uncertainty in the difference between feed delivered to the pond vs feed actually consumed by the fish (scoop variance, spill, water content). Baked into the empirical FCR; not modelled separately.

### Farm-realised FCR

The empirical Feed Conversion Ratio as the farm measures it — total feed consumed divided by total biomass gained, with all of **black loss**, **waste feed**, and **weighting error** baked in. Distinct from a bioenergetic FCR (DE/DP-based) which is **not** what this project fits.

_Avoid_: "FCR" alone (always specify farm-realised vs bioenergetic).

### SFR

Specific Feeding Rate, `F(t) / B(t)` — daily feed divided by standing biomass `B = N·W`. Units `kg·kg⁻¹·d⁻¹` or `%·d⁻¹` depending on context.

## Project structure

### Companion package — `growth_models`

The sibling Python package at `~/PycharmProjects/GrowthModels` that owns the canonical `SGR(T, W)` callable, the `0.0067 %·d⁻¹` biological floor, and the formula conventions. This project consumes `growth_models.sgr` and writes its converged surface back to this package (ADR-0001).

### Companion package — `FishGrowthFittingSGRpackage`

The sibling Python package at `~/PycharmProjects/FishGrowthFittingSGRpackage` that owns the per-cycle fitter — `alpha` / `log_alpha`, `SplineFit` (for stage 2), `simulation.py` (daily step + restocking aggregation). This project consumes the fitter directly.

_Avoid_: "The fitter" alone (ambiguous between this project's iterative-refit driver and the per-cycle fitter inside this package).
