<!-- TEMPLATE META — delete this block when putting the template to use.

Analysis variant of the library template. For research projects whose
primary deliverable is a body of investigations (INVESTIGATIONs + plots +
interpretation), not a public API or a multi-stage pipeline. Differs
from the library template in:

- analyse chain dominant. The build chain is available but not central.
  CLAUDE.md leads with the analyse-chain workflow.
- analysis/ is the primary work surface. Top-of-doc-map promotion.
- docs/reference/ is OPTIONAL. Many research projects have one or two
  scripts and no module hierarchy worth documenting. Reinstate the dir
  when first-party utility code grows.
- docs/domain/ pre-suggests model.md, data-shape.md, known-issues.md.
  No "working-notes" junk drawer (ADR-0007). Caveats land in
  known-issues.md, follow-up priorities in docs/planning/future-work.md,
  methodology decisions in docs/adr/, and headline numbers in the
  INVESTIGATION for that round.
- "Findings provenance" rule: every claim in a domain doc or ADR links
  back to the analysis/<dated-dir>/INVESTIGATION.md that produced it.

Closest analogue: GutEvac (gut-clearance research on Murray cod), and
the analysis/ portion of FishGrowthFittingSGRpackage.

Sections marked FIXED are part of the philosophy. Sections marked
PLACEHOLDER are project-specific.

Target length: under 100 lines of actual file content (excluding meta).
-->

# CLAUDE.md — <PLACEHOLDER: project name>

*This project was scaffolded from the AgenticEngineering warehouse. The warehouse's own `CLAUDE.md` describes the warehouse, not this project — do not load it as authoritative; this file is.*

<!-- FIXED -->
## Working approach

State your reading of the task before acting. If the task is ambiguous or underspecified, stop and ask rather than guessing. If multiple approaches exist, present tradeoffs — do not pick silently. For multi-step work, outline a brief plan with verification checks before starting.

**Analyse-first.** This is a research project. The default workflow is to start an investigation (`/start-analysis`), do the work in a dated dir, finalise it (`/finish-analysis`), and let findings settle into `glossary.md`, `docs/domain/`, `docs/adr/`, or `docs/planning/future-work.md`. The build chain is available for shippable artefacts (e.g. a CLI to run the analysis) but is not the centre of gravity.

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

- **`README.md`** — human-facing entry; links back to this file.
- **`glossary.md`** — domain ubiquitous language. Read before naming anything.
- **`analysis/YYYY-MM-DD-<topic>/INVESTIGATION.md`** — investigations. **The primary work surface.** Each dated dir holds the scripts and the canonical writeup.
- **`analysis/analysis-landscape.md`** — narrative across all investigations. Single entry point that links every INVESTIGATION.
- **`docs/domain/`** — non-vocabulary domain knowledge: model mechanics, data shape, known issues. Promoted from INVESTIGATION findings via `/finish-analysis`.
- **`docs/adr/`** — Architecture Decision Records (e.g. methodological choices: which likelihood, which model class, which validation procedure). 3-of-3 admission test.
- **`docs/reference/`** — OPTIONAL. Used only if the project grows first-party utility code worth a module-level writeup. Empty or absent in many research projects.
- **`docs/planning/`** — open backlog (`future-work.md`: next investigations, data-collection priorities, methodological todos) and the boundary rule vs. `.tickets/`. Indexed in `docs/planning/README.md`.
- **`.tickets/`** — local issue tracker. Available for shippable artefacts; often unused on pure-research projects.
- **`.tickets/inbox/`** — incoming cross-repo tickets.

<!-- FIXED -->
## Skills

`.claude/skills/<name>/SKILL.md` — procedural workflows. The most-used pair on a research project is `/start-analysis` and `/finish-analysis`. Symlink from `~/AgenticEngineering/skills/<name>` to install warehouse skills.

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

<!-- FIXED -->
## No orphans

Every document reachable from this file via a chain of links. The `/finish` skill (when installed) sweeps for orphans. Every analysis subdir must be linked from `analysis/analysis-landscape.md`.

<!-- FIXED -->
## Portability

This file also satisfies AGENTS.md. Symlink `AGENTS.md` → `CLAUDE.md` if needed.
