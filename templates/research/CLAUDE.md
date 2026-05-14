<!-- TEMPLATE META — delete this block when putting the template to use.

Research variant of the analysis template, with bidirectional SharePoint mirror.
For "official" MCA research projects whose deliverables (data, proposals,
reports, references) are accountable to a SharePoint folder under
sharepoint_planning:PROJECTS/. Distinct from the analysis template, which is
local-only and used for ad-hoc investigations on top of other repos.

Differences from the analysis template:

- Five "synced surface" dirs at root: Articles/, Proposal/, Data/, Reports/,
  Expenses/. These mirror the user's existing SharePoint project layout
  ("New project folder structure template11").
- A `.rclone-filter` defining what does NOT sync (code, .git, .venv, secrets,
  agent install). Everything else — including agent infrastructure
  (CLAUDE.md, glossary.md, docs/, .tickets/, analysis/) — syncs both ways.
- /sharepoint-sync skill installed. Pull at session start, push at /finish.
- Project lives under ~/ResearchProjects/<Project Name>/, not ~/PycharmProjects/.
- Project name is "YYYY <Title Case Name>" matching the SharePoint folder verbatim.

Closest analogue: GutEvac (renamed to "2026 Gut Clearance" on migration).

Sections marked FIXED are part of the philosophy. Sections marked
PLACEHOLDER are project-specific.

Target length: under 120 lines of actual file content (excluding meta).
-->

# CLAUDE.md — <PLACEHOLDER: project name, e.g. "2026 Gut Clearance">

*This project was scaffolded from the AgenticEngineering warehouse. The warehouse's own `CLAUDE.md` describes the warehouse, not this project — do not load it as authoritative; this file is.*

<!-- FIXED -->
## Working approach

State your reading of the task before acting. If the task is ambiguous or underspecified, stop and ask rather than guessing. If multiple approaches exist, present tradeoffs — do not pick silently. For multi-step work, outline a brief plan with verification checks before starting.

**Analyse-first.** This is a research project. The default workflow is to start an investigation (`/start-analysis`), do the work in a dated dir, finalise it (`/finish-analysis`), and let findings settle into `glossary.md`, `docs/domain/`, `docs/adr/`, or `docs/planning/future-work.md`. The build chain is available for shippable artefacts but is not the centre of gravity.

<!-- FIXED -->
## SharePoint mirror

This project is bidirectionally mirrored to `sharepoint_planning:PROJECTS/<Project Name>/`. The local directory and the SharePoint folder hold **the same shape**, with one exception: code does not push.

- **At session start:** run `/sharepoint-sync pull`. Newer files on SharePoint come down.
- **At `/finish`:** run `/sharepoint-sync push`. Newer files locally go up.
- **What syncs:** everything not excluded by `.rclone-filter`. Agent infrastructure (`CLAUDE.md`, `glossary.md`, `docs/`, `.tickets/`, `analysis/`) syncs alongside the human-facing dirs (`Articles/`, `Proposal/`, `Data/`, `Reports/`, `Expenses/`). Another agent picking up the SharePoint folder gets the full project context.
- **What does NOT sync:** `src/`, `scripts/`, `output/`, `.git/`, `.venv/`, `.claude/`, `.env`, build artefacts. See `.rclone-filter`.
- **Deletes do not propagate.** `rclone copy --update` only ever transfers — it never removes. To delete a file from the project, you must remove it from **both sides explicitly**. The skill refuses to do deletions; do them by hand and document them in the relevant ticket or INVESTIGATION.

See [`/sharepoint-sync`](.claude/skills/sharepoint-sync/SKILL.md) for full mechanics, conflict behaviour, and recovery.

<!-- PLACEHOLDER — describe the research project:
     WHAT: research question, domain, primary data, primary methods.
     WHY:  what decision or claim does this work support? Who reads
           the deliverable, and what do they do with it?
     HOW:  how to reproduce a run end-to-end (input → script → output);
           where data lives; where the latest report lives.
     Do NOT bake in design decisions (eviction policies, error-handling strategies,
     retry semantics, etc.) — those go in docs/adr/. CLAUDE.md describes shape;
     ADRs describe choices. -->
## What this project is

<WHAT / WHY / HOW.>

<!-- PLACEHOLDER -->
## Git conventions

- Remote: <PLACEHOLDER>
- Main branch: `main`
- Commit messages: imperative tense.

<!-- FIXED -->
## Documentation philosophy

Every fact has a single canonical home. Other documents link to it rather than restate it. **No orphans** — every document reachable from this file via a chain of links. CLAUDE.md indexes top-level directories; each top-level directory has a `README.md` that indexes its contents.

CLAUDE.md lists what exists and when to read it. Skills (`.claude/skills/`) wrap procedural workflows. Library (`glossary.md`, `docs/`, `analysis/`) carries declarative knowledge. For a research project the centre of gravity is `analysis/` and `docs/domain/`.

**Findings provenance.** Claims that land in `glossary.md`, `docs/domain/`, or `docs/adr/` link back to the `analysis/<dated>/INVESTIGATION.md` that produced them. Provenance is what keeps the substrate honest as the research evolves.

<!-- FIXED + PLACEHOLDER pointer adjustments -->
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

<!-- FIXED -->
## Skills

`.claude/skills/<name>/SKILL.md` — procedural workflows. The most-used skills on a research project are `/start-analysis`, `/finish-analysis`, `/sharepoint-sync`, and `/finish` (which calls `/sharepoint-sync push` at the end). Symlink from `~/AgenticEngineering/skills/<name>` to install warehouse skills.

<!-- FIXED -->
## What does NOT belong in CLAUDE.md

Methodology details (`docs/domain/` or the relevant INVESTIGATION). Step-by-step procedures (a skill or `docs/reference/`). Specific findings (the INVESTIGATION they came from, plus a glossary/domain promotion). Anything that applies only to some tasks.

<!-- FIXED -->
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

<!-- FIXED -->
## No orphans

Every document reachable from this file via a chain of links. The `/finish` skill sweeps for orphans. Every analysis subdir must be linked from `analysis/analysis-landscape.md`.

<!-- FIXED -->
## Portability

This file also satisfies AGENTS.md. Symlink `AGENTS.md` → `CLAUDE.md` if needed.
