# Future work

Open items for the 2026 Juvenile gut evac trial — data-collection priorities, analysis improvements, downstream consumers. Anything pre-decision lives here; once a decision is made and the work is scoped, it migrates to `.tickets/` as a concrete ticket (see [`docs/planning/README.md`](README.md)).

## In-flight trial bookkeeping

### FW-TR-01 — Cohort C pellet size, settled on the day

Pellet size for Cohort C (80–150 g) is **TBD on the day** depending on what the cage is actually being fed at the 80 g transition. The cage may be split into two sub-cages if it straddles the 4.5/6.5 mm cutoff. Record the decision and the `pellet weight` (g) into the long-form Excel `pellet size mm` and `pellet weight` columns; update [`docs/domain/data-shape.md`](../domain/data-shape.md) if the recording schema needs an extra "sub-cage" column.

### FW-TR-02 — Cohort A may need an extra sentinel sweep

The smallest cohort is most likely to require fast extension at the sentinel step (per [ADR-0001](../adr/0001-t0-anchor-via-prefast-and-sentinel.md)). Schedule slack is already budgeted. If two extensions are needed, slip the cohort rather than feeding into a contaminated t=0.

### FW-TR-03 — Flag pond temp drift > 2 °C across the sampling window

Pond temperature is logged hourly through the trial. If the cohort's pond temperature drifts > 2 °C between t=0 and the last sampled timepoint, flag in the per-cohort fit report — both the AIC and the t-at-20% will be sensitive to this. The proposal explicitly mentions this; carry the check forward into the analysis script.

## Analysis improvements

### FW-AN-01 — Diagnostic for π stability across timepoint samples

[ADR-0002](../adr/0002-normalisation-by-t0-batch-mean.md) depends on π being roughly stable across timepoint samples. Add an explicit diagnostic to the analysis: compare the binary-empty fraction at each timepoint to the cohort's t=0 π estimate; flag if any timepoint drifts beyond a sensible band (e.g. ±15 percentage points). If the diagnostic fires, the fallback is to fit raw (un-normalised) batch_dry curves with wider CIs.

### FW-AN-02 — Pellet-count cross-check as automated audit

Where pellets remain countable (`Pellets count in stomach` non-null), implement the cross-check programmatically: per timepoint, compare `mean(pellet_count) × pellet_weight` against `batch_dry / 15`. Disagreement flags either a balance issue or a sampling bias. Add to the analysis pipeline output as a per-cohort table.

## Downstream consumers

### FW-DN-01 — Feeding-frequency trial design uses GER curves

The output of this project — per-cohort `t at 20 % residual` (clock-hours and degree-hours) — is the design input for the upcoming juvenile feeding-frequency trial. The feeding-frequency project is a separate sibling and will be set up via the warehouse intake flow when its planning starts. File a forward link from this project's `Reports/` to that project once it exists.

### FW-DN-02 — SFR points reuse

Per-fish length, weight, and K-index from the 270-fish dataset are an incidental SFR calibration dataset. May feed back into `growth_models.sfr` (separate package). No specific consumer scheduled; file the cleaned per-fish data for later use.

### FW-DN-03 — Nematode survey

Per-fish nematode count is a side metric. Summarise as cohort-level prevalence (% fish with ≥ 1) and intensity (mean count among infected). Stakeholder for the survey result is TBD; flag in the cohort report and let the relevant farm contact decide.

## Methodology extensions

### FW-ME-01 — Cold-water cohort extension

Out of scope for this round. Bilbul is warm-water. Cold-water cohorts remain a separate, deferred item that mirrors the sibling `2026 Gut Clearance` project's identical deferred item.

### FW-ME-02 — Per-fish stomach DM via dish weighing

The dissection bench's `Form template.xlsx` includes dish-tare-aware per-fish dry-weight fields (rows 5–7). The current trial uses these only at the batch level. Future trials with smaller cohorts could push the dish protocol to per-fish — would unlock per-fish variance estimates for the within-cohort batch-mean uncertainty.
