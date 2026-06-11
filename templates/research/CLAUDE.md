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

**Analyse-first.** This is a research project. The default workflow is to start an investigation (`/start-analysis`), do the work in a dated dir, finalise it (`/finish-analysis`), and let findings settle into `glossary.md`, `docs/domain/`, `docs/adr/`, or `docs/planning/future-work.md`. The build chain is available for shippable artefacts but is not the centre of gravity. Keepers — the figures and numbers worth putting in front of a stakeholder — are promoted as they emerge into the **report backbone** (see below), so the final report assembles incrementally rather than in an endgame scramble.

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

<!-- FIXED -->
## Report backbone

The trial ends in a report; to keep that endgame cheap, the report is assembled **incrementally from the start**, not reconstructed in a finalisation scramble. [`Reports/report-backbone.md`](Reports/report-backbone.md) is the single curated spine the final report(s) grow from — distinct from `analysis/`, which stays the full scatter of attempts (dead ends included). The backbone holds the **story beats** (the narrative order; a later presentation follows the backbone, never the reverse), a **global figure register** (stable `R-xx` ids, provenance, a `report:` status — a demotion is a status change, not a silent delete), and a **headline-numbers inventory** (every report number traced to one computed source, `pipeline/output/numbers.json`).

**Promotion ("aha → backbone").** When an investigation yields a report-worthy figure or number, `/finish-analysis` promotes it: a register row + numbers entry, plus a one-command regenerator in `pipeline/` — the standalone `run_all` → figures + numbers flow, with `golden/` blessing each figure so reproduction is provable. Only keepers reach the backbone; the scatter stays in `analysis/`. The register format lives in [`Reports/README.md`](Reports/README.md).

<!-- FIXED + PLACEHOLDER pointer adjustments -->
## Documentation map

### Synced surface (mirrors SharePoint)

- **`Articles/`** — external reference papers, related literature.
- **`Proposal/`** — grant and stage proposals; the project's "why" as written for stakeholders.
- **`Data/`** — raw and processed data. Date-range subdirs (e.g. `13-02-2026 to 26-02-2026/`) are the existing convention for time-series experiments.
- **`Reports/`** — interim and final reports (DOCX, PPTX, PDF) — the human-facing deliverables. Includes [`report-backbone.md`](Reports/report-backbone.md), the incremental assembly surface for the final report (see **Report backbone** above).
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
- **`pipeline/`** — the standalone one-command reproduction flow (raw → every report figure + `numbers.json`) and its `golden/` blessed artefacts; built incrementally as figures are promoted to the backbone. Local-only by default (it is code); promote to a deliberate sync exception at finalisation, when it becomes the hand-over artefact.
- **`output/`** — generated artefacts (regeneratable).
- **`.git/`, `.venv/`, `.claude/`, `.env`, `pyproject.toml`, `.gitignore`, `.rclone-filter`** — tooling and config.

<!-- FIXED -->
## Skills

`.claude/skills/<name>/SKILL.md` — procedural workflows. The most-used skills on a research project are `/start-analysis`, `/finish-analysis`, `/sharepoint-sync`, `/update-register-entry`, and `/finish` (which calls `/update-register-entry` then `/sharepoint-sync push` at the end). Symlink from `~/AgenticEngineering/skills/<name>` to install warehouse skills.

**`/update-register-entry` is auto-invoked from `/finish`** in research-template projects. It maintains `.register/entry.yaml` — the per-project record consumed by the research-overseer's `/reconcile-register` sweep. See ADR-0006 in the research-overseer project.

**Skills are warehouse-symlinked — do not edit them in place.** Every entry under `.claude/skills/` is an absolute symlink to `~/AgenticEngineering/skills/<name>/`. Editing the SKILL.md (or any file under the linked dir) writes through the symlink and propagates the change to **every other project** that links the same skill. A global `PreToolUse` hook (`~/.claude/hooks/check-symlink-target.sh`) blocks Edit/Write on paths that resolve outside this project root and will surface the safe alternatives:

- **Project-local tweak**: replace the symlink with a copy first — `rm <link>; cp -rL ~/AgenticEngineering/skills/<name> .claude/skills/<name>` — then edit. The project now owns its fork; it will not receive future warehouse improvements to that skill.
- **New skill, this project only**: create a regular directory `.claude/skills/<my-skill>/` (no symlink). No collision.
- **Improvement that should reach every project**: `cd ~/AgenticEngineering/`, edit the canonical source, commit. All linked projects pick up the change automatically.

<!-- FIXED -->
## Memory

This project owns its knowledge in versioned docs, not in Claude's per-conversation auto-memory. When you learn something durable about this project — vocabulary, a domain mechanic, a decision, a fact about how the work is run — write it into its canonical home (`glossary.md` / `docs/domain/` / `docs/adr/` / `docs/planning/future-work.md`) rather than into a memory file. Auto-memory is for user preferences and cross-project habits; project facts belong in the repo, where they are versioned, reviewable, and visible to every other agent and every other machine.

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
- **Report-worthy figure or number produced** → register it in [`Reports/report-backbone.md`](Reports/report-backbone.md) (figure-register row + numbers inventory, with `report:` status) and ensure a one-command `pipeline/` regenerator exists. (`/finish-analysis` prompts this.)
- **New planned work** → `docs/planning/future-work.md`.
- **Project structure change** → update this file.
- **End of session** → `/finish` (which runs `/sharepoint-sync push` after orphan checks).

<!-- FIXED -->
## No orphans

Every document reachable from this file via a chain of links. The `/finish` skill sweeps for orphans. Every analysis subdir must be linked from `analysis/analysis-landscape.md`.

<!-- FIXED -->
## Portability

This file also satisfies AGENTS.md. Symlink `AGENTS.md` → `CLAUDE.md` if needed.
