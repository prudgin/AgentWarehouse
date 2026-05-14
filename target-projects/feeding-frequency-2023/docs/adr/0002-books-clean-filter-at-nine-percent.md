# ADR-0002 — Books-clean filter at 9% threshold

**Status**: accepted.
**Date**: 2026-05-07 (decision); 2026-05-14 (ADR captured).
**Provenance**: `docs/filters_and_drops.md` §Filter 4; `docs/decisions_log.md` 2026-05-07 entry "project tidy-up".

## Context

Per-cage SGR/SFR estimates depend on knowing the **daily fish inventory** in each cage. Two bookkeeping signals contaminate this:

- **`A_count`** — operator-entered count adjustments (typically write-offs for unrecorded mortality / cullings).
- **`CA_count`** — system close-day reconciliation (large adjustments at cycle close).

Both can be positive (fish removed from books) or negative (fish added back). When these adjustments are large relative to inventory, the **daily open count** that the SGR model fits against is unreliable — the cage may have had a different fish count for weeks before the books caught up.

A formal metric for this contamination is:

```
adj_daily_pct  = (A_count + CA_count) / Σ(daily_open_count) × 100     [%/day, cycle-wide]
trial_pct      = adj_daily_pct × trial_days                            [%, trial-attributed]
```

This spreads the cycle's total adjustment proportionally to daily inventory (Option B in `pipeline/audits/cycle_books_pct_compare.csv`), giving a constant cycle-wide daily rate that's then attributed to the trial portion.

## Decision

**Exclude cages where `|trial_pct| > 9.0%`** from the canonical analysis cohort.

The threshold is a deliberate round number. Alternative bases (% of stocking, % of throughput, % of mean inventory) are tabulated in `pipeline/audits/cycle_books_pct_compare.csv` and lead to broadly similar lists; 9% on "% of mean inventory" was chosen as the simplest defensible cutoff.

Implementation lives in `_common.books_noisy_drops()`, which reads `pipeline/audits/cycle_books.csv` at runtime. The drop set is unioned with `HARDCODED_DROPS` in `default_drops()`. **Self-syncing**: if the live ledger or threshold changes, the cohort updates automatically — the analyses don't carry hard-coded cohort lists.

## Consequences

- **Cohort size 48 → 32** (-16). The 16 dropped cages, by filter:
  - 8 by trial design (Pond 5: 4, 5, 8, 12; Pond 6: 1, 2, 7, 8).
  - 1 with no weight data (P3C12).
  - 1 corrupt sampling (P3C4 — hardcoded; see `docs/domain/filters-and-drops.md` §Filter 3).
  - **6 by books-noisy at 9% threshold**: P1C1, P1C6, P1C7, P3C5, P6C4, P6C12.
- **Headline numbers shift.** The 32-cage pooled SFR/SGR ratios are the canonical results reported in the README and the cross plot.
- **Threshold is a knob, not a discovery.** Anyone running a sensitivity at 7% or 12% can do so trivially by editing `_common.BOOKS_NOISY_THRESHOLD` (constant); the cohort regenerates automatically.
- **Single canonical output set.** As of 2026-05-07 the project deleted the parallel "unfiltered" outputs that previously existed. Only the books-clean cohort is reported. Users who want the unfiltered set must regenerate it.

## Alternatives considered

- **Lower threshold (5%)**: drops ~12 cages, leaves ~26. T2 control becomes very thin (4–5 cages). Rejected — sacrifices statistical power for a stricter cutoff that doesn't materially shift conclusions.
- **Use `% of throughput`** (sum of inflows + outflows) as the denominator. Tabulated in `cycle_books_pct_compare.csv`. Smaller denominators inflate the metric for short cycles; rejected as less defensible than mean inventory.
- **Drop cages with `|CA_count| > some absolute threshold`**: not normalised to cage size. Rejected.
- **No filter (use all 40 cycles)**: the report did this. Rejected — six cages have demonstrable inventory drift that contaminates per-cage SGR. The whole point of this re-analysis is to be more rigorous than the report on noise like this.
