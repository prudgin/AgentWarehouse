# ADRs — 2023 Feeding Frequency

Architecture Decision Records for methodological choices that survive the 3-of-3 admission test (hard to reverse, surprising without context, real trade-off).

- [0001 — Trajectory-anchored endpoint SGR](0001-trajectory-anchored-endpoint-sgr.md) — spline-derived endpoints instead of the 2023 report's two-point ln-form.
- [0002 — Books-clean filter at 9% threshold](0002-books-clean-filter-at-nine-percent.md) — exclude cages with > 9% trial-attributed bookkeeping drift.
- [0003 — Spline forecasting mode](0003-spline-forecasting-mode.md) — extend trajectories past the last sample by holding α constant.
- [0004 — Hybrid feed source](0004-hybrid-feed-source-workbook-and-mdf.md) — workbook inside the trial window, MDF outside.

Operational session notes that did NOT pass 3-of-3 (refactors, file moves, trivial fixes) are preserved in `_legacy-decisions-log.md` for reference.
