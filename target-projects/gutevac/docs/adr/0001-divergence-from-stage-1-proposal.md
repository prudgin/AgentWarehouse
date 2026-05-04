# ADR-0001 — Divergence from the Stage 1 proposal

**Status**: accepted
**Date**: 2026-05-04

## Context

The Stage 1 draft proposal (`docs/proposal/stage-1-2025-12-16.docx`, dated 16 December 2025) was written before the trial began. It proposed a three-temperature-band design (20–25 °C, 14–19 °C, 8–13 °C), four ponds per band, fixed sampling schedules totalling 105 fish per pond, and an analysis aimed at testing whether thermal-time transforms (DH, DH₀, Q10) collapse clearance curves across temperature bands.

Once the trial started, operational realities forced changes. The proposal also lacked specificity in places that became important — notably the gut-clearance endpoint and the analysis method — so the project filled those in as the work progressed.

## Decision

Treat the Stage 1 proposal as an **intention and rationale document, not an obligation**. The trial continues in the form it has actually been carried out. The proposal is preserved verbatim in `docs/proposal/` for audit trail; this ADR records what diverged and why, so future readers are not confused by the gap between the proposal and the artefacts that followed.

### Concrete divergences (proposal → reality)

| Aspect | Stage 1 proposal | Actual research |
|---|---|---|
| Temperature bands | Three: 20–25, 14–19, 8–13 °C | Only the warm band (17.1–27.8 °C) covered to date. Mid- and cold-band data are deferred. |
| Pond count | 4 ponds × 3 bands = 12 ponds | 4 ponds, all warm-band: MCF/P8C8, Whitton/P7C5, Whitton/P7C2, Whitton/P10C8. |
| Sampling intensity | 15 fish × 7 fixed timepoints = 105/pond | 15 fish × 5–8 ad-hoc timepoints per pond. |
| Endpoint | Vague: "segment-based presence/absence or scored fullness for stomach, midgut, hindgut". | Crystallised: proportion of fish with feed in stomach and in intestine. Plus opened-stomach categorisation (`% Today feed in stomach`, `% old feed in stomach` — by pellet count). |
| Analysis goal | Test whether DH / DH₀ / Q10 transforms collapse curves across temperature bands. | Fit a single pooled hump shape across the warm-band ponds, with per-pond eating fraction `c`. Thermal-time invariance is untestable without cold-band data. |
| Method | Not specified beyond "fit clearance curves". | Two-meal hump model (today + yesterday's residual combined via independence), binomial likelihood throughout, parametric bootstrap CIs. See `docs/reference/model-spec.md`. |

## Consequences

- The proposal's primary scientific question — *do clearance curves collapse under thermal-time transforms?* — remains open. It can be revisited only when cold-band data is collected (see `docs/planning/future-work.md`).
- The headline number from the warm-band trial (DH at 5% intestine clearance ≈ 1218, 95% CI [1072, 1351], ≈ 61 h at 20 °C) is reportable on its own merits, with the caveat that it does not extrapolate outside the 17–27 °C range.
- Future readers comparing the proposal to the report will be directed here for the reconciliation.
- This ADR explicitly does **not** constrain future trial design. New trials may continue to depart from the proposal as operational realities require; record substantive new departures as further ADRs.

## Provenance

- Proposal source: `docs/proposal/stage-1-2025-12-16.docx`.
- Reality source: `docs/reference/model-spec.md` (operative spec) and the first production analysis whose outputs are in `output/` and `reports/`.
- Note: this project predates the analyse-chain skill set, so there is no `analysis/<date>-<topic>/REPORT.md` to link as canonical provenance for the warm-band run. Future analyses (cold-band trial, refits) will follow the dated-dir convention.
