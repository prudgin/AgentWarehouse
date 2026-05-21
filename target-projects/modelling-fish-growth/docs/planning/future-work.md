# Future work — modelling-fish-growth

Open backlog. Items below are pre-decision: they describe a direction without yet committing to scope, design, or sequencing. Once an item becomes a decided piece of work, it moves to `.tickets/` (and this entry is deleted, per the warehouse boundary rule).

## Pipeline conversion (later milestone)

Once the iterative fit has stabilised through one or more analysis rounds — i.e. the Glencross-2012 surface refit converges reliably, per-cycle α(t) behaves, and the diagnostic story is settled — convert the project to the `pipeline` template (or layer pipeline shape on top of the analysis tree). Rationale: today the work is exploratory and per-round, so `analysis` is the honest framing; tomorrow we'll want a one-command end-to-end refit against new cycle data, which is `pipeline` shape.

When the conversion happens:
- Stages will likely mirror `idea.md` §Process: ingest cycles → init surface → per-cycle fit → quality weights → re-bin & refit → iterate → downstream SFR/FCR.
- `docs/reference/<stage>.md` per stage replaces / supplements the INVESTIGATION-centric writing pattern.
- Add a `Pipeline areas` table to `CLAUDE.md`.
- The existing `analysis/` dirs stay — exploratory work continues to live there.

## Joint NLME-ODE validation fit

From `idea.md` §Open questions: a Bayesian NLME-ODE fit (nlmixr2 in R, or Stan/NumPyro/PyMC in Python) as cross-validation against the iterative approach. Compare population-level Glencross coefficients and per-cycle α distributions. Deferred until the iterative approach produces a transparent baseline to compare against.

## Per-cycle covariate model

Once α and α(t) are stable, regress per-cycle α on covariates (feed type, stocking density, pond ID, season, disease events, treatment windows) to explain systematic deviations. Needs cycle-level metadata that doesn't exist as structured data yet.

## Measurement-error / temperature-uncertainty handling

Cleanly handled only in a Bayesian framework. Defer until the NLME-ODE branch is live.

## Cycle selection (representative cycles for surface fit)

`idea.md` §Scope: out of scope for first milestone, but will eventually need water-quality (DO, ammonia, T swings), disease incidence (iridovirus, EHN, protozoans), chemical treatments (sodium percarbonate, formalin), stocking density. See `docs/literature_review.md` §4 for the named cycle covariates.
