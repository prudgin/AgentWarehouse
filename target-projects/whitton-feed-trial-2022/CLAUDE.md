# CLAUDE.md — 2022 Whitton Feed Trial

*This project was scaffolded from the AgenticEngineering warehouse. The warehouse's own `CLAUDE.md` describes the warehouse, not this project — do not load it as authoritative; this file is.*

## Working approach

State your reading of the task before acting. If the task is ambiguous or underspecified, stop and ask rather than guessing. If multiple approaches exist, present tradeoffs — do not pick silently. For multi-step work, outline a brief plan with verification checks before starting.

**Analyse-first.** This is a research project. The default workflow is to start an investigation (`/start-analysis`), do the work in a dated dir, finalise it (`/finish-analysis`), and let findings settle into `glossary.md`, `docs/domain/`, `docs/adr/`, or `docs/planning/future-work.md`. The build chain is available for shippable artefacts but is not the centre of gravity.

## SharePoint mirror

This project is bidirectionally mirrored to `sharepoint_planning:PROJECTS/2022 Whitton Feed Trial/`. The local directory and the SharePoint folder hold **the same shape**, with one exception: code does not push.

- **At session start:** run `/sharepoint-sync pull`. Newer files on SharePoint come down.
- **At `/finish`:** run `/sharepoint-sync push`. Newer files locally go up.
- **What syncs:** everything not excluded by `.rclone-filter`. Agent infrastructure (`CLAUDE.md`, `glossary.md`, `docs/`, `.tickets/`, `analysis/`) syncs alongside the human-facing dirs (`Articles/`, `Proposal/`, `Data/`, `Reports/`, `Expenses/`). Another agent picking up the SharePoint folder gets the full project context.
- **What does NOT sync:** `src/`, `scripts/`, `output/`, `.git/`, `.venv/`, `.claude/`, `.env`, build artefacts. See `.rclone-filter`.
- **Deletes do not propagate.** `rclone copy --update` only ever transfers — it never removes. To delete a file from the project, you must remove it from **both sides explicitly**. The skill refuses to do deletions; do them by hand and document them in the relevant ticket or INVESTIGATION.

See [`/sharepoint-sync`](.claude/skills/sharepoint-sync/SKILL.md) for full mechanics, conflict behaviour, and recovery.

## What this project is

**WHAT**: Whitton-site companion to the 2021 Feed Trial Marine vs Non Marine vs LAP — testing the same Hayashikane / Biomar / Ridley diet panel at the Whitton ponds over June–October 2022. Records monthly biomass, modelled density at stocking, feed consumption, and condition scoring at three timepoints (initial May, mid 4461_001, final October).

**WHY**: Whitton's pond environment differs from Bilbul (water source, temperature regime, stocking history); the Whitton run validates that the 2021 Bilbul findings replicate under a different production context.

**HOW**:
- Proposal: `Proposal/MCA whitton feed trial.docx` and `Proposal/MCA project proposal_Feed Trial 2021_22_(07.04.22).docx`.
- Hayashikane trial dataset: `Data/Hayashikane Feed Trials 2021-03.xlsx`.
- Main trial dataset: `Data/Whitton Feed Trial 2022 June -October.xlsx`, `Data/Whitton Feed Trial 2022 June -October TD 22_11_22 Trent.xlsx` (Trent's annotated copy).
- Condition scoring: `Data/Condition scores whitton recording sheet.xlsx`, `Data/Whitton condition scores initial - May 22.xlsx`, `Data/Whitton condition scores final - October 22.xlsx`.
- Final report: `Reports/MCA_Final Feed Trial Report_Haya_Biomar & Ridley (20.03.23)[77].pdf`, `Reports/MCA_Final Feed Trial Report_Haya_Biomar & Ridley (20.03.23)[97].pdf`.
- Pond stocking: `Data/pond stocking wp9, wp10.xlsx`, `Data/modelled biomass and density  31-5-22.xlsx`.
- Feed-specs reference: `Articles/hyashikane trial feed specs.pdf`.

## Git conventions

- Remote: none currently — local-only repo. Add later if needed.
- Main branch: `main`
- Commit messages: imperative tense.

## Documentation philosophy

Every fact has a single canonical home. Other documents link to it rather than restate it. **No orphans** — every document reachable from this file via a chain of links. CLAUDE.md indexes top-level directories; each top-level directory has a `README.md` that indexes its contents.

CLAUDE.md lists what exists and when to read it. Skills (`.claude/skills/`) wrap procedural workflows. Library (`glossary.md`, `docs/`, `analysis/`) carries declarative knowledge. For a research project the centre of gravity is `analysis/` and `docs/domain/`.

**Findings provenance.** Claims that land in `glossary.md`, `docs/domain/`, or `docs/adr/` link back to the `analysis/<dated>/INVESTIGATION.md` that produced them. Provenance is what keeps the substrate honest as the research evolves.

## Documentation map

### Synced surface (mirrors SharePoint)

- **`Articles/`** — external reference papers, related literature.
- **`Proposal/`** — grant and stage proposals; the project's "why" as written for stakeholders.
- **`Data/`** — raw and processed data. Date-range subdirs (e.g. `13-02-2026 to 26-02-2026/`) are the existing convention for time-series experiments.
- **`Reports/`** — interim and final reports (DOCX, PPTX, PDF) — the human-facing deliverables.
- **`Expenses/`** — finance / receipts.

### Library (also syncs to SharePoint, no shame in it)

- **`README.md`** — human-facing entry; links back to this file.
- **`glossary.md`** — domain ubiquitous language. Read before naming anything.
- **`analysis/YYYY-MM-DD-<topic>/INVESTIGATION.md`** — investigations. **The primary work surface.** Each dated dir holds the scripts and the canonical writeup.
- **`analysis/analysis-landscape.md`** — narrative across all investigations.
- **`docs/domain/`** — non-vocabulary domain knowledge: model mechanics, data shape, known issues. Promoted from INVESTIGATION findings via `/finish-analysis`.
- **`docs/adr/`** — Architecture Decision Records (e.g. methodological choices). 3-of-3 admission test.
- **`docs/reference/`** — OPTIONAL. Used only if the project grows first-party utility code worth a module-level writeup.
- **`docs/planning/`** — open backlog (`future-work.md`) and the boundary rule vs. `.tickets/`.
- **`.tickets/`** — local issue tracker.
- **`.tickets/inbox/`** — incoming cross-repo tickets.

### Local only (excluded from sync)

- **`src/`, `scripts/`** — code.
- **`output/`** — generated artefacts (regeneratable).
- **`.git/`, `.venv/`, `.claude/`, `.env`, `pyproject.toml`, `.gitignore`, `.rclone-filter`** — tooling and config.

## Skills

`.claude/skills/<name>/SKILL.md` — procedural workflows. The most-used skills on a research project are `/start-analysis`, `/finish-analysis`, `/sharepoint-sync`, and `/finish` (which calls `/sharepoint-sync push` at the end). Symlink from `~/AgenticEngineering/skills/<name>` to install warehouse skills.

## What does NOT belong in CLAUDE.md

Methodology details (`docs/domain/` or the relevant INVESTIGATION). Step-by-step procedures (a skill or `docs/reference/`). Specific findings (the INVESTIGATION they came from, plus a glossary/domain promotion). Anything that applies only to some tasks.

## Update rules

When you change behaviour, update the doc that describes it. A task is not done until the docs match the state of the project.

- **Investigation completed** → finalise `analysis/<date>-<topic>/INVESTIGATION.md` and register it in `analysis/analysis-landscape.md`. Promote findings to `glossary.md` / `docs/domain/` / `docs/adr/` / `future-work.md` as applicable. (`/finish-analysis` does this.)
- **Methodology decision passing 3-of-3** → new `docs/adr/NNNN-slug.md`, with provenance link to the INVESTIGATION.
- **New domain term resolved** → add to `glossary.md`, with provenance link.
- **New domain mechanic discovered** → add to `docs/domain/`, with provenance link.
- **First-party utility code added** → write or extend a doc in `docs/reference/` (create the dir if absent).
- **New planned work** → `docs/planning/future-work.md`.
- **Project structure change** → update this file.
- **End of session** → `/finish` (which runs `/sharepoint-sync push` after orphan checks).

## No orphans

Every document reachable from this file via a chain of links. The `/finish` skill sweeps for orphans. Every analysis subdir must be linked from `analysis/analysis-landscape.md`.

## Portability

This file also satisfies AGENTS.md. Symlink `AGENTS.md` → `CLAUDE.md` if needed.
