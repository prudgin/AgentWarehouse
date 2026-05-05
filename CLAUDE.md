# CLAUDE.md — AgenticEngineering

This repository is a **project factory**. It hosts the templates, skills, and conventions used to cold-start new projects with a clean agentic setup, and to reset existing projects onto the same shape. The warehouse itself is a project that follows the conventions it teaches.

## Working approach

State your reading of the task before acting. If the task is ambiguous or underspecified, stop and ask rather than guessing. If multiple approaches exist, present tradeoffs — do not pick silently. For multi-step work, outline a brief plan with verification checks before starting.

## What this project is

**WHAT**: A warehouse of project-bootstrapping templates and Claude Code skills. Three deliverables:
- `templates/<type>/` — drop-in skeletons for new projects: `library`, `pipeline`, `tool-integration`, `analysis`.
- `skills/<name>/` — canonical skill sources used to create, maintain, and migrate projects.
- `references/` — external reference repos (e.g. `mattpocock-skills`) that informed the design.

**WHY**: Cold-starting a new project agentically is a friction point. Existing repos drift, develop inconsistent agent setups, accumulate orphan docs. This warehouse standardises both the cold-start and the migration path.

**HOW**: Use `/intake-target-project` from inside this directory to interview the user about a project being set up — output stages in `target-projects/<name>/`. Then `/create-project` (cold-start) or `/migrate-project` (existing repo) consumes the staging and writes the actual project repo. See [ADR-0014](docs/adr/0014-warehouse-grill-vs-project-grill.md) and [ADR-0015](docs/adr/0015-target-projects-staging.md).

## Git conventions

- Remote: <PLACEHOLDER>
- Main branch: `main` (or `master` — set on first push).
- Commit messages: imperative tense, describe what the change does.

## Documentation philosophy

Every fact has a single canonical home. Other documents link to it rather than restate it. **No orphans** — every document is reachable from this file via a chain of links. CLAUDE.md indexes top-level directories; each top-level directory has a `README.md` that indexes its contents.

CLAUDE.md lists what exists and when to read it. Skills (`.claude/skills/`) wrap procedural workflows. Library (`glossary.md`, `docs/`, `analysis/`) carries declarative knowledge.

## Documentation map

- **[`README.md`](README.md)** — human-facing entry; links back to this file.
- **[`glossary.md`](glossary.md)** — warehouse-specific vocabulary (skill, library, template, build chain, analyse chain, ADR, ...). Read before naming anything in this repo.
- **[`docs/reference/`](docs/reference/README.md)** — what the warehouse contains and how it's organised: templates inventory, skills inventory.
- **[`docs/adr/`](docs/adr/README.md)** — Architecture Decision Records. The 23 ADRs here record the design choices made in setting up the warehouse.
- **[`docs/domain/`](docs/domain/README.md)** — non-vocabulary domain knowledge. Includes:
  - `philosophy.md` — the WHY narrative (mental model, the two workflow chains, agent-as-maintainer principle).
  - `external-references.md` — what's in `references/` and what we took from each.
  - `existing-projects.md` — state of the user's existing repos and what's planned for each.
- **[`docs/planning/`](docs/planning/README.md)** — open backlog (`future-work.md`) and the boundary rule between future-work and `.tickets/` (pre-decision vs. post-decision; transition deletes the future-work entry).
- **[`analysis/`](analysis/README.md)** — investigations. First entry: the 2026-05-04 template self-test, which informed ADRs 0016–0023 and the trade-off-batch tickets.
- **[`.tickets/`](.tickets/README.md)** — local issue tracker for warehouse work.
- **[`templates/`](docs/reference/templates.md)** — project skeletons: `library/`, `pipeline/`, `tool-integration/`, `analysis/`. Inventory in [docs/reference/templates.md](docs/reference/templates.md).
- **[`target-projects/`](target-projects/README.md)** — per-target staging dirs accumulated by `/intake-target-project` before transfer to actual project repos via `/create-project` or `/migrate-project`. Permanent record of every project the warehouse has set up.
- **[`skills/`](skills/README.md)** — canonical skill sources.
- **[`references/`](docs/domain/external-references.md)** — external reference repos. See `docs/domain/external-references.md` for what's here and why.

## Skills

`.claude/skills/<name>/` — procedural workflows. Each is a symlink into `skills/<name>/` so edits to canonical sources propagate. Currently installed:

**Build chain:** `grill`, `to-prd`, `to-issues`, `triage`, `work-issue`, `finish`.
**Analyse chain:** `start-analysis`, `finish-analysis`.
**Cross-cutting:** `diagnose`, `improve-codebase-architecture`, `zoom-out`, `file-cross-repo-ticket`, `check-inbox`.
**Project lifecycle** (warehouse-only — operate against `target-projects/<name>/`): `intake-target-project`, `create-project`, `migrate-project`.
**Global** (canonical here, install as `~/.claude/skills/sudo-script/`): `sudo-script`.

See [`skills/README.md`](skills/README.md) for the full inventory with descriptions and auto-mode behaviour.

## What does NOT belong in CLAUDE.md

Code style rules. Step-by-step procedures (write a skill or a doc in `docs/reference/`). Deep domain knowledge (`glossary.md` or `docs/domain/`). Anything that applies only to some tasks.

## Update rules

When you change behaviour, update the doc that describes it. A task is not done until the docs match the state of the project.

- **Template change** → update `docs/reference/templates.md`.
- **Skill added or changed** → update `docs/reference/skills.md` and `skills/README.md`.
- **New design decision (passes 3-of-3 admission test)** → write a new `docs/adr/NNNN-slug.md`.
- **New warehouse term resolved** → add to `glossary.md`.
- **Project structure change** → update this file.
- **New planned work** → add to `docs/planning/future-work.md`.

## No orphans

Every document in the repo must be reachable from CLAUDE.md via a chain of links. The `/finish` skill (planned) sweeps for orphans. If you create a new doc, link it from the appropriate index.

## Portability

This file also satisfies the AGENTS.md convention. `AGENTS.md` is a symlink to this file.
