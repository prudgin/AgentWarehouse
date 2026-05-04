# ADR-0003 — Harvest threshold convention: fraction of all fish

**Status**: accepted
**Date**: 2026-05-04

## Context

The headline number from this project is the DH at which a "small enough" fraction of fish still have feed in the intestine — the **harvest fasting period** (see `glossary.md`). "Small enough" has to be turned into a number, which requires picking both a percentage threshold (5 % is the working choice) and a denominator: 5 % of *what*?

Two conventions are equally defensible:

1. **% of all fish in the pond**, including fish that did not eat the most recent meal. Operationally meaningful: corresponds to the actual fraction of harvest weight that still carries gut content.
2. **% of fish that ate today's meal** (the eating fraction `c`). More biology-pure: removes the dilution from non-eaters and reports clearance kinetics on its own terms.

With observed eating fractions `c ≈ 0.7–0.87`, the two conventions give meaningfully different DH values. A 5 %-of-all-fish threshold corresponds to ≈ `5 / c` ≈ 6 % of eaters; conversely a 5 %-of-eaters threshold corresponds to ≈ `5 · c` ≈ 4 % of all fish. On the steeply-falling tail of the hump, that small percentage shift translates to a non-trivial DH shift.

## Decision

**Use convention (1): fraction of all fish, including non-eaters.** State the convention explicitly every time the threshold is reported.

The mathematical form: report DH such that `f_intestine(DH) = Q · c` on the decline side of the hump, for each Q in {0.50, 0.25, 0.10, 0.05, 0.01}. Multiplying by `c` is what makes Q a fraction of *all* fish (after the `c` multiplier inside `f`, the curve already represents fraction-of-all-fish; the `Q · c` form is from the spec's formulation where `c` was hoisted outside).

## Consequences

- The headline DH-at-5 % is an operational number: "if you fast for this long, ≤ 5 % of fish at harvest will have feed in the intestine". This is the question the farm actually asks.
- A reader looking at the same data with the eaters-only convention will get a smaller DH at 5 %. Reports must therefore name the convention prominently to prevent silent misuse.
- If `c` is later re-estimated (e.g. via the soft-constraint fit anticipated in `docs/domain/known-issues.md`) the headline DH-at-5 % will shift even on the same data. That shift is real and should be reported transparently — it is not a bug.
- The threshold percentage itself (5 %) is a separate decision, currently inherited as an industry convention. If a future trial argues for a different threshold (e.g. 1 %), this ADR's convention still applies; only the numeric Q changes.

## Alternatives considered

- **% of eaters only.** Rejected for headline use because it understates the operational fraction at harvest. Useful as a *secondary* number when comparing kinetics across ponds with different `c`; report both if the comparison matters.
- **% of fish-weight rather than fish-count.** Would weight by individual fish weight; defensible if there is large within-pond size heterogeneity, but currently the protocol samples 15 fish without per-fish weight resolution at the gut level. Deferred until per-fish weight is recorded alongside gut state.

## Provenance

- `docs/reference/model-spec.md` §"Derived quantities" — defines the threshold convention.
- `glossary.md` → DH at 5 % — the canonical entry naming this convention.
- `analysis/2026-04-16-warm-band-fit/REPORT.md` (planned) — first run reporting under this convention.
