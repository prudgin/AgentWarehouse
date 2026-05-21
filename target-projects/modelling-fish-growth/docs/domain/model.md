# Model — per-cycle iterative `SGR(T, W)` refit

Methodology reference. Distilled from `docs/design/initial-idea.md` (frozen historical version) so it can evolve as the work proceeds. Companion docs: `sgr-conventions.md` (formula hygiene, units, Glencross coefficient tables) and `literature-review.md` (alternative forms, prior Murray cod work).

Load-bearing methodological choices are recorded as ADRs ([0001](../adr/0001-canonical-surface-lives-in-growth-models.md), [0002](../adr/0002-iterative-refit-vs-nlme.md), [0003](../adr/0003-per-cycle-alpha-structure.md), [0004](../adr/0004-glencross-2012-starting-form.md), [0005](../adr/0005-log-space-residuals.md)). This doc summarises *how* — the ADRs record *why*.

## Goal

Fit `SGR(T, W)` (and downstream SFR, FCR) from **operational** pond data — sparse noisy weight samples, feed records, harvest yields. Not a biological / bioenergetic FCR model (Glencross-style DE/DP requirements); a **farm-realised** empirical fit with operational noise baked in: **black loss**, **waste feed**, **weighting error** (see `../../glossary.md`).

The hard part: pairwise SGR between two weight samples can span months during which both `T` and `W` move, so a pairwise SGR can't honestly be pinned to any single `(T, W)`. The iterative refit separates the **population surface** from per-cycle deviation **α** (see ADR-0003).

Target species: **Murray cod (Maccullochella peelii)**. First milestone: a converged `SGR(T, W)` surface refit to Murray cod operational data.

## Process (one **iteration round**)

### Step 0 — Initial / current surface

Round 1 initialises `SGR(T, W)` from the **Glencross-2012** form with barramundi coefficients as starting shape (ADR-0004). Round N starts from round N-1's converged surface. The surface returns `%·d⁻¹`.

```
SGR(T, W) [%·d⁻¹] = (K + xT + yT² + zT³) · W^(aT + b − 1)
```

Pairwise SGR from consecutive weight samples is **not** used to fit the starting surface. It's plotted against the current surface as a sanity check; systematic mismatch in some `(T, W)` region is a flag, not a refit signal.

Cross-validation baselines (**Björnsson-Steinarsson**, **Brière-2**, **Sharpe-Schoolfield high-only**) are fitted to the same daily triples once Step 3 has produced them — see ADR-0004.

### Step 1 — Per-cycle α fit

For each cycle, integrate the **daily step** day by day:

```
W_{i+1} = W_i · (1 + α · SGR(T_i, W_i) / 100)^Δt
```

with `α` constant in stage 1 and `α(t)` (cubic B-spline, 3–5 knots, curvature penalty) in stage 2 (ADR-0003).

**Restocking jumps** are applied after the day's growth step:

```
W(t⁺) = (N_old · W(t⁻) + N_added · W_added) / (N_old + N_added)
N(t⁺) = N_old + N_added
```

`N(t)` is tracked alongside `W(t)` (needed for downstream SFR).

**Loss:** log-space residuals on weight (ADR-0005):

```
loss(α | cycle) = Σᵢ (ln W_pred(tᵢ; α) − ln W_obs(tᵢ))²
```

**Two-stage warm-up:** stage 1 constant α first (stable, robust), stage 2 spline α(t) initialised at the stage-1 scalar.

### Step 2 — Per-day quality weights

For each day of each cycle, compute `w(t)` — a kernel sum over time-distances to nearest weight samples in that cycle:

```
w(t) ∝ Σᵢ exp(−(t − tᵢ)² / 2σ²)
```

σ on the order of a typical inter-sample gap. `w(t)` attaches to every daily `(T, W, SGR)` triple produced and is the explicit mechanism that down-weights extrapolated days. Days near samples speak louder than extrapolated days; cycles with overall sparse sampling contribute less than dense cycles.

Also attach **cycle quality flags** for filtering later (see `../../glossary.md`): total sample count, average and max inter-sample gap, presence/absence of harvest endpoint anchor.

### Step 3 — Re-bin and refit

With smooth `W(t)` for every day of every cycle, daily SGR is defined.

1. Bin the `(T, W)` plane.
2. Within each bin, aggregate using per-day weights from Step 2: weighted mean for the SGR value; sum of weights as the bin's **effective sample size**.
3. Refit the Glencross coefficients (K, x, y, z, a, b) using **weighted regression** with the bin's effective sample size as regression weight.

Sanity-check refit against the previous round's coefficients — large jumps signal instability and warrant looking at the data, not just accepting the move.

### Step 4 — Iterate

Feed the refit surface back into Step 1.

**Convergence:** RMS difference of predicted SGR across a `(T, W)` grid covering the operational range. Stop when below threshold.

**Oscillation watch:** if successive rounds oscillate, dampen the update (e.g. `new = 0.5·old + 0.5·refit`).

### Step 5 — Downstream SFR and FCR

Once `W(t)` and `N(t)` are smooth daily series, biomass `B(t) = N(t)·W(t)` is daily. Feed records give daily feed `F(t)`.

```
SFR(t) = F(t) / B(t)
FCR(t) = F(t) / (B(t) · SGR(t)) = SFR(t) / SGR(t)
```

Bin SFR over `(T, W)` the same way as SGR; refit a parametric form or a regularised free surface. FCR derived from the two surfaces; cross-check against pond-level realised FCR.

## Diagnostics

Binning is not load-bearing for the fit (the parametric refit could be done on daily triples directly), but stays valuable as diagnostic:

- Heat maps of residuals across `(T, W)` → where Glencross's shape is wrong for Murray cod.
- Heat maps of bin counts / total weight → where the model is extrapolating.
- Per-cycle α(t) plots → outlier cycles, systematic patterns (e.g. mid-cycle dip → density effect).
- Iteration-to-iteration coefficient tracking → convergence behaviour.

## Boundaries

- **In scope (first milestone):** the surface refit, per-cycle α machinery, convergence behaviour, diagnostic surfaces, the iterative fitter as a callable in `src/modelling_fish_growth/`.
- **Out of scope (first milestone):** representative-cycle selection (deferred — needs water-quality, disease, treatment data — see `../planning/future-work.md`), per-cycle covariate regression on α, joint NLME-ODE validation (see ADR-0002), measurement-error / temperature-uncertainty handling.
- **Hand-off:** converged surface coefficients flow to `~/PycharmProjects/GrowthModels` (ADR-0001). Handoff format TBD — see `_warehouse/intake-notes.md` if this is still open.

## Provenance

- `docs/design/initial-idea.md` — frozen 2026-05 design doc this model.md was distilled from. Read for the narrative including "what changed vs the original idea".
- `docs/domain/sgr-conventions.md` — formula hygiene + Glencross coefficient tables.
- `docs/domain/literature-review.md` — alternative parametric forms, prior Murray cod work, cycle-filtering context.
- ADRs 0001–0005.
