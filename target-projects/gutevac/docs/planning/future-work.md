# Future work

Open backlog. Top of list = next up. Items move to `.tickets/` when ready to start; entries here are seeds, not specs.

For known issues with the current model and data see [`docs/domain/known-issues.md`](../domain/known-issues.md). For per-term definitions see [`glossary.md`](../../glossary.md).

---

## Data collection

### FW-DC-01 — Cold-band data (8–13 °C)

**Why.** Current data covers 17–28 °C only. The fasting lookup table extrapolates to colder temperatures using the degree-hours relationship, but this has not been validated empirically. The original Stage 1 proposal explicitly proposed three temperature bands (see [ADR-0001](../adr/0001-divergence-from-stage-1-proposal.md)); cold-band coverage is the largest open gap in the work.

**What it unlocks.** First, headline numbers usable in winter harvest. Second, the actual scientific question from the proposal — does thermal-time scaling collapse curves across temperature bands, or is a separate cold-water curve needed?

**Plan.** When cold-band data arrives, refit the pooled model on the combined dataset first, then test for a temperature-band fixed effect on `m_clr` to see whether sigmoid kinetics are truly DH-invariant.

### FW-DC-02 — Mid-band coverage (14–19 °C)

**Why.** Current dataset has limited coverage in the mid-temperature band (only Whitton/P7C2 and Whitton/P10C8 sit near 19–20 °C). More mid-band ponds would tighten CIs and test for pond-to-pond variability in this range.

### FW-DC-03 — Always include a t=0 sample per pond

**Why.** Without a t=0 row, *c* must be imputed from the cross-pond mean — see KI-06. One row with a non-null `% Today feed in stomach` is sufficient.

**Action.** Sampling-protocol change for all future trials.

### FW-DC-04 — Improve "% old feed in stomach" grading, or drop the column

**Why.** Currently 0–2 fish out of 15 across all t=0 rows; the data is too noisy to be useful and the model-vs-observed gap (KI-03) is most likely a grading artefact.

**Action.** Either invest in grading consistency (paired-grader cross-check, training, photo reference set) or remove the column from the protocol to stop collecting data we can't use.

### FW-DC-05 — Larger n per timepoint

**Why.** *n* = 15 gives wide binomial CIs at intermediate proportions. *n* = 30 would halve the variance per timepoint and tighten the DH-at-5 % CI noticeably.

**Trade-off.** Doubles per-timepoint trial cost. Decide once cold-band coverage is in scope; relative value depends on whether CI tightening or band coverage matters more for the operational question.

---

## Model and analysis

### FW-MA-01 — Resolve coupled `w_arr` / *c* identifiability (KI-01 + KI-02)

**Why.** The two issues are linked: tight `w_arr` lower bound + fitted *c* is the joint fix. Doing one without the other will reintroduce the other's symptoms.

**Plan.** Tighten `w_arr` lower bound to 30. Add a fit-mode for *c* where each pond's t=0 `% Today feed in stomach` enters as a binomial likelihood term rather than hard input. Add a comparison report (current method vs. soft-constraint method) before adopting.

### FW-MA-02 — Per-pond χ² contributions in the report

**Why.** Pond-level outliers (KI-04: Whitton/P7C5 mid-decline) currently surface only via per-row residuals. A summary line per pond would localise outliers automatically.

**Effort.** Small; report-only change.

### FW-MA-03 — Hierarchical extension on `m_clr` per pond

**Why.** If/when more ponds arrive (especially across temperature bands), a random-effects extension on `m_clr` would let pond-level variability inform the CIs without requiring per-pond fits. Will not help on the current 4-pond dataset; do not attempt before more data is in scope.

### FW-MA-04 — End-to-end Python DH pipeline

**Why.** Today, `Degree * hours` in `Data trimmed.xlsx` is computed from the temperature pipeline output (`scripts/process_temperature.py` → `data/raw/Farm 04 Oxygen Reports/processed/*hourly.csv`) and pasted in by hand. Pulling this integration into the gut-clearance package eliminates a manual step and lets the analysis re-run end-to-end from raw oxygen reports + sampling timepoints.

**Likely shape.** Promote `scripts/process_temperature.py` into `src/gut_clearance/temperature.py`; add a `compute_degree_hours()` step that reads sampling timepoints and integrates the hourly temperature series for each pond. Coupled with FW-DC-01 (cold data) since it's the same upstream system.

---

## Operational / reporting

### FW-OP-01 — Review 5 % vs. 1 % threshold with operations and quality teams

**Why.** The 5 % threshold ("1 in 20 fish may still have some feed") is the default reported. If a stricter standard is operationally required, the 1 % threshold adds roughly 300 DH (about 15 hours at 20 °C) to the fasting period. The choice belongs to operations, not the analysis. See [ADR-0003](../adr/0003-harvest-threshold-convention.md).

### FW-OP-02 — Per-fish weight at gut sampling

**Why.** Current protocol records pond-mean weight, not per-fish weight at the gut-state sampling point. Without per-fish weight, fish-weight cannot enter the model as a covariate or as a weighting factor (alternative threshold convention discussed in ADR-0003).

**Action.** Add per-fish weight measurement to the sampling protocol. Cheap; relevant if size-effect questions emerge.
