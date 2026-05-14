# ADR-0001 — Trajectory-anchored endpoint SGR

**Status**: accepted.
**Date**: 2026-05-07 (decision); 2026-05-14 (ADR captured).
**Provenance**: `docs/decisions_log.md` (split candidate); `docs/methodology_sgr.md` §Differences from the original report's Table 1.

## Context

The 2023 trial report (Deepika Satchithananthan) computed per-cage SGR using the workbook's two weight checks:

```
SGR_report = (ln(W_interim) − ln(W_initial)) / days × 100
```

Two problems made the report's Table 1 SGRs unreliable:

1. **Window mismatch.** The "initial" check was 2023-05-03 (T1) or 2023-06-07 (T2), well before the trial start of 2023-07-20. The "interim" check was 2023-08-01/02 — only 12 days into the trial. The formula therefore mostly measured **pre-trial growth** with a small trial-window tail.
2. **Single-check sampling noise.** Each weight check sampled ~1% of cage population. With small N, the second check randomly hitting smaller fish produced **negative apparent SGRs** for several cages. The report acknowledged this for P3C4 (351 → 143 g) but did not filter affected cages.

## Decision

Replace the two-point formula with a **trajectory-anchored endpoint** estimator:

```
SGR_realised = (ln(W_sim_end) − ln(W_sim_start)) / days × 100
```

where `W_sim_start` and `W_sim_end` are the **spline-fitted simulated weights at the trial-window endpoints**, computed by the MDF SGR fitting pipeline. The spline anchors on multiple sample sources (workbook, SharePoint, raw per-fish, trial weight checks), so the estimator is robust to small-N single-check sampling artefacts.

Endpoint dates are the actual trial-window boundaries:
- T1: `2023-07-20 → 2023-09-20` (63 days).
- T2: `2023-07-20 → 2023-09-06` (49 days).

## Consequences

- **Trial-1 SGRs flip from negative to positive** for several cages. The cohort spread becomes 0.18–0.30 %/day where the report had negatives.
- **The numbers in this project do not reproduce the report's Table 1.** Any reader comparing to the report must read this ADR + `docs/domain/methodology-sgr.md` §Differences before flagging a discrepancy.
- **Dependency on the spline.** The estimator's quality is the spline's quality. The spline is anchored on ≥3 sample sources per cage in most cases (see `pipeline/build_snapshot.py` injection counts in `pipeline/audits/snapshot_summary.json`). For cages with limited samples after the interim check, see [ADR-0003 — Spline forecasting mode](0003-spline-forecasting-mode.md).
- **Pre-trial SGR is now estimable** as a separate quantity. The `pretrial/` analysis uses the same trajectory-anchored estimator over `2023-05-20 → 2023-07-19`, producing a clean baseline that lets us decompose the trial gap into "inherited cohort variance" and "regime effect" — see `docs/domain/methodology-pretrial.md`.

## Alternatives considered

- **Keep the report's formula for direct comparability.** Rejected — the formula is wrong for the trial window and the noise issue is not optional.
- **Use the workbook checks but on the trial-window dates only.** Not possible — there is only one check inside the trial window (the interim), no end-of-trial weight check. The trial was designed without an end-weight protocol for the trial cohort (harvest came later, mixed with operational events).
- **Two-point ln formula on simulated weights only (skip the per-day evaluation).** Functionally equivalent to the endpoint formula; this is what we use. The "model" comparison is the part that benefits from per-day evaluation, not the realised SGR.
