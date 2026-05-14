# Intake notes — juvenile

Session: 2026-05-14. First of three sibling FeedingFrequency projects to migrate.

## Audit of source repo `/home/rndmanager/PycharmProjects/FeedingFrequency/Juvenile`

**Tree** (full — small repo):
```
Juvenile/
├── CLAUDE.md                                          (461 lines)
└── BilbulFishCensus/
    ├── Bilbul_fish_census_2026-05-04.xlsx
    └── build_census.py                                (~275 lines)
```

No git history. No `glossary.md`, no `docs/`, no `.tickets/`, no `.claude/`. The repo is essentially **one big CLAUDE.md plus one tool**.

### What `CLAUDE.md` contains (knowledge-dense)

Title: "Juvenile project — scope convention". It functions as a single-document mini-substrate covering:

1. **Canonical scope.** Bilbul juvenile farm = 12 ponds × 8 cages = 96 grow-out units. Hierarchy (Operation `JU`, Region `JR`, Area `BIL`, SiteIds `B01`-`B12`, UnitIds 803-898 contiguous). Cycle ledger pre-curated (`AreaCode == 'BIL'` yields exactly 96). All dates Sydney local.
2. **Four in-scope data streams**, each with canonical loader:
   - Temperature (pond-grain, daily) from `cycle_ledger/cycle_days.parquet`.
   - Oxygen (`OM5` mg/L, pond-grain) from raw OData `vReportingBaselineEnvironment.csv` at `Level == "Cluster"`. Pond→ClusterId mapping `B0x → x*1,000,000 + 4,000,000`. Audit 2026-05-08: 2024-05-03 onward, 96-99 % daily fill.
   - Treatments (cage-grain) from `vReportingBaselineTreatment.csv`. 22,467 in-scope rows; products in active use 2024-2026 enumerated; columns to use vs ignore enumerated.
   - Feeding from `cycle_ledger/cycle_feedings.parquet`. Important domain note: **sinking vs floating feed** — cages with fish <50 g get sinking feed with non-trivial waste, biasing `actual/expected` SFR ratios upward; wider acceptance band for sub-50 g cages.
3. **Cage selection for trials.** Full procedure with knob defaults, filter order, and reference implementation (~100 lines of Python). Used "to pick one cage per size bracket for a feeding-frequency trial". Inputs: brackets `[(10,45),(45,80),(80,150)]`, `window_days=14`, exclude_products={Formalin, Copper sulphate}, O2 thresholds, min feed days, SFR band per weight bracket.

### What `BilbulFishCensus/build_census.py` does

A standalone tool that reads MercatusDataFeed's published parquets (`/mnt/data/mercatus/cycle_ledger/units.parquet`, and `MercatusDataFeed/data/processed/clean/vReportingBaselineInventoryByDay.parquet`) and emits an Excel workbook splitting all Bilbul fish into SFR-balanced weight bands (`[0,10,15,23,40,70,150]` g — equal-SFR spacing at 18 °C). Three sheets: printable by-size view, flat cage data, bucket summary. CLI: `python build_census.py [--date YYYY-MM-DD] [--out DIR]`.

This appears to be an **operational tool** — produces a stakeholder-facing Excel snapshot. It is NOT analysis output; it's a reusable utility.

## Resolved

- **Q1 — Project identity.** This project IS the **2026 Juvenile gut evac trial**. The existing local CLAUDE.md is *not* the project's CLAUDE.md — user described it as "just basically a skill for Claude to retrieve data and select ponds from Bilbul for sampling". SharePoint folder name `2026 Juvenile gut evac` stays as-is (no rename).
- **Q2 — Where the existing 461-line CLAUDE.md content goes.** Option (c): split into project-local declarative docs (NOT a warehouse skill, NOT a project-local skill). Targets:
  - `glossary.md` — terms (pond, cage, UnitId range 803-898, OM5, Bilbul, SFR band, sinking-vs-floating-feed, ...).
  - `docs/domain/data-shape.md` — canonical scope + the four data-stream loaders (temperature, oxygen, treatments, feeding).
  - `docs/reference/cage-selection.md` — the §5 cage-selection procedure (knobs, filter order, reference impl).
  - Note: sibling projects (FeedingFrequency2023, FrequencyRAS) may need parallel content — they'll get their own copies, not shared via a warehouse skill.
- **Q3 — Name & path.**
  - Project name (verbatim, used for both SharePoint folder and local dir): `2026 Juvenile gut evac`.
  - Local target: `~/ResearchProjects/2026 Juvenile gut evac/`.
  - No SharePoint rename. Subfolder conversions (`Articles and background/` → `Articles/` etc.) TBD pending first `sharepoint-sync pull`.

## SharePoint contents (pulled 2026-05-14)

```
2026 Juvenile gut evac/
├── Articles and background/
│   ├── Aquaculture Research - 2001 - Talbot - Pattern of feed intake in four species of fish under commercial farming conditions .pdf
│   ├── PGO - 039 Feed size chart-1.pdf
│   ├── YTK_feeding_relevant_chapters.pdf
│   ├── YTK_methodological_critique.pdf
│   └── YTK_model_plots.pdf
├── Data/
│   ├── Bilbul 12-05-2026.xlsx
│   └── Form template.xlsx
├── Expenses/                       (empty)
├── Proposal/
│   ├── Bilbul_GER_trial_proposal.md
│   └── Notes on trial design.docx
└── Report/                         (empty)
```

Subfolder mismatches vs the research template:
- `Articles and background/` → `Articles/`  (rename — same convention as gutevac).
- `Report/` → `Reports/`  (rename — same convention as gutevac).

## Project framing (from `Proposal/Bilbul_GER_trial_proposal.md`)

- **WHAT**: Estimate gastric evacuation rate (GER) of Murray cod across three juvenile size cohorts (A: 10–45 g on 3 mm pellet, B: 45–80 g on 4.5 mm, C: 80–150 g on 4.5/6.5 mm), and derive **time-to-20%-residual stomach dry matter** for each. Cohorts match the §5 cage-selection brackets exactly — the existing cage-selection procedure IS the cohort-selection procedure.
- **Design**:
  - Pre-trial fast (~48/72/96 h scaled for temp) with sentinel-fish validation (`<0.05 % BW dry matter` empty threshold). Slack day in schedule for fast extension.
  - One test feed to satiation at t=0. Six timepoints per cohort × 15 fish = 270 fish total.
  - Per fish: length, weight, K, stomach empty Y/N, pellet count, mush Y/N, intestine Y/N, nematode count.
  - Per batch (15-fish pool): wet weight + dry weight to constant mass.
  - Known constants: 3 mm pellet ≈ 16 mg dry, 4.5 mm ≈ 73 mg, 6.5 mm TBD.
- **Analysis**:
  - Normalisation by t=0 batch mean — non-feeder fraction π cancels in numerator/denominator.
  - Three model families compared by AIC: **exponential** (current-contents proportional), **square-root** (surface-area proportional, bolus erosion), **power/Andersen** (3-param flexible).
  - Diagnostic: K_local from successive intervals — flat ⇒ first-order; trending ⇒ not exponential.
  - Bootstrap CI on **t at 20 % residual**, in clock-hours AND degree-hours.
  - Side: binary stomach/intestine clearance curves (Apr 2026 report style; stomach fit as `P(empty | t) = π + (1−π)·F_evac(t)`). Nematode prevalence + intensity per cohort.
- **Comparison to 2026 Gut Clearance (sibling project)**:
  - Apr 2026 work used opportunistic harvest-window design, whole-pond fasts, assumed single sigmoid form. Contaminated t=0 by yesterday's meal.
  - This trial: controlled t=0 anchor via pre-fast + sentinel; isolates rate from intake variance via normalisation; **tests** the kinetic family rather than assuming first-order.
- **Status**: **Trial in flight.** Proposal status says "Draft for internal review" but data collection started 2026-05-12. `Data/Bilbul 12-05-2026.xlsx` is the real trial dataset (275 fish rows so far). First cohort (cage Pond 8 Cage 1, ~Cohort C weight range 53-151 g) has data at t=0 (12 May 08:00) and at least one post-feed timepoint (13 May 04:00, ~20 h post-feed). Treat the proposal as the canonical methods document; data collection is in progress.
- **Data shape (`Bilbul 12-05-2026.xlsx`)**: 22 columns — Farm, Pond, Cage, Date/Time last fed, Date/Time harvested, Date/Time dissected, Fish number, Length cm, Weight g, K index, Pellets count in stomach, Wet weight in stomach, Feed in stomach Y/N, Batch wet weight, Batch dry weight, Feed in intestine Y/N, Nematode count, pellet size mm, pellet weight. Per-fish observations + batch wet/dry weights filled at later timepoints (none at t=0 since the proposal says count pellets while distinct, no batch dry-matter until mush stage).
- **Form template**: `Data/Form template.xlsx` is the per-cohort data-recording form (30 fish rows × 8 cols + batch metadata header). Maps to the long-form `Bilbul <date>.xlsx` via cage+timepoint keys.
- **Stakeholders / operational why**: **Design input for a future juvenile feeding-frequency trial.** If we establish the time-to-20%-residual per cohort, we can then run a feeding-frequency trial with inter-meal spacing chosen from clearance kinetics rather than guesswork. Side outputs (SFR datapoints, nematode survey) are reused independently. This explains why the project sat under `~/PycharmProjects/FeedingFrequency/` locally — it's the kinetics anchor of a broader feeding-frequency program. Cross-link to the eventual feeding-frequency project (sibling staging dir TBD).
- **Cohort scope**: warm-water only (Bilbul). Cold-water extension explicitly deferred.

## Glossary seeds (to draft)

From proposal + scope CLAUDE.md:
- **GER** (gastric evacuation rate). Distinguish from "gut clearance" (whole-gut). Sibling project `2026 Gut Clearance` uses different terminology — note relationship.
- **Cohort** (A/B/C — one cage per size bracket).
- **t=0**, **sentinel fish**, **operational empty threshold** (<0.05 % BW dry matter, or <2 intact-pellet equivalents).
- **K_local** (local first-order rate, diagnostic).
- **Residual fraction** y_rel(t) = batch_dry(t) / batch_dry(0).
- **Non-feeder fraction π**.
- **Pellet count cross-check** (pellet-count × known pellet dry weight as independent per-fish DM estimate while pellets remain countable, i.e. no mush).
- **Mush** (point at which pellet count becomes unreliable).
- **Binary clearance curve** (% fish with feed in stomach / intestine vs time).
- **Bilbul**, **pond**, **cage**, **UnitId range 803-898**, **OM5** — from scope CLAUDE.md.
- **SFR band**, **sinking-vs-floating-feed cutoff (~50 g)** — from scope CLAUDE.md.

## ADR candidates (3-of-3 admission test)

- Normalisation by t=0 batch mean (instead of explicit non-feeder subtraction). Reason: simpler analysis, avoids per-fish feed/no-feed classification. Trade-off: requires π stable across timepoint samples — explicit assumption.
- Three-family AIC model comparison (vs. assuming first-order). Reason: Apr 2026 work assumed a sigmoid and the hump was artefactual — this trial is explicit about testing kinetic form.
- Pre-trial fast + sentinel validation of t=0 (vs. opportunistic harvest-window). Reason: Apr 2026's biggest source of error was contaminated t=0. This is the major methodological departure.
- 20 %-residual endpoint convention (vs. 5 % or 50 %). Reason: TBD — proposal uses it without justifying; ask the user.

## Open alignment questions
2. **Final project name (Title Case).** Template requires `YYYY <Title Case Name>` matching SharePoint verbatim. SharePoint currently is `2026 Juvenile gut evac` (mixed case). Options: rename SharePoint to canonical Title Case e.g. `2026 Juvenile Gut Evac`, or keep verbatim. Recommend rename (consistent with the `2026 Gut clearence → 2026 Gut Clearance` precedent set in the gutevac migration).
3. **Local target path.** Research template lives under `~/ResearchProjects/<Project Name>/`. Current is `~/PycharmProjects/FeedingFrequency/Juvenile`. Sibling `FrequencyRAS` and `FeedingFrequency2023` would each move similarly. The `FeedingFrequency/` parent dir effectively disappears (no project lives at that level).
4. **Tooling relocation.** Where does `BilbulFishCensus/build_census.py` belong? Options: keep under this project as `src/<package>/...`, or extract to a separate utility repo since the same census likely serves the sibling projects too.
5. **Scope/loaders document.** The 461-line CLAUDE.md is currently a Frankenstein of "what is this project" + "Bilbul scope reference" + "canonical loaders" + "cage-selection procedure". Under warehouse conventions these split into glossary entries (Bilbul, pond, cage, UnitId range, OM5, sinking vs floating feed, SFR band, ...), domain docs (`docs/domain/data-shape.md` for loaders, `docs/domain/cage-selection.md` for the trial-selection procedure or `docs/reference/cage-selection.md` if treated as utility), ADRs (sinking-vs-floating wider-band convention?), and a much shorter project-level CLAUDE.md.
6. **Reuse across siblings.** The Bilbul scope + loaders are clearly project-spanning (FrequencyRAS likely needs the same loaders for a RAS scope; FeedingFrequency2023 is historical). Should this material live in a **shared library** rather than be duplicated three times? Probably yes — possibly a new project that the three trials all depend on. (This is the biggest architectural question and deserves a decision before staging too much content.)
7. **`AreaCode == 'BIL'` assumption.** The scope CLAUDE.md says the ledger is already curated such that `AreaCode == 'BIL'` yields exactly the 96 grow-out cages. This is a load-bearing data-shape claim that should land in `docs/domain/` with provenance.

(More questions will be raised inline during the interview.)
