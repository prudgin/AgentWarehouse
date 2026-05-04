<!-- TEMPLATE META — delete this block when putting the template to use.

Pipeline variant of the library template. Differs from the library template in:
- Adds a "Pipeline areas" table for multi-stage pipelines.
- Adds a "Shared venv" section for pipelines that share a Python environment
  with sibling repos.
- docs/reference/ is organised one file per stage rather than one per module.
- docs/domain/ pre-allocates files for mechanics, known-anomalies, data-model.

Filter for every line: would removing it cause the next agent to make
mistakes? If not, cut it.

Sections marked FIXED are part of the philosophy. Sections marked
PLACEHOLDER are project-specific.

Target length: under 100 lines of actual file content (excluding this meta).
-->

# CLAUDE.md — <PLACEHOLDER: project name>

*This project was scaffolded from the AgenticEngineering warehouse. The warehouse's own `CLAUDE.md` describes the warehouse, not this project — do not load it as authoritative; this file is.*

<!-- FIXED -->
## Working approach

State your reading of the task before acting. If the task is ambiguous or underspecified, stop and ask rather than guessing. If multiple approaches exist, present tradeoffs — do not pick silently. For multi-step work, outline a brief plan with verification checks before starting.

<!-- PLACEHOLDER — describe the pipeline:
     WHAT: input source, output sink, intermediate stages, technology.
     WHY:  what this pipeline produces and who consumes it.
     HOW:  how to run end-to-end and per-stage; how to verify outputs. -->
## What this project is

<WHAT / WHY / HOW.>

<!-- PLACEHOLDER — fill in the table for this pipeline's stages.
     Each row: stage name, entry point, code dir, output. -->
## Pipeline areas

| Area | Entry point | Code | Output |
|------|------------|------|--------|
| **Orchestration** | `<entry>.py` | — | runs all stages in order |
| Ingestion | `<entry>.py` | `ingestion/` | ... |
| Stage A | `<entry>.py` | `stage_a/` | ... |
| Stage B | `<entry>.py` | `stage_b/` | ... |

<!-- PLACEHOLDER — only if shared venv applies. Delete the section
     entirely if this project owns its own venv. -->
## Shared venv

`<this-project>/.venv/` is shared by N projects: ... See [`docs/reference/conventions.md`](docs/reference/conventions.md) for the convention.

### No version pins, ever

Bare-name dependencies in `pyproject.toml` (no `>=`, `==`, or constraints). Pinning is silent staleness; we want loud failures.

<!-- PLACEHOLDER -->
## Git conventions

- Remote: <PLACEHOLDER>
- Main branch: `main`
- Commit messages: imperative tense.

<!-- FIXED -->
## Documentation philosophy

Every fact has a single canonical home. Other documents link to it rather than restate it. **No orphans** — every document reachable from this file via a chain of links. CLAUDE.md indexes top-level directories; each top-level directory has a `README.md` that indexes its contents.

CLAUDE.md lists what exists and when to read it. Skills (`.claude/skills/`) wrap procedural workflows. Library (`glossary.md`, `docs/`, `analysis/`) carries declarative knowledge.

<!-- FIXED + PLACEHOLDER pointer adjustments -->
## Documentation map

- **`README.md`** — human-facing entry; links back to this file.
- **`glossary.md`** — domain ubiquitous language. Read before naming anything.
- **`docs/reference/`** — how the code works. Pipeline-style: typically one doc per stage (ingestion.md, stage_a.md, stage_b.md, ...). Source of truth is the code.
- **`docs/adr/`** — Architecture Decision Records. Numbered files. 3-of-3 admission test.
- **`docs/domain/`** — non-vocabulary domain knowledge: mechanics (how upstream actions become data), known anomalies, data model.
- **`docs/planning/`** — open backlog (`future-work.md`) and the boundary rule between future-work and `.tickets/`. Indexed in `docs/planning/README.md`.
- **`analysis/YYYY-MM-DD-<topic>/REPORT.md`** — investigations.
- **`analysis/analysis-landscape.md`** — narrative across all investigations.
- **`.tickets/`** — local issue tracker.
- **`.tickets/inbox/`** — incoming cross-repo tickets.

<!-- FIXED -->
## Skills

`.claude/skills/<name>/SKILL.md` — procedural workflows. Each has a frontmatter `description` that tells the agent when to use it. Symlink from `~/AgenticEngineering/skills/<name>` to install warehouse skills.

<!-- FIXED -->
## What does NOT belong in CLAUDE.md

Code style rules. Step-by-step procedures (write a skill or `docs/reference/`). Deep domain knowledge (`glossary.md` or `docs/domain/`). Per-stage details (`docs/reference/<stage>.md`). Anything that applies only to some tasks.

<!-- FIXED -->
## Update rules

When you change behaviour, update the doc that describes it.

- **Code change in a stage** → update `docs/reference/<stage>.md`.
- **Architectural decision passing 3-of-3** → new `docs/adr/NNNN-slug.md`.
- **New domain term resolved** → `glossary.md`.
- **New domain mechanic discovered** → `docs/domain/`.
- **Investigation completed** → finalise `analysis/<date>-<topic>/REPORT.md` and register in landscape.
- **New planned work** → `docs/planning/future-work.md`.
- **New stage added or stage layout changed** → this file (the pipeline-areas table) and `docs/reference/`.

<!-- FIXED -->
## No orphans

Every document reachable from this file via a chain of links. The `/finish` skill sweeps for orphans.

<!-- FIXED -->
## Portability

This file also satisfies AGENTS.md. Symlink `AGENTS.md` → `CLAUDE.md` if needed.
