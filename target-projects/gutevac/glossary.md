# Glossary — gutevac

Project-specific vocabulary for the gut-clearance research on farmed Murray cod. Read this before naming anything new in the repo.

Each entry: canonical term, synonyms to **avoid**, one-sentence definition, relationships, an example dialogue line, and any flagged ambiguities.

---

## Degree-hours (DH)

**Avoid**: thermal time (bare), °C·h, "DH₀" (unless explicitly contrasting with a Q10-adjusted transform).

The thermal-time unit used as the operative time axis throughout the project: the integral of water temperature over wall-clock time since the last feed, ∑(T·Δt). All model parameters, thresholds, and CIs are reported in DH.

**Relationships**: converted to clock-hours at a reference temperature via `hours = DH / temp_c`. Precomputed per row in the master Excel's `Degree * hours` column; do not recompute from `Hours passed × Water temperature at harvest` (the precomputed values use hourly-grained temperature data and are more accurate).

**Example**: "DH at 5 % is 1218, which is about 61 hours at 20 °C."

**Flagged**: the proposal's text discusses DH, DH₀, and Q10-adjusted variants as candidates for testing thermal-time invariance; in the current single-band fit only plain DH is used. If multi-band data ever arrives, this distinction will need to be revived.

**Provenance**: `docs/reference/model-spec.md`; `docs/proposal/stage-1-2025-12-16.docx`.

---

## Pond

**Avoid**: cell, dam, tank (when referring to the analysis-level sampling unit).

A `Farm/Unit` pair (e.g. `Whitton/P7C5`) acting as a replicate in the fit. Ponds pool across timepoints; the model fits a single hump shape across all ponds, with per-pond differences entering only through the pond-mean temperature (which sets `d_y`) and per-pond `c`.

**Relationships**: identified in code as `pond_id = Farm/Unit`. Current dataset: 4 ponds in the warm band (`MCF/P8C8`, `Whitton/P7C5`, `Whitton/P7C2`, `Whitton/P10C8`).

**Example**: "Whitton/P7C5 is the pond with the borderline residuals at DH 345 and 570."

**Flagged**: "cell" and "dam" appear in the oxygen-report data (e.g. `F04_Cell02_Dam07`); they refer to physical infrastructure, not analysis units. Inside the gut-clearance analysis, always use **pond**.

**Provenance**: `docs/reference/model-spec.md`; `data/raw/Data trimmed.xlsx` columns `Farm`, `Unit`.

---

## Eating fraction (c)

**Avoid**: eating compliance, eating rate, c-factor.

The per-pond fraction of fish that ate today's meal. Computed from a pond's t=0 row(s) as `c_pond = "% Today feed in stomach"` (averaged across multiple t=0 rows if present). Multiplies the hump model so that non-eaters contribute zero today-meal signal.

**Relationships**: assumed equal day-to-day (`c_yest = c_today`). When a pond has no t=0 row, `c` is imputed from the mean of observed ponds and the report flags the imputation. Currently observed range across ponds: 69.8–86.7 %; mean ≈ 81 %.

**Example**: "MCF/P8C8 has no t=0 row, so its c is imputed at 81.1 %."

**Flagged**: working notes #2 — `c` is probably underestimated, because fish that ate today but cleared their stomach quickly look like non-eaters at sampling. Future runs may let `c` be a fitted parameter with t=0 stomach data as a soft constraint.

**Provenance**: `docs/reference/model-spec.md` §"Eating fraction c"; `docs/domain/known-issues.md` item 2.

---

## Hump model

**Avoid**: single-sigmoid model, peasant model (those refer to the earlier superseded methods in `archive/`).

The single-meal intestinal model: `f_intestine(DH) = c · (σ_arr(DH) − σ_clr(DH))`, with `σ(x; m, w) = 1 / (1 + exp(−(x − m)/w))`. Produces a hump because `σ_arr` rises from zero before `σ_clr` does, so their difference peaks and decays. Four shape parameters (`m_arr`, `w_arr`, `m_clr`, `w_clr`) shared across all ponds.

**Relationships**: combined with itself via the **two-meal combination** to produce the per-row predicted probability used in the binomial likelihood. Stomach has its own simpler form `g_stomach(DH) = c · (1 − σ_emp(DH))`.

**Example**: "The hump model peaks at about 0.83 before the c multiplier."

**Flagged**: arrival parameters (`m_arr`, `w_arr`) are poorly identified — `w_arr` pins to its lower bound in the current run. Treat `m_arr` as a fitting artefact, not a biological number. See `docs/domain/known-issues.md` item 1.

**Provenance**: `docs/reference/model-spec.md` §"Model".

---

## Two-meal combination

**Avoid**: today-plus-yesterday model, two-day combination.

The independence formula combining today's meal contribution with yesterday's residual on the same fish: `P_obs = 1 − (1 − f(d_t)) · (1 − f(d_t + d_y))`, where `d_t` is the row's DH and `d_y = T_pond_mean × 24` is yesterday's-meal age in DH.

**Relationships**: applies uniformly to all rows including t=0 (do **not** special-case t=0; let the model evaluate at the actual observed `d_t`, which is 0–14 DH for time-zero rows). Both stomach and intestine use this combination.

**Example**: "At t=0 the two-meal combination predicts 37–54 % yesterday-residual but observed is 0–13 %."

**Flagged**: the t=0 prediction gap is the project's largest unresolved validation issue; most likely a grading artefact (graders under-score "old" pellets). See `docs/domain/known-issues.md` item 3.

**Provenance**: `docs/reference/model-spec.md` §"Two-meal combination (independence)".

---

## t=0 row

**Avoid**: time-zero sample, baseline row, reference row.

A row in the master data where `% Today feed in stomach` is non-null. This is the data-driven marker for a time-zero observation; that column is empty at every other timepoint by protocol. A pond's t=0 row anchors its eating fraction `c`.

**Relationships**: a t=0 row may have a small but non-zero `Degree * hours` (observed range 0–13.6 DH) because sampling occurs slightly after the nominal feed cutoff; treat the small DH at face value, do not zero it. A pond may have multiple t=0 rows (e.g. Whitton/P7C5 has two — average them for `c`).

**Example**: "MCF/P8C8 has no t=0 row, which is why its c had to be imputed."

**Flagged**: future trials should always include at least one t=0 sample per pond. See working-notes data-collection priority #8.

**Provenance**: `docs/reference/model-spec.md` §"Time-zero detection (data-driven, no config needed)".

---

## Today feed / Old feed (in stomach)

**Avoid**: fresh feed, fresh pellets, residual feed (when referring to the data columns).

Two stomach-content categories distinguished by opening fish at sampling and visually scoring pellets. Recorded only at t=0 rows.

- **Today feed** — pellets eaten in the most recent feeding event. Captured in the column `% Today feed in stomach`. Drives the eating fraction `c`.
- **Old feed** — pellets remaining from the previous day's feeding event. Captured in `% old feed in stomach`. Used as a soft validation against the model's predicted yesterday-residual; **not** used in the fit.

**Relationships**: `% Today feed in stomach + % old feed in stomach ≤ % Feed in stomach` at t=0 (the totals column is the union; the breakdown is a subset of fish where pellet age was scoreable).

**Example**: "Today/old splitting was added to the protocol after the proposal — the proposal didn't anticipate opening stomachs and counting pellets."

**Flagged**: `% old feed in stomach` is flimsy data — typically 0–2 fish out of 15 at each t=0 row. ±15 percentage-point disagreement with the model is unremarkable; ±30 + would be concerning. Working notes #3 hypothesises graders under-score old pellets.

**Provenance**: `docs/reference/model-spec.md` §"Validation against '% old feed in stomach'"; `data/raw/Data trimmed.xlsx`.

---

## Harvest fasting period

**Avoid**: fasting time, withholding period, starve time.

The pre-harvest fast required for fish guts to clear sufficiently for harvest. The operational decision this whole project exists to inform. Reported as a DH value with hour-equivalents at reference temperatures (15, 20, 25 °C).

**Relationships**: the **DH at 5 %** is the primary harvest criterion (see next entry). Below this fraction, fish are considered "clean enough" by the project's working definition. Stomach emptying (`m_emp`) sets a lower bound on inter-meal interval but is **not** the harvest criterion — intestinal clearance is.

**Example**: "Current recommendation: minimum harvest fasting of 1218 DH, ≈ 61 hours at 20 °C."

**Flagged**: the value applies only inside the trial temperature range (17–27 °C). Cold-water extrapolation requires future cold-band data.

**Provenance**: `docs/reference/model-spec.md` §"5. Practical recommendations"; `analysis/2026-04-16-warm-band-fit/REPORT.md` (planned, retrofit of the current run).

---

## DH at 5 %

**Avoid**: 5 % threshold, 95 % cleared time, T₉₅.

The DH at which the predicted intestinal-feed fraction `f_intestine(DH)` falls to 5 % of *all* fish (including non-eaters), evaluated on the decline side of the hump. The project's primary harvest criterion.

**Relationships**: thresholds are also reported at 50, 25, 10, and 1 %. The threshold convention — **% of all fish, including non-eaters** — is a deliberate choice; an alternative convention ("% of fish that ate today") would shift the number. The choice is stated explicitly in every report.

**Example**: "DH at 5 % is 1218, 95 % CI [1072, 1351]."

**Flagged**: changing the threshold convention would change the headline number meaningfully (eating fraction is ≈ 0.81, so a 5 %-of-eaters threshold corresponds to ≈ 4 %-of-all-fish). Always state which convention you mean.

**Provenance**: `docs/reference/model-spec.md` §"Derived quantities"; `analysis/2026-04-16-warm-band-fit/REPORT.md` (planned).
