# Known issues

Durable model pathologies and data-quality problems that future agents and future-me need to know about. Each entry: what's wrong, why, current mitigation, and what would resolve it.

For per-term definitions see [`glossary.md`](../../glossary.md). For forward-looking action items (cold-band data, larger n, etc.) see [`docs/planning/future-work.md`](../planning/future-work.md). For the model itself see [`model.md`](model.md).

---

## Model issues

### KI-01 — Arrival sigmoid is poorly identified

**Symptom.** The optimiser pushes `w_arr` to its lower bound (current run: `w_arr = 2.4 DH`). `m_arr`'s reported CI is artificially tight; it reflects optimiser stability at a boundary corner, not real biological precision.

**Cause.** With *c* absorbed into the model, the per-meal hump can't exceed `c × 1` on the rising side. To explain observed peaks of ~90–100 % in the intestine data, the optimiser forces a near-instantaneous arrival.

**Mitigation in current code.** Bound on `w_arr` is `(1, 400)`, lowered from the spec's original `(20, 400)` because the c-correction sharpened arrival further.

**Reporting rule.** Do **not** report `m_arr` or `w_arr` as biological numbers. The headline DH-at-5 % is unaffected (it's dominated by `m_clr`, `w_clr`).

**Possible fix.** Tighten `w_arr` lower bound back to ≥ 30 to keep the arrival parameters interpretable, accepting that the fit will under-predict the early peak. Pair this with KI-02 (let *c* be fitted with t=0 stomach as a soft constraint) — the two issues are coupled.

**Provenance.** First production run, April 2026 — `working_notes_for_future_runs.txt` (archive); `analysis/2026-04-16-warm-band-fit/REPORT.md` (planned, retrofit).

---

### KI-02 — Eating fraction *c* is probably underestimated

**Symptom.** Model under-predicts the early intestine peak: model peaks at ~80 %, data shows 90–100 %.

**Cause.** *c* is computed from t=0 stomach observations (`% Today feed in stomach`). Fish that ate today but cleared their stomach quickly look like non-eaters at sampling and are excluded from the *c* numerator. The bias is downward.

**Mitigation in current code.** None. *c* is fixed input; the fit absorbs the under-counting into hump-shape distortion (see KI-01).

**Possible fix.** Let *c* be a fitted parameter with t=0 stomach data contributing as a *soft constraint* (likelihood term) rather than a hard input. More implementation work but cleanly handles the bias. Couple with KI-01 resolution.

**Provenance.** `working_notes_for_future_runs.txt` (archive).

---

### KI-03 — Yesterday-stomach validation gap

**Symptom.** Model predicts 37–54 % yesterday-residual at t=0; observed `% old feed in stomach` is 0–13 %. A persistent ~30+ percentage-point gap.

**Most likely cause.** Graders under-score "old" pellets — fresh and digested pellets are hard to distinguish after hours mixed in stomach, and the default attribution is "today" when uncertain.

**Less likely cause.** Real residual clears faster than the model thinks (would imply the two-meal independence assumption is wrong, or `d_y` is overestimated).

**Mitigation.** "% old feed in stomach" is treated as soft validation only — does **not** enter the fit. Reports flag the gap and note the grading-artefact hypothesis.

**Possible fix.** Improve grading protocol if achievable. Otherwise continue to treat `% old feed in stomach` as soft validation; do not adjust the model based on it.

**Provenance.** `working_notes_for_future_runs.txt` (archive); model-spec §"Validation against '% old feed in stomach'".

---

## Data quality issues

### KI-04 — Whitton/P7C5 outlier in mid-decline

**Symptom.** Both stomach and intestine standardised residuals at DH 345 and DH 570 exceed +2.0 (current run: stomach +2.73 / +2.68; intestine +2.00 / +2.64). Consistently above the pooled trend.

**Cause.** Unknown. Could be real pond variation (different fish or conditions specific to that pond) or a measurement quirk (single batch, consistent grader bias). With 4 ponds total there is no statistical power to distinguish.

**Mitigation.** Note in every report. Headline numbers remain trustworthy because the outlier doesn't dominate the fit.

**Possible fix.** Per-pond χ² contributions in the report would localise pond-level outliers automatically. Not yet implemented (see future-work).

**Provenance.** `working_notes_for_future_runs.txt` (archive).

---

### KI-05 — Borderline goodness-of-fit p-values

**Symptom.** Pearson χ² p-values: 0.011 (stomach), 0.028 (intestine). Below the 0.05 conventional threshold; mostly driven by KI-04 and a few late-DH points.

**Cause.** Single hump shape pooled across 4 ponds with only modest pond-to-pond variability captured. Real systematic misfit at the level of ~2–3 outlier rows.

**Mitigation.** Note in reports as "fit is adequate but not excellent". Headline numbers (DH-at-5 %, `m_emp`, `m_clr`) are trustworthy at this fit quality.

**Possible fix.** Hierarchical extension on `m_clr` per pond once enough ponds are in scope (see future-work). Will not help on the current 4-pond dataset.

**Provenance.** `working_notes_for_future_runs.txt` (archive).

---

### KI-06 — MCF/P8C8 has no t=0 row

**Symptom.** *c* for `MCF/P8C8` is imputed from the mean of other observed ponds (current value 0.811, vs. 0.667–0.867 observed elsewhere).

**Cause.** Sampling protocol gap on that pond.

**Mitigation in current code.** Imputation flagged in every report. The model fits without modification — `c` is treated as input data either way.

**Reporting rule.** Always state *c* imputation prominently when reporting MCF/P8C8 results.

**Possible fix.** Future trials must always include at least one t=0 sample per pond. Captured in future-work.

**Provenance.** `working_notes_for_future_runs.txt` (archive); current run's report flags this in §"Eating fraction c by pond".

---

## Reporting rule of thumb

When a report references the headline DH-at-5 %, none of these issues compromise it materially. When a report references arrival-side parameters (`m_arr`, `w_arr`, intestinal-arrival kinetics, stomach-dripping duration) it must cite KI-01. When a report references *c* per pond, it must cite KI-02 (and KI-06 for MCF/P8C8). When a report shows yesterday-stomach validation, it must cite KI-03.
