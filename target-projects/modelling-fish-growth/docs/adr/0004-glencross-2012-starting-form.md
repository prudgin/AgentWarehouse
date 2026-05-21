# ADR-0004: Glencross-2012 as the starting parametric form for `SGR(T, W)`

- **Status:** accepted
- **Date:** 2026-05-21
- **Provenance:** `idea.md` §Step 0; `docs/sgr_conventions.md` §"Glencross — starting shape for the surface"; `docs/literature_review.md` §3.

## Context

The iterative refit (ADR-0002) needs an initial population surface to start from. Three classes of choice:

- **Free-form smoother** (3D GP, thin-plate spline, MARS, ...). Maximum flexibility, no biological prior, identifiability disaster with sparse Murray cod data.
- **Parametric forms with thermal asymmetry** — capture both the rising and falling limbs of the thermal response. Glencross-2008/2012, Björnsson-Steinarsson (BS), Brière-2, Sharpe-Schoolfield (SS).
- **Monotonic-in-T forms** — TGC family (Iwama-Tautz 1981, Cho-Bureau, Lupatsch-Kissil). Linear or power-law in T, no post-optimum decline. Wrong shape for our biology.

The right choice has to:

- Carry post-optimum decline (Murray cod growth drops sharply above ~25 °C; industry guidance: optimum 24–25 °C, brief tolerance up to 30 °C).
- Have an allometric piece (`W^k` or `W^(aT+b)`) — bigger fish grow at a lower specific rate.
- Be identifiable from sparse operational data.
- Match what already exists in `growth_models.sgr` (currently barramundi Glencross coefficients).

## Decision

Start the iterative refit from the **Glencross & Bermudes (2012)** form:

```
SGR(T, W) [%·d⁻¹] = (K + xT + yT² + zT³) · W^(aT + b − 1)
```

- 6 parameters: K, x, y, z, a, b.
- Cubic-in-T thermal kernel (both lower and upper decline).
- T-dependent allometric exponent — captures the empirical fact that larger fish lose more growth at high T than small fish.
- Initialise coefficients from Glencross's barramundi fit (`docs/sgr_conventions.md`); magnitudes will be wrong (barramundi is tropical, Murray cod is temperate). Refit from iteration 1.

**Fallback:** Glencross-2008 (fixed `k` instead of `aT + b`) if identifiability is poor with sparse Murray cod data.

**Cross-validation baselines** (carried alongside the primary form, not replacing it):

- **Björnsson-Steinarsson** — closest direct family; quadratic in T with T-dependent log-W slope; 5 parameters.
- **Brière-2** — slim asymmetric T kernel × W^k; 4 parameters on T axis; biologically clean hard-zero at T_max.
- **Sharpe-Schoolfield high-only** — mechanistic enzyme-deactivation kernel × W^k; most defensible thermal kernel for an ectotherm; identifiability risk with sparse data.

## Alternatives considered

1. **Glencross-2008 (fixed `k`) as primary.** 5 parameters, simpler. Loses the size-dependent thermal optimum — the size effect ends up either ignored or absorbed by α(t). Rejected as primary; kept as fallback.
2. **Free-form 3D smoother.** Already rejected in ADR-0002 for the same identifiability + cycle-deviation-absorption reasons.
3. **Björnsson-Steinarsson as primary.** Same family, one order lower in T. Tempting on parsimony grounds; carry as cross-validation baseline instead. Switching the primary form mid-project is heavy enough that we want one consistent reference until it demonstrably underperforms.
4. **Sharpe-Schoolfield as primary.** Most mechanistically defensible thermal kernel. Rejected for now: identifiability with sparse operational data is the dominant risk, and SS has Arrhenius-style parameters (Ea, Eh, Th) that are hard to recover from noisy farm data alone.

## Consequences

- Glencross's published barramundi coefficients are used **only as initial shape**. Murray cod magnitudes will move: optimum from ~30 °C → ~24–25 °C, narrower thermal window, different K-magnitude. Sanity-check refit-to-iteration coefficient drift (`idea.md` §Step 3) catches pathological moves.
- Pairwise SGR from consecutive weight samples is **not** used to fit the starting surface (it spans months of moving T/W). It's plotted against the Glencross shape as a sanity check; systematic mismatch in some `(T, W)` region is a flag, not a refit signal.
- Cross-validation against BS / Brière-2 / SS-high happens **after** the primary form has produced a converged surface — the alternatives are fitted to the same daily `(T, W, SGR, weight)` triples Step 3 produces. Substantial disagreement between primary and alternatives is a signal that identifiability is the limiting factor, not the form.
- The choice of starting form determines the shape of `growth_models.sgr_murray_cod` (ADR-0001). A future change of primary form will be a breaking change downstream.

## References

- Glencross, B.D. & Bermudes, M. (2012). *Aquaculture Nutrition* 18: 411–422.
- Glencross, B.D. (2008). *Aquaculture Nutrition* 14: 360–373.
- Björnsson, B., Steinarsson, A. & Árnason, T. (2007). *Aquaculture* 271: 216–226.
- Brière, J.F. et al. (1999). *Environmental Entomology* 28: 22–29.
- Schoolfield, R.M., Sharpe, P.J.H. & Magnuson, C.E. (1981). *J. Theor. Biol.* 88: 719–731.
- `docs/sgr_conventions.md` (in source repo) — coefficient tables and recast.
- `docs/literature_review.md` §3 — parametric forms compared.
