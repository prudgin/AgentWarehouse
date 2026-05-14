# CLAUDE.md — 2026 Juvenile gut evac

*This project was scaffolded from the AgenticEngineering warehouse. The warehouse's own `CLAUDE.md` describes the warehouse, not this project — do not load it as authoritative; this file is.*

## Working approach

State your reading of the task before acting. If the task is ambiguous or underspecified, stop and ask rather than guessing. If multiple approaches exist, present tradeoffs — do not pick silently. For multi-step work, outline a brief plan with verification checks before starting.

**Analyse-first.** This is a research project. The default workflow is to start an investigation (`/start-analysis`), do the work in a dated dir, finalise it (`/finish-analysis`), and let findings settle into `glossary.md`, `docs/domain/`, `docs/adr/`, or `docs/planning/future-work.md`. The build chain is available for shippable artefacts (the analysis code itself) but is not the centre of gravity.

## SharePoint mirror

This project is bidirectionally mirrored to `sharepoint_planning:PROJECTS/2026 Juvenile gut evac/`. The local directory and the SharePoint folder hold the same shape, with one exception: code does not push.

- **At session start:** run `/sharepoint-sync pull`. Newer files on SharePoint come down. Trial data (`Data/Bilbul <date>.xlsx`) accumulates on SharePoint as dissection batches are recorded — the pull is what makes that data available locally.
- **At `/finish`:** run `/sharepoint-sync push`. Newer files locally go up — including analysis outputs in `Reports/`, agent docs in `docs/`, and any updates to `glossary.md`, `analysis/`, or `.tickets/`.
- **What syncs:** everything not excluded by `.rclone-filter`. Agent infrastructure (`CLAUDE.md`, `glossary.md`, `docs/`, `.tickets/`, `analysis/`) syncs alongside the human-facing dirs (`Articles/`, `Proposal/`, `Data/`, `Reports/`, `Expenses/`).
- **What does NOT sync:** `src/`, `scripts/`, `output/`, `.git/`, `.venv/`, `.claude/`, `.env`, build artefacts. See `.rclone-filter`.
- **Deletes do not propagate.** `rclone copy --update` only ever transfers — it never removes. To delete a file you must remove it from **both sides explicitly** and document the removal.

See [`/sharepoint-sync`](.claude/skills/sharepoint-sync/SKILL.md) for full mechanics.

## What this project is

**WHAT**: The Bilbul GER (gastric evacuation rate) trial. Three juvenile Murray cod cohorts on their normal Biomar diets — A (10–45 g, 3 mm pellet), B (45–80 g, 4.5 mm), C (80–150 g, 4.5 or 6.5 mm). One cage per cohort, selected via [`docs/reference/cage-selection.md`](docs/reference/cage-selection.md). Pre-trial fast with sentinel-fish validation anchors a clean t=0 (see [ADR-0001](docs/adr/0001-t0-anchor-via-prefast-and-sentinel.md)). One satiation feed, six timepoints × 15 fish per cohort. Per-cohort GER curves fitted across three kinetic families and compared by AIC (see [ADR-0003](docs/adr/0003-three-family-aic-kinetic-comparison.md)). Headline output: **time to 20 % residual stomach dry matter**, in clock-hours and degree-hours, per cohort, with bootstrap CIs.

**WHY**: Design input for an upcoming juvenile feeding-frequency trial — inter-meal spacing chosen from clearance kinetics rather than guesswork. Side outputs (re)used downstream: SFR datapoints from the 270-fish dataset; nematode prevalence/intensity per cohort.

**HOW** — to reproduce a run end-to-end (once data collection is complete):
- Trial data lives at `Data/Bilbul <YYYY-MM-DD>.xlsx` — one file per trial date, one row per (cage × timepoint × fish). Shape and conventions in [`docs/domain/data-shape.md`](docs/domain/data-shape.md).
- Analysis is investigation-driven: `analysis/<YYYY-MM-DD>-<topic>/` holds the campaign's scripts and `INVESTIGATION.md`. Imports shared model code from `src/juvenile_ger/`.
- Stakeholder write-ups land in `Reports/`.

The canonical methods document — drafted by the user before the trial — is [`Proposal/Bilbul_GER_trial_proposal.md`](Proposal/Bilbul_GER_trial_proposal.md). It is the authoritative source for protocol; ADRs in this repo are the per-decision rationale extracts.

## Git conventions

- Remote: none currently — local-only repo. Add later if needed.
- Main branch: `main`.
- Commit messages: imperative tense, describe what the change does.

## Documentation philosophy

Every fact has a single canonical home. Other documents link to it rather than restate it. **No orphans** — every document reachable from this file via a chain of links. CLAUDE.md indexes top-level directories; each top-level directory has a `README.md` that indexes its contents.

CLAUDE.md lists what exists and when to read it. Skills (`.claude/skills/`) wrap procedural workflows. Library (`glossary.md`, `docs/`, `analysis/`) carries declarative knowledge. For a research project the centre of gravity is `analysis/` and `docs/domain/`.

**Findings provenance.** Claims that land in `glossary.md`, `docs/domain/`, or `docs/adr/` link back to the `analysis/<dated>/INVESTIGATION.md` that produced them. Provenance is what keeps the substrate honest as the research evolves.

## Documentation map

### Synced surface (mirrors SharePoint)

- **`Articles/`** — external reference papers (Talbot 2001 piscine feed intake, PGO feed-size chart, YTK methodological critique + model plots).
- **`Proposal/`** — `Bilbul_GER_trial_proposal.md` (the canonical methods document) and `Notes on trial design.docx`.
- **`Data/`** — raw trial recording. One long-form Excel per trial date (`Bilbul YYYY-MM-DD.xlsx`) plus the `Form template.xlsx` field-recording form. Shape in [`docs/domain/data-shape.md`](docs/domain/data-shape.md).
- **`Reports/`** — interim and final reports — the human-facing deliverables.
- **`Expenses/`** — finance / receipts.

### Library (also syncs to SharePoint)

- **[`README.md`](README.md)** — human-facing entry; links back to this file.
- **[`glossary.md`](glossary.md)** — project vocabulary (GER, cohort, t=0, sentinel fish, π non-feeder fraction, residual fraction, K_local, mush, binary clearance curve, Bilbul scope, OM5, SFR band, sinking-vs-floating feed, degree-hours). Read before naming anything.
- **`analysis/YYYY-MM-DD-<topic>/INVESTIGATION.md`** — investigations. **The primary work surface** once data analysis begins.
- **`analysis/analysis-landscape.md`** — narrative across all investigations.
- **[`docs/domain/`](docs/domain/README.md)** — non-vocabulary domain knowledge:
  - [`data-shape.md`](docs/domain/data-shape.md) — trial recording schema + the four Mercatus data streams (temperature, oxygen, treatments, feeding) + 96-cage Bilbul scope.
- **[`docs/reference/`](docs/reference/README.md)** — procedural references:
  - [`cage-selection.md`](docs/reference/cage-selection.md) — the cohort-cage selection procedure used to pick Cohorts A, B, C.
- **[`docs/adr/`](docs/adr/README.md)** — methodological decisions:
  - 0001 — t=0 anchored by pre-fast + sentinel validation.
  - 0002 — Stomach evacuation normalised by t=0 batch mean (non-feeders cancel).
  - 0003 — Per-cohort AIC comparison of three kinetic families.
- **[`docs/planning/future-work.md`](docs/planning/future-work.md)** — open backlog: trial bookkeeping, analysis improvements, downstream consumers, methodology extensions.
- **`.tickets/`** — local issue tracker for concrete code/protocol changes.
- **`.tickets/inbox/`** — incoming cross-repo tickets.

### Local only (excluded from sync)

- **`src/juvenile_ger/`** — shared model code (loaders, kinetic fits, plots) used by the dated investigation campaigns.
- **`scripts/`** — operational scripts. Includes `build_census.py` (Bilbul-wide fish census tool that produced the cohort-pick reference snapshot in `Data/`).
- **`output/`** — generated artefacts (regeneratable).
- **`.git/`, `.venv/`, `.claude/`, `.env`, `pyproject.toml`, `.gitignore`, `.rclone-filter`** — tooling and config.

## Skills

`.claude/skills/<name>/SKILL.md` — procedural workflows. The most-used on this project are `/start-analysis`, `/finish-analysis`, `/sharepoint-sync`, and `/finish` (which runs `/sharepoint-sync push` at the end). The build chain (`/grill`, `/to-prd`, `/to-issues`, `/triage`, `/work-issue`) is available for edits to `src/juvenile_ger/` or `scripts/`. Cross-cutting: `/diagnose`, `/file-cross-repo-ticket`, `/check-inbox`. Skills are symlinks from `~/AgenticEngineering/skills/<name>/`.

## What does NOT belong in CLAUDE.md

Methodology details (the proposal or the relevant INVESTIGATION). Step-by-step procedures (a skill, `docs/reference/`, or `docs/domain/`). Specific findings (the INVESTIGATION they came from, plus a glossary/domain promotion). Anything that applies only to some tasks.

## Update rules

When you change behaviour, update the doc that describes it. A task is not done until the docs match the state of the project.

- **Investigation completed** → finalise `analysis/<date>-<topic>/INVESTIGATION.md` and register in `analysis/analysis-landscape.md`. Promote findings to `glossary.md` / `docs/domain/` / `docs/adr/` / `future-work.md` as applicable. (`/finish-analysis` does this.)
- **Methodology decision passing 3-of-3** → new `docs/adr/NNNN-slug.md`, with provenance link to the INVESTIGATION or proposal section.
- **New domain term resolved** → add to `glossary.md`, with provenance link.
- **New domain mechanic discovered** → add to `docs/domain/`, with provenance link.
- **New trial-recording column or schema change** → update [`docs/domain/data-shape.md`](docs/domain/data-shape.md).
- **Code change in `src/juvenile_ger/`** → keep the relevant `docs/reference/` page in sync.
- **New planned work** → `docs/planning/future-work.md`.
- **Project structure change** → update this file.
- **End of session** → `/finish` (which runs `/sharepoint-sync push` after orphan checks).

## No orphans

Every document reachable from this file via a chain of links. The `/finish` skill sweeps for orphans. Every analysis subdir must be linked from `analysis/analysis-landscape.md`.

## Portability

This file also satisfies AGENTS.md. `AGENTS.md` is a symlink to this file.
