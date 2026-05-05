# Glossary — <PLACEHOLDER: project name>

<PLACEHOLDER: one or two sentences describing the project's research domain and why this glossary exists.>

This is the project's **ubiquitous language**: one canonical term per concept, with synonyms explicitly avoided. Variables, functions, doc text, REPORT writeups, and ticket titles should use the canonical term and never the avoided ones.

Entries here typically come from `analysis/<dated>/REPORT.md` findings, promoted via `/finish-analysis`. Each entry should link to the REPORT that produced it (provenance).

## Format rules

- **Be opinionated.** When multiple words exist for the same concept, pick one and list the others as "Avoid".
- **Flag conflicts explicitly.** If a term is used ambiguously, call it out in "Flagged ambiguities" with a clear resolution.
- **One sentence per definition.** Define what it IS, not what it does. Depth goes in `docs/domain/`.
- **Show relationships.** Use bold term names and express cardinality where obvious.
- **Domain only.** General programming or statistics concepts do not belong, even if the project uses them. Ask: "is this concept unique to this domain, or general?" Only the former qualifies.
- **Link provenance.** Each entry links the REPORT (or domain doc) where the term was resolved.
- **Entry shape.** Each entry is a `### Term` heading followed by a blank line, the definition paragraph, a blank line, and italic-field lines (`_Avoid_:`, `_Provenance_:`, ...). Heading style is required so deep-links into the glossary resolve via standard markdown anchors.

## Language

<!-- PLACEHOLDER — example structure, replace with real domain terms.

### Degree-hours (DH)

Cumulative thermal time since a reference event (e.g. last feed) — sum over hours of water temperature × duration.

_Avoid_: degree-days (different unit), thermal sum (ambiguous reference).
_Provenance_: [analysis/2026-01-14-thermal-time/REPORT.md].

### Hump model

Difference of two sigmoids σ_arr − σ_clr, modelling fraction of fish with feed in intestine over time.

_Avoid_: bell curve, peak model.
_Provenance_: [docs/domain/model.md].

### Linear-Gaussian baseline

The default OLS-fit-with-Gaussian-residuals model used for first-pass analyses.

_Avoid_: linear regression (too generic), OLS fit (too narrow — implies only the optimisation method).
_Provenance_: definition lives in [docs/domain/model.md](docs/domain/model.md);
the term itself was resolved in [analysis/2026-01-14-baseline-fit/REPORT.md].
(Chained provenance is legitimate when a term is *resolved* in a REPORT but its *form/depth* lives in a domain doc — point at the domain doc, which itself back-points to the REPORT.)

-->

## Relationships

<!-- PLACEHOLDER — example.

- A **Hump model** evaluates against **Degree-hours (DH)** as the time axis.
- The **Hump model** has parameters **m_arr**, **m_clr** (midpoints) and **w_arr**, **w_clr** (widths).

-->

## Example dialogue

<!-- PLACEHOLDER — a short conversation between a researcher and a domain
     expert that demonstrates how the terms interact naturally. -->

## Flagged ambiguities

<!-- PLACEHOLDER — only list terms that have caused confusion or that have
     been deliberately disambiguated. Empty section is fine for new projects. -->
