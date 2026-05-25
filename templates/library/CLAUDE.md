<!-- TEMPLATE META — delete this block when putting the template to use.

This template encodes a documentation philosophy, not just a file layout.
Core idea: CLAUDE.md is the agent's entry point. It is loaded into every
session, so content that is not universally relevant degrades the model's
attention to the rest. Deeper context lives elsewhere and is read on demand
(progressive disclosure).

Two complementary forms of progressive disclosure:
- Reference-style: docs in glossary.md, docs/, analysis/. CLAUDE.md indexes
  them; agents follow pointers as the task demands.
- Trigger-style: skills in .claude/skills/. Agents see only frontmatter
  descriptions; bodies load when the description matches the task.

Sections marked FIXED are part of the philosophy and should not be
changed between projects. Sections marked PLACEHOLDER are project-specific
and must be filled in.

Filter for every line: would removing it cause the next agent to make
mistakes? If not, cut it.

Target length: under 80 lines of actual file content (excluding this
meta block).
-->

# CLAUDE.md — <PLACEHOLDER: project name>

*This project was scaffolded from the AgenticEngineering warehouse. The warehouse's own `CLAUDE.md` describes the warehouse, not this project — do not load it as authoritative; this file is.*

<!-- FIXED -->
## Working approach

State your reading of the task before acting. If the task is ambiguous or underspecified, stop and ask rather than guessing. If multiple approaches exist, present tradeoffs — do not pick silently. For multi-step work, outline a brief plan with verification checks before starting.

<!-- PLACEHOLDER — 8–12 lines. Cover three things:
     WHAT: technology, stack, shape of the project, major directories, entry points.
     WHY:  purpose of the project and purpose of each major part.
     HOW:  how to install, run, test, and verify changes.
     Prefer pointers over inline content. Do not paste code or long lists
     here — link to files in docs/ or to paths in the repo.
     Do NOT bake in design decisions (eviction policies, error-handling strategies,
     retry semantics, etc.) — those go in docs/adr/. CLAUDE.md describes shape;
     ADRs describe choices. -->
## What this project is

<WHAT / WHY / HOW goes here.>

<!-- PLACEHOLDER — short block with the project's git conventions:
     remote, main branch, commit message style, any auth notes. -->
## Git conventions

<Git conventions go here.>

<!-- FIXED -->
## Documentation philosophy

Every fact has a single canonical home. Other documents link to it rather than restate it. **No orphans** — every document is reachable from this file via a chain of links. CLAUDE.md indexes top-level directories; each top-level directory has a `README.md` that indexes its contents. Substance lives in the leaf files.

CLAUDE.md lists what exists and when to read it. Skills (`.claude/skills/`) wrap procedural workflows. Library (`glossary.md`, `docs/`, `analysis/`) carries declarative knowledge.

<!-- FIXED -->
## Documentation map

- **`README.md`** — human-facing entry; links back to this file.
- **`glossary.md`** — domain ubiquitous language. One canonical term per concept; synonyms listed as "Avoid". Read before naming anything.
- **`docs/reference/`** — how the code works. One doc per module or subsystem. Source of truth is the code.
- **`docs/adr/`** — Architecture Decision Records. Numbered files (`0001-slug.md`, `0002-slug.md`, ...). Created lazily; admission test is strict (see `docs/adr/README.md`).
- **`docs/domain/`** — domain knowledge that is not vocabulary: how the domain behaves, mechanics, known anomalies, data model.
- **`docs/planning/`** — open backlog (`future-work.md`) and the boundary rule between future-work and `.tickets/` (pre-decision vs. post-decision; transition deletes the future-work entry). Indexed in `docs/planning/README.md`.
- **`analysis/YYYY-MM-DD-<topic>/INVESTIGATION.md`** — investigation outputs. Each dir holds the scripts and the canonical writeup.
- **`analysis/analysis-landscape.md`** — narrative across all investigations. Single entry point that links every INVESTIGATION.
- **`.tickets/`** — local issue tracker (PRDs and tickets). Triage state in a `Status:` line.
- **`.tickets/inbox/`** — incoming tickets from agents working in dependent repos. Triage on session start.

<!-- FIXED -->
## Skills

`.claude/skills/<name>/SKILL.md` — procedural workflows the agent can invoke. Each has a frontmatter `description` that tells the agent when to use it. Some auto-invoke on description match; some are explicit-only (slash command).

Read each SKILL.md only when the workflow is needed.

<!-- FIXED -->
## Memory

This project owns its knowledge in versioned docs, not in Claude's per-conversation auto-memory. When you learn something durable about this project — vocabulary, a domain mechanic, a decision, a fact about how the work is run — write it into its canonical home (`glossary.md` / `docs/domain/` / `docs/adr/` / `docs/planning/future-work.md`) rather than into a memory file. Auto-memory is for user preferences and cross-project habits; project facts belong in the repo, where they are versioned, reviewable, and visible to every other agent and every other machine.

## What does NOT belong in CLAUDE.md

Code style rules (use a linter or `docs/reference/conventions.md`). Step-by-step procedures (write a skill or a doc in `docs/reference/`). Deep domain knowledge (`glossary.md` or `docs/domain/`). Anything that applies only to some tasks (put it where it belongs and let the agent find it). If it is not universally relevant to every session, it does not belong here.

<!-- FIXED -->
## Update rules

When you change behaviour, update the doc that describes it. A task is not done until the docs match the state of the project.

- **Code change** → update the relevant `docs/reference/` doc (if one exists).
- **Architectural decision (passes 3-of-3 admission test)** → write a new `docs/adr/NNNN-slug.md`.
- **New domain term resolved** → add to `glossary.md`.
- **New domain mechanic discovered** → write or extend a doc in `docs/domain/`.
- **Investigation completed** → finalise `analysis/<date>-<topic>/INVESTIGATION.md` and register it in `analysis/analysis-landscape.md`.
- **New planned work** → add to `docs/planning/future-work.md`. When shipped, remove the entry; rationale lives in the ADR or the landscape entry.
- **Project structure change** → update this file.

<!-- FIXED -->
## No orphans

Every document in the repo must be reachable from CLAUDE.md via a chain of links. The `/finish` skill (when installed) sweeps for orphan docs. If you create a new doc, link it from the appropriate index (CLAUDE.md, `analysis/analysis-landscape.md`, or a `docs/<area>/README.md`).

<!-- FIXED -->
## Portability

This file also satisfies the AGENTS.md convention. Symlink `AGENTS.md` to this file if the project is used with non-Claude agents.
