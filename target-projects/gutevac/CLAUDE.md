# CLAUDE.md — gutevac

## Working approach

State your reading of the task before acting. If the task is ambiguous or underspecified, stop and ask rather than guessing. If multiple approaches exist, present tradeoffs — do not pick silently. For multi-step work, outline a brief plan with verification checks before starting.

**Analyse-first.** This is a research project. The default workflow is to start an investigation (`/start-analysis`), do the work in a dated dir, finalise it (`/finish-analysis`), and let findings settle into `glossary.md`, `docs/domain/`, `docs/adr/`, or `docs/planning/future-work.md`. The build chain is available for changes to the analysis pipeline itself (`src/gut_clearance/`) but is not the centre of gravity.

## What this project is

**WHAT**: Research on gut-clearance kinetics in farmed Murray cod, to set a defensible **minimum harvest fasting period**. The pipeline (`src/gut_clearance/`, fed by `data/raw/Data trimmed.xlsx`) fits a two-meal hump model to fraction-of-fish-with-feed observations and produces a fasting-duration lookup table. The deliverable is the external write-up (`reports/`); the pipeline is the working tool.

**WHY**: Pre-harvest fasting is currently set by tradition. This project produces an evidence-based recommendation expressed in degree-hours, so the same number works across temperatures. Stakeholders are operations and quality teams.

**HOW**: To reproduce a run end-to-end:
- Raw inputs live in `data/raw/trials/` — one workbook per trial-pond, in the `meta`/`samples`/`fish` template shape. Add a new trial by copying `data/raw/trials/_template/template_trial.xlsx`.
- Build processed store: `python scripts/build_processed_data.py` regenerates `data/processed/{samples.csv, fish.csv, pond_trial_meta.csv, Data trimmed.xlsx}` (overwrites; never edit by hand).
- Pipeline source: `src/gut_clearance/` (single-module package; submodule split is on the future-work list).
- Run: `python -m gut_clearance` (defaults to reading `data/processed/Data trimmed.xlsx`).
- Outputs land in `output/` (gitignored). The current canonical run is archived under `analysis/2026-04-16-warm-band-fit/`.
- Upstream temperature processing for degree-hours calculation: `scripts/process_temperature.py` (run intermittently when new oxygen reports arrive; the integrated DH values are still hand-pasted into the `samples` sheet — see FW-MA-04).
- Stakeholder write-ups live in `reports/`.

## Git conventions

- Remote: none currently — local-only repo. Add later if needed.
- Main branch: `main`.
- Commit messages: imperative tense, describe what the change does.

## Documentation philosophy

Every fact has a single canonical home. Other documents link to it rather than restate it. **No orphans** — every document is reachable from this file via a chain of links. CLAUDE.md indexes top-level directories; each top-level directory has a `README.md` that indexes its contents.

CLAUDE.md lists what exists and when to read it. Skills (`.claude/skills/`) wrap procedural workflows. Library (`glossary.md`, `docs/`, `analysis/`) carries declarative knowledge. The centre of gravity is `analysis/` and `docs/domain/`.

**Findings provenance.** Claims that land in `glossary.md`, `docs/domain/`, or `docs/adr/` link back to the `analysis/<dated>/REPORT.md` that produced them. Provenance is what keeps the substrate honest as the research evolves.

## Documentation map

- **[`README.md`](README.md)** — human-facing entry; links back to this file.
- **[`data/README.md`](data/README.md)** — how the data store is laid out (`data/raw/trials/` → `data/processed/`) and how to add a new trial.
- **[`glossary.md`](glossary.md)** — domain vocabulary (degree-hours, pond, eating fraction, hump model, samples table, fish table, ...). Read before naming anything.
- **[`analysis/`](analysis/README.md)** — investigations. Each `YYYY-MM-DD-<topic>/` dir holds one investigation's scripts and `REPORT.md`. The primary work surface.
  - **[`analysis/analysis-landscape.md`](analysis/analysis-landscape.md)** — narrative across all investigations.
- **[`docs/domain/`](docs/domain/README.md)** — non-vocabulary domain knowledge:
  - [`model.md`](docs/domain/model.md) — hump model mechanics.
  - [`data-shape.md`](docs/domain/data-shape.md) — master Excel layout, columns, the hard "never recompute DH" rule.
  - [`known-issues.md`](docs/domain/known-issues.md) — model pathologies and data-quality problems to flag in any report.
- **[`docs/adr/`](docs/adr/README.md)** — Architecture Decision Records:
  - 0001 — Divergence from Stage 1 proposal.
  - 0002 — Two-meal hump with binomial likelihood.
  - 0003 — Harvest threshold convention (% of all fish).
- **[`docs/reference/`](docs/reference/README.md)** — how the code works:
  - [`model-spec.md`](docs/reference/model-spec.md) — the operative spec `src/gut_clearance/` implements.
- **[`docs/proposal/`](docs/proposal/README.md)** — Stage 1 proposal, preserved verbatim. See ADR-0001 for the divergence.
- **[`docs/planning/future-work.md`](docs/planning/future-work.md)** — open backlog: data-collection priorities, analysis improvements, operational reviews.
- **[`reports/`](reports/README.md)** — stakeholder deliverables (interim pptx, current docx). Tracked.
- **[`.tickets/`](.tickets/README.md)** — local issue tracker for concrete code/protocol changes.
- **[`.tickets/inbox/`](.tickets/inbox/)** — incoming cross-repo tickets.
- **[`archive/`](archive/README.md)** — superseded methods (peasant, earlier hump). Kept for provenance.

## Skills

`.claude/skills/<name>/SKILL.md` — procedural workflows. Most-used pair on this project: `/start-analysis` and `/finish-analysis`. Symlink from `~/AgenticEngineering/skills/<name>` to install warehouse skills.
**Skills are warehouse-symlinked — do not edit them in place.** Every entry under `.claude/skills/` is an absolute symlink to `~/AgenticEngineering/skills/<name>/`. Editing the SKILL.md (or any file under the linked dir) writes through the symlink and propagates the change to **every other project** that links the same skill. A global `PreToolUse` hook (`~/.claude/hooks/check-symlink-target.sh`) blocks Edit/Write on any symlink whose target lies outside this project root and will surface the safe alternatives:

- **Project-local tweak**: replace the symlink with a copy first — `rm <link>; cp -rL ~/AgenticEngineering/skills/<name> .claude/skills/<name>` — then edit. The project now owns its fork; it will not receive future warehouse improvements to that skill.
- **New skill, this project only**: create a regular directory `.claude/skills/<my-skill>/` (no symlink). No collision.
- **Improvement that should reach every project**: `cd ~/AgenticEngineering/`, edit the canonical source, commit. All linked projects pick up the change automatically.

## What does NOT belong in CLAUDE.md

Methodology details (`docs/domain/` or the relevant REPORT). Step-by-step procedures (a skill or `docs/reference/`). Specific findings (the REPORT they came from, plus a glossary/domain promotion). Anything that applies only to some tasks.

## Update rules

When you change behaviour, update the doc that describes it. A task is not done until the docs match the state of the project.

- **Investigation completed** → finalise `analysis/<date>-<topic>/REPORT.md` and register in `analysis/analysis-landscape.md`. Promote findings to `glossary.md` / `docs/domain/` / `docs/adr/` / `future-work.md` as applicable. (`/finish-analysis` does this.)
- **Methodology decision passing 3-of-3** → new `docs/adr/NNNN-slug.md`, with provenance link to the REPORT.
- **New domain term resolved** → add to `glossary.md`, with provenance link.
- **New domain mechanic discovered** → add to `docs/domain/`, with provenance link.
- **Code change in `src/gut_clearance/`** → update `docs/reference/model-spec.md` if the model behaviour changed.
- **New planned work** → `docs/planning/future-work.md`.
- **Project structure change** → update this file.

## No orphans

Every document reachable from this file via a chain of links. The `/finish` skill (when installed) sweeps for orphans. Every analysis subdir must be linked from `analysis/analysis-landscape.md`.

## Portability

This file also satisfies AGENTS.md. `AGENTS.md` is a symlink to this file.
