# docs/adr/

Architecture Decision Records for the 2026 Juvenile gut evac trial. Each ADR captures a decision that passes the 3-of-3 admission test: hard to reverse, surprising without context, has a real trade-off.

For per-term definitions see [`../../glossary.md`](../../glossary.md). For the trial protocol these ADRs implement see [`../../Proposal/Bilbul_GER_trial_proposal.md`](../../Proposal/Bilbul_GER_trial_proposal.md).

## Index

- [`0001-t0-anchor-via-prefast-and-sentinel.md`](0001-t0-anchor-via-prefast-and-sentinel.md) — t=0 is anchored by a deliberate pre-trial fast with sentinel-fish validation, not opportunistic harvest-window sampling. The methodological departure from the sibling `2026 Gut Clearance` project.
- [`0002-normalisation-by-t0-batch-mean.md`](0002-normalisation-by-t0-batch-mean.md) — primary GER curve is `y_rel(t) = batch_dry(t) / batch_dry(0)`, with non-feeders cancelling in numerator and denominator. No per-fish feed/no-feed classification for the primary curve.
- [`0003-three-family-aic-kinetic-comparison.md`](0003-three-family-aic-kinetic-comparison.md) — per cohort, fit and compare exponential / square-root / power-Andersen by AIC rather than assuming first-order. K_local diagnostic as a structural cross-check.
