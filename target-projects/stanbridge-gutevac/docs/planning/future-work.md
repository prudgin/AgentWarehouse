# Future work — 2026 Stanbridge gut evac

Open items deferred during intake. Items here are **pre-decision** — once a decision is reached, the entry converts to a ticket in `.tickets/` (and the entry is deleted, per warehouse boundary rule).

## Pre-trial — must resolve before t=0 of first cohort

- **FW-PR-01 — Author `Proposal/Stanbridge_GER_trial_proposal.md`.** Seed from the Bilbul proposal (`2026 Juvenile gut evac/Proposal/Bilbul_GER_trial_proposal.md`); replace Bilbul-specific sections (cohorts, scope, feed). User-owned authoring.
- **FW-PR-02 — Decide cohort count and weight brackets.** Range: ~200 g – 1.5 kg. Drives pond-selection filter and dissection logistics. Likely resolved during pond shortlisting.
- **FW-PR-03 — Author `docs/reference/pond-selection.md`.** Stanbridge analogue of Bilbul's `cage-selection.md`. Filter logic: weight bracket (per cohort), SFR band (single threshold, all floating), pond oxygen filter (per-pond from `vReportingBaselineInventoryByDay.Oxygen`). All inputs are pond-grain, so the procedure shape mirrors Bilbul's cage-grain shape — a single-pass filter over the 78 ponds.
- **FW-PR-04 — Implement `.claude/skills/select-trial-ponds/`.** Thin wrapper over `pond-selection.md` returning the per-bracket shortlist. Mirrors the Bilbul project's local `/select-trial-cages` skill. Pure code task; defer until pond-selection.md exists.

## During-trial — recordkeeping

- **FW-DT-01 — Define `Data/Stanbridge <date>.xlsx` headers.** Already documented at the column level in [data-shape §1](../domain/data-shape.md#1-trial-recording--the-data-files-that-live-on-sharepoint) (Bilbul shape with `Pond → Cell` and `Cage → Pond` renames). Producing the physical Excel template (binary file) is a 10-minute task post-scaffold: copy `Bilbul/Data/Form template.xlsx`, swap the two header labels, save as `Stanbridge/Data/Form template.xlsx`. Convert to a ticket when the project repo exists.

## Analysis-readiness

- **FW-AN-01 — Audit Stanbridge treatments export.** Confirm Stanbridge UnitIds appear in `vReportingBaselineTreatment.csv`, profile the product mix, decide if treatment proximity should disqualify a pond from selection. See [data-shape §2.4](../domain/data-shape.md#24-treatments--per-pond-dosing-events).

## Downstream consumers

- **FW-DS-01 — Cross-trial comparison with Bilbul.** Both projects use identical methodology (ADRs 0001–0003) and same headline metric. A side-by-side report comparing per-cohort time-to-20%-residual across weight ranges 10–150 g (Bilbul) and 200 g – 1.5 kg (Stanbridge) is a natural follow-up once both trials complete.

## Notes on this list

Conversion rule: when a decision is reached on any FW-* item, delete the entry and file the executable action as a ticket in `.tickets/`.

### Closed during intake

- ~~FW-PR-05 — Validate pre-fast logistics in static ponds with operations.~~ Confirmed during intake; no special accommodation needed.
- ~~FW-AN-02 — Tune oxygen-filter thresholds for cell-grain data.~~ Oxygen is pond-grain at Stanbridge (corrected source: `InventoryByDay.Oxygen`); Bilbul thresholds carry over without adjustment.
- ~~FW-AN-03 — Decide on shared `src/` package.~~ Decision: **copy, do not share.** Stanbridge gets its own `src/stanbridge_ger/` derived from `src/juvenile_ger/`. Resolves when first investigation creates the package.
