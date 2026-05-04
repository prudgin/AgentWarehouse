# Future Work

Open backlog. Top of file = next up. As work ships, the entry moves out: shipped behaviour goes into `docs/reference/`; rationale and decision history go into `docs/adr/` or `analysis/analysis-landscape.md`.

This file holds **proposals and open questions only**. Nothing about what's already done — that lives in the codebase, the reference docs, and the analysis tree.

See [`README.md`](README.md) for the boundary rule (vs. `.tickets/`) and the entry format.

## Backlog

<!-- PLACEHOLDER — replace with real entries.

## Investigate slow ledger publish step

**What:** profile the publish stage and identify the bottleneck.
**Why:** publish is currently 40% of total pipeline time; suspect the staging copy.
**Open questions:** is the bottleneck I/O, parquet serialisation, or the atomic rename?
**Links:** [analysis/2026-01-14-publish-timing/REPORT.md] (if started).

-->
