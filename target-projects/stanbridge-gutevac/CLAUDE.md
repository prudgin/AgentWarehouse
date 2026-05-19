# CLAUDE.md — 2026 Stanbridge gut evac

*This project was scaffolded from the AgenticEngineering warehouse. The warehouse's own `CLAUDE.md` describes the warehouse, not this project — do not load it as authoritative; this file is.*

## Working approach

State your reading of the task before acting. If the task is ambiguous or underspecified, stop and ask rather than guessing. If multiple approaches exist, present tradeoffs — do not pick silently. For multi-step work, outline a brief plan with verification checks before starting.

**Analyse-first.** This is a research project. The default workflow is to start an investigation (`/start-analysis`), do the work in a dated dir, finalise it (`/finish-analysis`), and let findings settle into `glossary.md`, `docs/domain/`, `docs/adr/`, or `docs/planning/future-work.md`. The build chain is available for shippable artefacts (the analysis code itself) but is not the centre of gravity.

## SharePoint mirror

This project is bidirectionally mirrored to `sharepoint_planning:PROJECTS/2026 Stanbridge gut evac/`. The local directory and the SharePoint folder hold the same shape, with one exception: code does not push.

- **At session start:** run `/sharepoint-sync pull`. Newer files on SharePoint come down. Trial data (`Data/Stanbridge <date>.xlsx`) accumulates on SharePoint as dissection batches are recorded — the pull is what makes that data available locally.
- **At `/finish`:** run `/sharepoint-sync push`. Newer files locally go up — including analysis outputs in `Reports/`, agent docs in `docs/`, and any updates to `glossary.md`, `analysis/`, or `.tickets/`.
- **What syncs:** everything not excluded by `.rclone-filter`. Agent infrastructure (`CLAUDE.md`, `glossary.md`, `docs/`, `.tickets/`, `analysis/`) syncs alongside the human-facing dirs (`Articles/`, `Proposal/`, `Data/`, `Reports/`, `Expenses/`).
- **What does NOT sync:** `src/`, `scripts/`, `output/`, `.git/`, `.venv/`, `.claude/`, `.env`, build artefacts. See `.rclone-filter`.
- **Deletes do not propagate.** `rclone copy --update` only ever transfers — it never removes. To delete a file you must remove it from **both sides explicitly** and document the removal.

See [`/sharepoint-sync`](.claude/skills/sharepoint-sync/SKILL.md) for full mechanics.

## What this project is

**WHAT**: The Stanbridge GER (gastric evacuation rate) trial. Stanbridge-cohorts of Murray cod on grow-out feed, weights spanning ~200 g to ~1.5 kg, drawn from the 78 ongrowing ponds at the Stanbridge site (6 cells, all `AreaCode == 'STA'`). Cohort count and exact weight brackets resolved during pond selection. One pond per cohort. Pre-trial fast with sentinel-fish validation anchors a clean t=0 (see [ADR-0001](docs/adr/0001-t0-anchor-via-prefast-and-sentinel.md)). One satiation feed, six timepoints × 15 fish per cohort. Per-cohort GER curves fitted across three kinetic families and compared by AIC (see [ADR-0003](docs/adr/0003-three-family-aic-kinetic-comparison.md)). Headline output: **time to 20 % residual stomach dry matter**, in clock-hours and degree-hours, per cohort, with bootstrap CIs.

**WHY**: Design input for a future Stanbridge-side feeding-frequency trial — inter-meal spacing chosen from clearance kinetics rather than guesswork. **Complementary** to the sibling Bilbul GER trial (`2026 Juvenile gut evac`) at 10–150 g — together the two projects cover the juvenile-through-ongrowing weight range with directly-comparable methodology. **Not** a pre-harvest fasting trial (that's the unrelated `2026 Gut Clearance` project; its goal and method differ).

**HOW** — to reproduce a run end-to-end (once data collection is complete):
- Trial data lives at `Data/Stanbridge <YYYY-MM-DD>.xlsx` — one file per trial date, one row per (pond × timepoint × fish). Shape and conventions in [`docs/domain/data-shape.md`](docs/domain/data-shape.md).
- Analysis is investigation-driven: `analysis/<YYYY-MM-DD>-<topic>/` holds the campaign's scripts and `INVESTIGATION.md`. Imports shared model code from `src/stanbridge_ger/` (or a shared package — see [FW-AN-03](docs/planning/future-work.md)).
- Stakeholder write-ups land in `Reports/`.

The canonical methods document — to be drafted by the user before the trial — is [`Proposal/Stanbridge_GER_trial_proposal.md`](Proposal/Stanbridge_GER_trial_proposal.md). Authoring is tracked as [FW-PR-01](docs/planning/future-work.md). Once drafted, it is the authoritative source for protocol; ADRs in this repo are the per-decision rationale extracts.

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

- **`Articles/`** — external reference papers (Talbot 2001 piscine feed intake, YTK methodological critique + model plots, anything Stanbridge-specific staged later).
- **`Proposal/`** — `Stanbridge_GER_trial_proposal.md` (the canonical methods document, to be authored — [FW-PR-01](docs/planning/future-work.md)).
- **`Data/`** — raw trial recording. One long-form Excel per trial date (`Stanbridge YYYY-MM-DD.xlsx`) plus the `Form template.xlsx` field-recording form. Shape in [`docs/domain/data-shape.md`](docs/domain/data-shape.md).
- **`Reports/`** — interim and final reports — the human-facing deliverables.
- **`Expenses/`** — finance / receipts.

### Library (also syncs to SharePoint)

- **[`README.md`](README.md)** — human-facing entry; links back to this file.
- **[`glossary.md`](glossary.md)** — project vocabulary (GER, cohort, t=0, sentinel fish, π non-feeder fraction, residual fraction, K_local, mush, binary clearance curve, Stanbridge scope, OM5, SFR band, degree-hours). Read before naming anything.
- **`analysis/YYYY-MM-DD-<topic>/INVESTIGATION.md`** — investigations. **The primary work surface** once data analysis begins.
- **`analysis/analysis-landscape.md`** — narrative across all investigations.
- **[`docs/domain/`](docs/domain/README.md)** — non-vocabulary domain knowledge:
  - [`data-shape.md`](docs/domain/data-shape.md) — trial recording schema + Mercatus data streams (Stanbridge scope 78 ponds, per-pond temperature, **cell-level oxygen** with uneven coverage).
- **`docs/reference/`** — OPTIONAL, created on-demand. Planned first entry: `pond-selection.md` ([FW-PR-03](docs/planning/future-work.md)).
- **[`docs/adr/`](docs/adr/README.md)** — methodological decisions:
  - 0001 — t=0 anchored by pre-fast + sentinel validation (inherited from Bilbul sibling).
  - 0002 — Stomach evacuation normalised by t=0 batch mean (inherited from Bilbul sibling).
  - 0003 — Per-cohort AIC comparison of three kinetic families (inherited from Bilbul sibling).
- **[`docs/planning/future-work.md`](docs/planning/future-work.md)** — open backlog: pre-trial deferrals, recordkeeping, analysis-readiness, downstream consumers.
- **`.tickets/`** — local issue tracker for concrete code/protocol changes.
- **`.tickets/inbox/`** — incoming cross-repo tickets.

### Local only (excluded from sync)

- **`src/`** (e.g. `src/stanbridge_ger/`) — shared model code (loaders, kinetic fits, plots) used by the dated investigation campaigns. Created on demand.
- **`scripts/`** — operational scripts. Created on demand.
- **`output/`** — generated artefacts (regeneratable).
- **`.git/`, `.venv/`, `.claude/`, `.env`, `pyproject.toml`, `.gitignore`, `.rclone-filter`** — tooling and config.

## Skills

`.claude/skills/<name>/SKILL.md` — procedural workflows. The most-used on this project are `/start-analysis`, `/finish-analysis`, `/sharepoint-sync`, and `/finish` (which runs `/sharepoint-sync push` at the end). The build chain (`/grill`, `/to-prd`, `/to-issues`, `/triage`, `/work-issue`) is available for edits to `src/` or `scripts/`. Cross-cutting: `/diagnose`, `/file-cross-repo-ticket`, `/check-inbox`.

**Skills are warehouse-symlinked — do not edit them in place.** Every entry under `.claude/skills/` is an absolute symlink to `~/AgenticEngineering/skills/<name>/`. Editing the SKILL.md (or any file under the linked dir) writes through the symlink and propagates the change to **every other project** that links the same skill. A global `PreToolUse` hook (`~/.claude/hooks/check-symlink-target.sh`) blocks Edit/Write on any symlink whose target lies outside this project root and will surface the safe alternatives:

- **Project-local tweak**: replace the symlink with a copy first — `rm <link>; cp -rL ~/AgenticEngineering/skills/<name> .claude/skills/<name>` — then edit. The project now owns its fork; it will not receive future warehouse improvements to that skill.
- **New skill, this project only**: create a regular directory `.claude/skills/<my-skill>/` (no symlink). No collision.
- **Improvement that should reach every project**: `cd ~/AgenticEngineering/`, edit the canonical source, commit. All linked projects pick up the change automatically.

**Planned project-local skills** (real files under `.claude/skills/`, not symlinks from the warehouse):

- **`/select-trial-ponds`** — pick "normally performing" Stanbridge ponds for a trial from the Mercatus published parquets and OData exports. Thin wrapper over `docs/reference/pond-selection.md`. Both that doc and this skill are deferred until pond-selection logic is authored — see [FW-PR-03 and FW-PR-04](docs/planning/future-work.md).

## What does NOT belong in CLAUDE.md

Methodology details (the proposal or the relevant INVESTIGATION). Step-by-step procedures (a skill, `docs/reference/`, or `docs/domain/`). Specific findings (the INVESTIGATION they came from, plus a glossary/domain promotion). Anything that applies only to some tasks.

## Update rules

When you change behaviour, update the doc that describes it. A task is not done until the docs match the state of the project.

- **Investigation completed** → finalise `analysis/<date>-<topic>/INVESTIGATION.md` and register in `analysis/analysis-landscape.md`. Promote findings to `glossary.md` / `docs/domain/` / `docs/adr/` / `future-work.md` as applicable. (`/finish-analysis` does this.)
- **Methodology decision passing 3-of-3** → new `docs/adr/NNNN-slug.md`, with provenance link to the INVESTIGATION or proposal section. Sequential numbering from 0004 (0001–0003 are inherited).
- **New domain term resolved** → add to `glossary.md`, with provenance link.
- **New domain mechanic discovered** → add to `docs/domain/`, with provenance link.
- **New trial-recording column or schema change** → update [`docs/domain/data-shape.md`](docs/domain/data-shape.md).
- **Code change in `src/`** → keep the relevant `docs/reference/` page in sync.
- **New planned work** → `docs/planning/future-work.md`.
- **Project structure change** → update this file.
- **End of session** → `/finish` (which runs `/sharepoint-sync push` after orphan checks).

## No orphans

Every document reachable from this file via a chain of links. The `/finish` skill sweeps for orphans. Every analysis subdir must be linked from `analysis/analysis-landscape.md`.

## Portability

This file also satisfies AGENTS.md. `AGENTS.md` is a symlink to this file.
