# CLAUDE.md — WaterQualityFeed

*This project was scaffolded from the AgenticEngineering warehouse. The warehouse's own `CLAUDE.md` describes the warehouse, not this project — do not load it as authoritative; this file is.*

## Working approach

State your reading of the task before acting. If the task is ambiguous or underspecified, stop and ask rather than guessing. If multiple approaches exist, present tradeoffs — do not pick silently. For multi-step work, outline a brief plan with verification checks before starting.

## What this project is

**WHAT.** A daily mirror of the WQ SharePoint site into parquet form. Pulls six lists (`WQ_Readings`, `WQ_Units`, `WQ_Sites`, `WQ_Farms`, `WQ_ParameterRanges`, `WQ_Flags`) via the [`WQ_Reader_Proxy`](docs/domain/sources.md) Power Automate flow, normalises Sydney TZ, and atomically publishes parquets under `/mnt/data/water_quality/`.

**WHY.** WQ data is currently SharePoint-only — invisible to MDF analysis, Power BI, and ad-hoc work. Mirroring it to the data lake unlocks those consumers. v1 does *not* canonicalise UnitIds to Mercatus — see [ADR-0003](docs/adr/0003-v1-wq-native-identifiers-no-canonical-mapping.md) and [the unit-mapping puzzle](docs/domain/unit-mapping-puzzle.md).

**HOW.** Run `python run_pipeline.py` against MDF's shared venv. systemd timer fires daily at 03:00 Sydney (one hour ahead of MDF so a future canonical-mapping stage can read MDF's morning publish in-run if needed).

## Pipeline areas

*Canonical list of stages. If you change this table, run `/finish` — it cross-checks against `docs/reference/`.*

| Area | Entry point | Code | Output |
|------|------------|------|--------|
| **Orchestration** | `run_pipeline.py` | — | runs all stages in order |
| Ingestion | `run_pipeline.py` | `ingestion/` | `<published>/.staging/raw/*.json` |
| Clean | `run_pipeline.py` | `processing/clean/` | `<published>/.staging/*.parquet` (Sydney TZ, typed) |
| Publish | `run_pipeline.py` | `processing/publish.py` | atomic rename `<published>/.staging/` → `<published>/` |

Published root: `/mnt/data/water_quality/` (env override `WQ_DATA_ROOT`). Schema contract auto-written as `<published>/README.md` on every successful run.

## Shared venv

This project does **not** own a `.venv/`. It is a 5th tenant of MDF's shared venv at `/home/rndmanager/PycharmProjects/MercatusDataFeed/.venv/`, alongside MercatusDataFeed, GrowthModels, PowerBI, and FishGrowthFittingSGRpackage. See [ADR-0002](docs/adr/0002-share-mdf-venv-despite-standalone.md) for the reasoning, and [`docs/reference/conventions.md`](docs/reference/conventions.md) for installation.

### No version pins, ever

Bare-name dependencies in `pyproject.toml` (no `>=`, `==`, or constraints). Pinning is silent staleness; we want loud failures across the multi-project venv.

### Naming conventions (three namespaces, one project)

| Namespace | This project |
|-----------|--------------|
| Repo / directory (CamelCase) | `WaterQualityFeed` |
| Python import (snake_case) | `water_quality_feed` |
| pip distribution (kebab) | `water-quality-feed` |

## Git conventions

- Remote: `https://github.com/prudgin/WaterQualityFeed.git`
- Main branch: `master` (matching MDF; the project pairs with MDF day-to-day).
- Commit messages: imperative tense.
- Gitignored: `data/` (project-internal scratch only — published surface lives at `/mnt/data/water_quality/`), `.env`, `.idea/`, `__pycache__/`.

## Documentation philosophy

Every fact has a single canonical home. Other documents link to it rather than restate it. **No orphans** — every document reachable from this file via a chain of links.

CLAUDE.md lists what exists and when to read it. Skills (`.claude/skills/`) wrap procedural workflows. Library (`glossary.md`, `docs/`) carries declarative knowledge.

## Documentation map

- **[`README.md`](README.md)** — human-facing entry; links back to this file.
- **[`glossary.md`](glossary.md)** — project vocabulary (Reading, WQ-native identifier, Site-level reading, WQ Reader Proxy, Canonical-mapping stage, Pattern 1 / Pattern 2, Mirror). Read before naming anything.
- **`docs/reference/`** — one doc per stage (`ingestion.md`, `clean.md`, `publish.md`) plus `conventions.md` (CSV/JSON parse rules, TZ rules, .env, shared-venv install). Source of truth is the code.
- **[`docs/adr/`](docs/adr/)** — Architecture Decision Records. v1 has three:
  - [0001 — Standalone pipeline, not an MDF stage](docs/adr/0001-standalone-pipeline-not-mdf-stage.md)
  - [0002 — Share MDF's venv despite being standalone](docs/adr/0002-share-mdf-venv-despite-standalone.md)
  - [0003 — v1 publishes WQ-native identifiers; canonical mapping deferred](docs/adr/0003-v1-wq-native-identifiers-no-canonical-mapping.md)
- **[`docs/domain/`](docs/domain/)** — non-vocabulary domain knowledge:
  - [`sources.md`](docs/domain/sources.md) — the WQ Reader Proxy flow and the six SP list schemas.
  - [`unit-mapping-puzzle.md`](docs/domain/unit-mapping-puzzle.md) — the two farm patterns and what the canonical-mapping stage will have to do.
- **[`docs/planning/`](docs/planning/)** — open backlog (`future-work.md`) and the boundary rule between future-work and `.tickets/`.
- **`analysis/YYYY-MM-DD-<topic>/INVESTIGATION.md`** — investigations.
- **`.tickets/`** — local issue tracker. `.tickets/inbox/` for incoming cross-repo tickets.

## Skills

`.claude/skills/<name>/SKILL.md` — procedural workflows symlinked from `~/AgenticEngineering/skills/<name>`. Installed: `grill`, `to-prd`, `to-issues`, `triage`, `work-issue`, `finish`, `start-analysis`, `finish-analysis`, `diagnose`, `improve-codebase-architecture`, `file-cross-repo-ticket`, `check-inbox`.

## What does NOT belong in CLAUDE.md

Code style rules (`docs/reference/conventions.md`). Step-by-step procedures (skill or `docs/reference/`). Deep domain knowledge (`glossary.md` or `docs/domain/`). Per-stage details (`docs/reference/<stage>.md`). Anything that applies only to some tasks.

## Update rules

When you change behaviour, update the doc that describes it.

- **Code change in a stage** → update `docs/reference/<stage>.md`.
- **Architectural decision passing 3-of-3** → new `docs/adr/NNNN-slug.md`.
- **New domain term resolved** → `glossary.md`.
- **New domain mechanic discovered** → `docs/domain/`.
- **Investigation completed** → finalise `analysis/<date>-<topic>/INVESTIGATION.md` and register in landscape.
- **New planned work** → `docs/planning/future-work.md`.
- **New stage added or stage layout changed** → this file (the pipeline-areas table) and `docs/reference/`.

## No orphans

Every document reachable from this file via a chain of links. The `/finish` skill sweeps for orphans.

## Portability

This file also satisfies AGENTS.md. `AGENTS.md` is a symlink to this file.
