# CLAUDE.md — 2023 Feeding Frequency

*This project was scaffolded from the AgenticEngineering warehouse. The warehouse's own `CLAUDE.md` describes the warehouse, not this project — do not load it as authoritative; this file is.*

## Working approach

State your reading of the task before acting. If the task is ambiguous or underspecified, stop and ask rather than guessing. If multiple approaches exist, present tradeoffs — do not pick silently. For multi-step work, outline a brief plan with verification checks before starting.

**Analyse-first.** This is a research project. The default workflow is to start an investigation (`/start-analysis`), do the work in a dated dir, finalise it (`/finish-analysis`), and let findings settle into `glossary.md`, `docs/domain/`, `docs/adr/`, or `docs/planning/future-work.md`. The build chain is available for shippable artefacts (the analysis code itself) but is not the centre of gravity.

The 2023 re-analysis arc is **already complete and documented** in `docs/domain/methodology-*.md`. Treat those as the canonical writeups. New work should land in `analysis/<date>-<topic>/` dirs.

## SharePoint mirror

This project is bidirectionally mirrored to `sharepoint_planning:PROJECTS/2023 Feeding Frequency/`. The local directory and the SharePoint folder hold the same shape, with one exception: code does not push.

- **At session start:** run `/sharepoint-sync pull`. Newer files on SharePoint come down — chiefly stakeholder docs in `Reports/` or `Proposal/`, or new entries in `Data/raw-mcfarlane-2023/`.
- **At `/finish`:** run `/sharepoint-sync push`. Newer files locally go up — including analysis outputs, updates to `glossary.md`, new `analysis/<date>/INVESTIGATION.md`s, and any `.tickets/` activity.
- **What syncs:** everything not excluded by `.rclone-filter`. Agent infrastructure (`CLAUDE.md`, `glossary.md`, `docs/`, `.tickets/`, `analysis/`) syncs alongside the human-facing dirs (`Articles/`, `Proposal/`, `Data/`, `Reports/`, `Expenses/`).
- **What does NOT sync:** `src/`, `scripts/`, `output/`, `.git/`, `.venv/`, `.claude/`, `.env`, build artefacts. See `.rclone-filter`.
- **Deletes do not propagate.** `rclone copy --update` only ever transfers — it never removes. To delete a file you must remove it from **both sides explicitly** and document the removal.

See [`/sharepoint-sync`](.claude/skills/sharepoint-sync/SKILL.md) for full mechanics.

## What this project is

**WHAT**: Re-analysis of Aquna's 2023 Murray cod feeding-frequency trials at McFarlane's site, anchored to the Nov-2024 `growth_models` SFR/SGR surface. Two parallel trials:
- **Trial 1** (Ponds 1, 3): twice/day vs once/day, 9 weeks.
- **Trial 2** (Ponds 5, 6): every-second-day vs once/day, 7 weeks.

Final cohort: **32 books-clean cages** of 48. Per-trial pooled results: SFR ratio, SGR ratio (vs Nov-2024 model surface), plus a Cross plot (SFR vs SGR) and a pre-trial baseline + extended-window plot that spans pre/trial/post windows. Source documents: `Proposal/Data analysis feeding strategy.xlsx` (the field-trial workbook) and `Reports/Final report McFarlane's_DS.docx` (Deepika Satchithananthan's 2023 original report — this re-analysis differs from its Table 1; see [ADR-0001](docs/adr/0001-trajectory-anchored-endpoint-sgr.md)).

**WHY**: Aquna's operational question — should McFarlane's adopt a non-once-daily regime? The original 2023 report had inconclusive results with single-sample-noise issues. The re-analysis adds: a single canonical books-clean cohort, trajectory-anchored endpoint SGR, model-anchored SFR/SGR comparisons, and a pre-trial baseline cohort separation. **Headline**: T1 treatment (twice/day) modestly over-grows. T2 treatment (alt-day) clearly under-grows — but about half the T2 gap is inherited cohort weakness, only half is regime effect.

**HOW** — to reproduce a run end-to-end:

```bash
PY=/home/rndmanager/PycharmProjects/MercatusDataFeed/.venv/bin/python

# 1. Extract source workbook into Data/*.csv (idempotent)
$PY scripts/extract.py

# 2. Pipeline — only re-run if the live ledger or filters change
$PY -m feeding_frequency_2023.pipeline.build_manifest    # cage → CycleId
$PY -m feeding_frequency_2023.pipeline.build_snapshot    # MDF snapshot
$PY -m feeding_frequency_2023.pipeline.run_fits          # SGR fitting (~5 min, n_jobs=1)

# 3. Analyses (cheap; re-run any time)
$PY -m feeding_frequency_2023.analyses.sgr.run
$PY -m feeding_frequency_2023.analyses.sfr.run
$PY -m feeding_frequency_2023.analyses.cross.run
$PY -m feeding_frequency_2023.analyses.pretrial.run
$PY -m feeding_frequency_2023.analyses.context.plot_do
$PY -m feeding_frequency_2023.analyses.context.plot_treatments
```

The full data pipeline (5 stages) is in [`docs/domain/data-pipeline.md`](docs/domain/data-pipeline.md).

## External dependencies

- **`growth_models`** — `/home/rndmanager/PycharmProjects/GrowthModels/src` (Nov-2024 SFR/SGR surface).
- **MercatusDataFeed (MDF)** — `/home/rndmanager/PycharmProjects/MercatusDataFeed`:
  - venv: `MercatusDataFeed/.venv/bin/python` — what this project runs with.
  - SGR step modules in `MDF/processing.sgr_growth_modelling`.
  - Patched at runtime (forecasting mode — see [ADR-0003](docs/adr/0003-spline-forecasting-mode.md); custom plot styles; trial-window vlines on diagnostic plots). MDF source is not modified.
- **Cycle ledger** — `/mnt/data/mercatus/cycle_ledger/` (read-only). `pipeline/build_snapshot.py` clips into a local copy at `pipeline/ledger_snapshot/`.
- **Raw OData exports** — `/mnt/data/mercatus/raw/odata_exports/` (used by `analyses/context/` only).

## Git conventions

- Remote: none currently — local-only repo. Add later if needed.
- Main branch: `main`.
- Commit messages: imperative tense, describe what the change does.

## Documentation philosophy

Every fact has a single canonical home. Other documents link to it rather than restate it. **No orphans** — every document reachable from this file via a chain of links. CLAUDE.md indexes top-level directories; each top-level directory has a `README.md` that indexes its contents.

CLAUDE.md lists what exists and when to read it. Skills (`.claude/skills/`) wrap procedural workflows. Library (`glossary.md`, `docs/`, `analysis/`) carries declarative knowledge. For a research project the centre of gravity is `analysis/` and `docs/domain/`.

**Findings provenance.** Claims that land in `glossary.md`, `docs/domain/`, or `docs/adr/` link back to the `analysis/<dated>/INVESTIGATION.md` (or `docs/domain/methodology-*.md` writeup) that produced them.

## Documentation map

### Synced surface (mirrors SharePoint)

- **`Articles/`** — external reference papers (currently empty; reserved for future literature).
- **`Proposal/`** — `Data analysis feeding strategy.xlsx` (the source field-trial workbook used as canonical input), `Feeding strategy protocol.docx`, `Twice daily feeding protocol.docx`, `mcfarlane treatment allocation.xlsx`, plus earlier-phase project material (`Feed sheets strategy trial/`, `Feeding strategy project/`).
- **`Data/`** — extracted CSVs (`feed_daily.csv`, `cage_weekly.csv`, `cage_weights.csv`, `pond_weekly.csv`), `schema.md`, and `raw-mcfarlane-2023/` (per-fish raw extracts from 44 monthly workbooks + the comparison-vs-MDF-SharePoint validation). Schema is in [`Data/schema.md`](Data/schema.md).
- **`Reports/`** — `Final report McFarlane's_DS.docx` (Deepika Satchithananthan's 2023 report), `Final report McFarlane's_DS.pdf`, `2026-review/` (recent review materials).
- **`Expenses/`** — finance / receipts.

### Library (also syncs to SharePoint)

- **[`README.md`](README.md)** — human-facing entry; links back to this file.
- **[`glossary.md`](glossary.md)** — project vocabulary (McFarlane's, T1/T2, books-clean cohort, realised vs model SGR/SFR, forecasting mode, P3C4, P6C10, MDF, growth_models, ...). Read before naming anything.
- **`analysis/YYYY-MM-DD-<topic>/INVESTIGATION.md`** — investigations (none yet — the 2026-05 re-analysis is documented in `docs/domain/methodology-*.md` instead; new work goes here).
- **`analysis/analysis-landscape.md`** — narrative across all investigations.
- **[`docs/domain/`](docs/domain/README.md)** — non-vocabulary domain knowledge:
  - [`trial-design.md`](docs/domain/trial-design.md) — pond / cage / regime assignments, weight-check dates, cohort tables, headline results.
  - [`data-pipeline.md`](docs/domain/data-pipeline.md) — 5-stage chain from source workbook to analysis inputs.
  - [`filters-and-drops.md`](docs/domain/filters-and-drops.md) — the filter ladder producing the 32-cage cohort.
  - [`methodology-sgr.md`](docs/domain/methodology-sgr.md) — per-cage realised vs model SGR.
  - [`methodology-sfr.md`](docs/domain/methodology-sfr.md) — daily SFR aggregation + plots.
  - [`methodology-cross.md`](docs/domain/methodology-cross.md) — SFR ratio vs SGR ratio scatter.
  - [`methodology-pretrial.md`](docs/domain/methodology-pretrial.md) — 2-month baseline + extended window.
- **[`docs/adr/`](docs/adr/README.md)** — methodological decisions:
  - 0001 — Trajectory-anchored endpoint SGR.
  - 0002 — Books-clean filter at 9% threshold.
  - 0003 — Spline forecasting mode.
  - 0004 — Hybrid feed source (workbook in-trial, MDF out-of-trial).
- **[`docs/planning/future-work.md`](docs/planning/future-work.md)** — open backlog.
- **`.tickets/`** — local issue tracker for concrete code/protocol changes.
- **`.tickets/inbox/`** — incoming cross-repo tickets.

### Local only (excluded from sync)

- **`src/feeding_frequency_2023/pipeline/`** — `build_manifest.py`, `build_snapshot.py`, `run_fits.py` and the supporting CSV/parquet artefacts (`fits/`, `audits/`, `ledger_snapshot/`, `clean/`, `working/`, `state/`).
- **`src/feeding_frequency_2023/analyses/`** — `_common.py`, `cages_used.csv`, and the per-analysis modules (`sgr/`, `sfr/`, `cross/`, `pretrial/`, `context/`).
- **`scripts/extract.py`** — workbook → CSV extraction script (entry point).
- **`output/`** — generated artefacts (regeneratable).
- **`.git/`, `.venv/`, `.claude/`, `.env`, `pyproject.toml`, `.gitignore`, `.rclone-filter`** — tooling and config.

## Skills

`.claude/skills/<name>/SKILL.md` — procedural workflows. The most-used on this project are `/start-analysis`, `/finish-analysis`, `/sharepoint-sync`, and `/finish` (which runs `/sharepoint-sync push` at the end). The build chain (`/grill`, `/to-prd`, `/to-issues`, `/triage`, `/work-issue`) is available for edits to `src/feeding_frequency_2023/` or `scripts/`. Cross-cutting: `/diagnose`, `/file-cross-repo-ticket`, `/check-inbox`. Skills are symlinks from `~/AgenticEngineering/skills/<name>/`.

**Skills are warehouse-symlinked — do not edit them in place.** Every entry under `.claude/skills/` is an absolute symlink to `~/AgenticEngineering/skills/<name>/`. Editing the SKILL.md (or any file under the linked dir) writes through the symlink and propagates the change to **every other project** that links the same skill. A global `PreToolUse` hook (`~/.claude/hooks/check-symlink-target.sh`) blocks Edit/Write on any symlink whose target lies outside this project root and will surface the safe alternatives:

- **Project-local tweak**: replace the symlink with a copy first — `rm <link>; cp -rL ~/AgenticEngineering/skills/<name> .claude/skills/<name>` — then edit. The project now owns its fork; it will not receive future warehouse improvements to that skill.
- **New skill, this project only**: create a regular directory `.claude/skills/<my-skill>/` (no symlink). No collision.
- **Improvement that should reach every project**: `cd ~/AgenticEngineering/`, edit the canonical source, commit. All linked projects pick up the change automatically.

## What does NOT belong in CLAUDE.md

Methodology details (`docs/domain/methodology-*.md`). Step-by-step procedures (a skill, `docs/domain/`, or `docs/reference/` if one gets created). Specific findings (the methodology doc that produced them; new findings get an INVESTIGATION). Anything that applies only to some tasks.

## Update rules

When you change behaviour, update the doc that describes it. A task is not done until the docs match the state of the project.

- **Investigation completed** → finalise `analysis/<date>-<topic>/INVESTIGATION.md` and register in `analysis/analysis-landscape.md`. Promote findings to `glossary.md` / `docs/domain/` / `docs/adr/` / `future-work.md` as applicable. (`/finish-analysis` does this.)
- **Methodology decision passing 3-of-3** → new `docs/adr/NNNN-slug.md`.
- **New domain term resolved** → add to `glossary.md`.
- **New domain mechanic discovered** → add to `docs/domain/`.
- **Pipeline change (any of build_manifest / build_snapshot / run_fits)** → update [`docs/domain/data-pipeline.md`](docs/domain/data-pipeline.md).
- **Filter / cohort change** → update [`docs/domain/filters-and-drops.md`](docs/domain/filters-and-drops.md) and [`docs/domain/trial-design.md`](docs/domain/trial-design.md) cohort tables.
- **New planned work** → `docs/planning/future-work.md`.
- **Project structure change** → update this file.
- **End of session** → `/finish` (which runs `/sharepoint-sync push` after orphan checks).

## No orphans

Every document reachable from this file via a chain of links. The `/finish` skill sweeps for orphans. Every analysis subdir must be linked from `analysis/analysis-landscape.md`.

## Portability

This file also satisfies AGENTS.md. `AGENTS.md` is a symlink to this file.
