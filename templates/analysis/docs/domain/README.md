# Domain

Domain knowledge that is **not** vocabulary. Vocabulary lives in `glossary.md` (one canonical term per concept). This directory holds knowledge about how the domain *behaves* — model mechanics, data shape, methodological assumptions, known issues.

For a research project, `docs/domain/` is one of the two centres of gravity (the other is `analysis/`). Findings from INVESTIGATIONs get promoted here when they're durable enough to want a stable home.

**No "working notes" junk drawer.** Per [ADR-0007](../adr/README.md), there is no third place between docs (knowledge) and tickets (status). Content that often accumulates as floating `working_notes.txt` files splits cleanly:

- Caveats and pathologies ("trust this number, not that one") → `known-issues.md`.
- Follow-up priorities ("collect cold-band data next round") → `docs/planning/future-work.md`.
- Methodology decisions ("use binomial likelihood, not asymmetric") → `docs/adr/NNNN-*.md` (if 3-of-3 admission test passes).
- Headline numbers from the latest round → live in that round's INVESTIGATION; promoted to `glossary.md` or here only when they stabilise.

If you find yourself wanting a `working-notes.md`, ask which of the four canonical homes the content belongs in. There is always one.

## When to write here vs glossary

| | `glossary.md` | `docs/domain/` |
|---|---|---|
| Answers | "What does this term mean?" | "How does this work in the domain?" |
| Granularity | One term, one definition | A coherent topic, multi-paragraph or multi-section |
| Examples | "Degree-hours: cumulative thermal time since last feed." | "How the hump model decomposes today's vs. yesterday's meal." "Known issues with the optimiser hitting the w_arr lower bound." |

If you find yourself writing more than two sentences about a term in `glossary.md`, the extra material probably belongs in `docs/domain/`. The glossary entry stays tight; it links to the domain doc for depth.

## Suggested files (create lazily)

These are the topic slots a typical research project ends up filling. Don't create them empty — wait until there's substance:

- **`model.md`** — the model the analysis fits or the framework the data is interpreted through. Equations, parameters, assumptions, constraints.
- **`data-shape.md`** — what's in the raw data, where it comes from, how to read it, what's gitignored vs. committed.
- **`known-issues.md`** — model pathologies, optimiser quirks, data-quality flaws, results that should be treated with caution. Each entry links the INVESTIGATION that surfaced it.

## Rules

- Update when an investigation discovers a new mechanic, anomaly, or relationship.
- Link to `glossary.md` for term definitions; do not redefine here.
- Link to ADRs for methodological decisions.
- Link to the `analysis/<dated>/INVESTIGATION.md` that produced the finding (provenance).
- One file per topic. Topics are stable: prefer extending an existing file over fragmenting.

## Index

<!-- PLACEHOLDER — list each domain doc with a one-line summary. The /finish
     skill checks that every file in this directory is listed here.

- [model.md](model.md) — the analysis model: form, parameters, assumptions.
- [data-shape.md](data-shape.md) — raw-data layout, sources, what's gitignored.
- [known-issues.md](known-issues.md) — model pathologies and data-quality flaws to flag.

-->
