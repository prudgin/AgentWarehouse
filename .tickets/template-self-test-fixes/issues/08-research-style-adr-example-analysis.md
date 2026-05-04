**Status:** ready-for-agent
**Category:** enhancement

## What to build

Add a worked research-style ADR example to `templates/analysis/docs/adr/README.md`. The current placeholder example is `event-sourced-orders.md` — a build-chain shape that doesn't translate to research projects.

Suggested example shape (do not literally write this ADR file in the template; just update the README's example block):

```md
- [0001-likelihood-choice-binomial.md](0001-likelihood-choice-binomial.md) — use standard binomial likelihood throughout, including for k=0 observations; rejected the asymmetric-likelihood alternative because the model's structural constraints prevent the long-fat-tail pathology that motivated asymmetric handling.
```

The example should illustrate a methodology decision (likelihood choice, validation procedure, pooling strategy) rather than an architectural one.

## Why

Analysis subagent flagged that the only ADR example in the template is build-chain-shaped, which sets the wrong mental anchor for what an analysis-template ADR looks like. A research-style example lowers the barrier for an analyst writing their first ADR.

## Acceptance criteria

- [ ] `templates/analysis/docs/adr/README.md` has a research-style example (likelihood, validation, pooling, or similar) replacing or supplementing the current build-chain example.
- [ ] The example is illustrative only (in an HTML-comment placeholder block), not a real committed ADR.
- [ ] Wording demonstrates the 3-of-3 admission test passing for a methodology decision.

## Blocked by

None.

## Comments

(empty)
