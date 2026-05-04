# Future Work

Open backlog. Top of file = next up. As work ships, the entry moves out: shipped behaviour goes into `docs/reference/`; rationale and decision history go into `docs/adr/` or `analysis/analysis-landscape.md`.

This file holds **proposals and open questions only**. Nothing about what's already done — that lives in the codebase, the reference docs, and the analysis tree.

## Format

Each entry is short. One paragraph or a small section. Format:

```md
## <short title>

**What:** one or two sentences describing the proposed work.
**Why:** what problem it solves, or what question it answers.
**Open questions:** anything that needs to be resolved before starting.
**Links:** related ADRs, REPORTs, tickets, glossary terms.
```

Order entries by priority (top = next). Resolved entries are deleted, not struck through.

## Backlog

<!-- PLACEHOLDER — replace with real entries.

## Investigate slow ledger publish step

**What:** profile the publish stage and identify the bottleneck.
**Why:** publish is currently 40% of total pipeline time; suspect the staging copy.
**Open questions:** is the bottleneck I/O, parquet serialisation, or the atomic rename?
**Links:** [analysis/2026-01-14-publish-timing/REPORT.md] (if started).

-->
