# Domain

Domain knowledge that is **not** vocabulary. Vocabulary lives in `glossary.md` (one canonical term per concept). This directory holds knowledge about how the domain *behaves* — mechanics, anomalies, data shape, business rules.

## When to write here vs glossary

| | `glossary.md` | `docs/domain/` |
|---|---|---|
| Answers | "What does this term mean?" | "How does this work in the domain?" |
| Granularity | One term, one definition | A coherent topic, multi-paragraph or multi-section |
| Examples | "Order: a confirmed customer purchase request." | "How Mercatus UI actions produce data records." "Known anomalies in the cycle ledger." |

If you find yourself writing more than two sentences about a term in `glossary.md`, the extra material probably belongs in `docs/domain/`. The glossary entry stays tight; it links to the domain doc for depth.

## Rules

- Update when you discover a new domain mechanic, anomaly, or relationship — typically during investigation work.
- Link to `glossary.md` for term definitions; do not redefine here.
- Link to ADRs for decisions that shaped how the domain is modelled.
- One file per topic. Topics are stable: prefer extending an existing file over fragmenting.

## Pipeline-specific suggested files

For data pipelines, three domain docs almost always pay off — populate them as you go:

- **`data-model.md`** — entity relationships, schemas, key entity sets, join keys.
- **`mechanics.md`** — how upstream user/system actions produce the records this pipeline ingests.
- **`known-anomalies.md`** — data quirks and edge cases the code has to handle (and why).

Create them lazily — don't make empty stubs.

## Index

<!-- PLACEHOLDER — list each domain doc with a one-line summary. The /finish
     skill checks that every file in this directory is listed here.

- [data-model.md](data-model.md) — entity relationships, schemas, key entity sets.
- [mechanics.md](mechanics.md) — how upstream actions produce data records.
- [known-anomalies.md](known-anomalies.md) — data quirks and edge cases.

-->
