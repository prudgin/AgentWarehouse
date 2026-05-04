**Status:** ready-for-agent
**Category:** enhancement

## What to build

Add a worked example of provenance chaining to `templates/analysis/glossary.md`'s format-rules section. The chain pattern: glossary entry → domain doc → REPORT.

Current glossary placeholder examples have a `_Provenance_` field but don't illustrate that the link can chain through `docs/domain/`. Example to add (in the format-rules narrative or as a placeholder example):

```md
**Linear-Gaussian baseline**:
The default OLS-fit-with-Gaussian-residuals model used for first-pass analyses.
_Avoid_: linear regression (too generic), OLS fit (too narrow — implies only the optimisation method).
_Provenance_: definition lives in [docs/domain/model.md](docs/domain/model.md);
the term itself was resolved in [analysis/2026-01-14-baseline-fit/REPORT.md].
```

The example should make clear that provenance can chain: a term that was *resolved* in a REPORT but whose *form/depth* lives in a domain doc legitimately points provenance at the domain doc, which itself back-points to the REPORT.

## Why

Analysis subagent flagged that the chain (glossary → domain → REPORT) is correct per the rules but takes two reads of the format rules to verify. A worked example collapses that to one read.

## Acceptance criteria

- [ ] `templates/analysis/glossary.md` contains a worked example showing chained provenance.
- [ ] The example is annotated with one line explaining *why* chaining is legitimate.
- [ ] No change to the format rules themselves — just the example.

## Blocked by

None.

## Comments

(empty)
