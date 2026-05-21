# CLAUDE.md — research-overseer

*This project was scaffolded from the AgenticEngineering warehouse. The warehouse's own `CLAUDE.md` describes the warehouse, not this project — do not load it as authoritative; this file is.*

## Working approach

State your reading of the task before acting. If the task is ambiguous or underspecified, stop and ask rather than guessing. **Destructive operations on shared state (SharePoint folders, register XLSX) follow the tiered auth gate — see [ADR-0004](docs/adr/0004-tiered-destructive-ops-auth-gate.md).**

This is a tool-integration-shaped project with analysis as a first-class surface. Skills wrap the rclone + openpyxl plumbing; `_tools/` holds the underlying scripts; `analysis/` is where cross-project meta-investigations live.

## What this project is

**WHAT**: An overarching research agent. Maintains the master research projects register (`sharepoint_planning:PROJECTS/RnD projects register.xlsx`) by reconciling per-project `.register/entry.yaml` files. Runs cross-project meta-investigations. Performs maintenance on R&D SharePoint (delete empty folders, restructure old content). Routes cross-repo tickets back into per-project repos.

**WHY**: Per-project agents already maintain individual project state; the manager already maintains the register manually. The overseer closes the loop: it propagates project-side truth into the register, surfaces drift, and lifts the synthesis work above any single project. See [glossary](glossary.md) for vocabulary.

**HOW**: Per-project research repos write a `.register/entry.yaml` (via `/update-register-entry`, auto-called from `/finish`). The overseer's `/reconcile-register` sweeps those files (both locally under `~/ResearchProjects/*/` and on SharePoint), computes diffs against the register XLSX, applies clean diffs, queues conflicts. Meta-investigations live under `analysis/YYYY-MM-DD-<topic>/`. SharePoint maintenance follows the tiered gate ([ADR-0004](docs/adr/0004-tiered-destructive-ops-auth-gate.md)).

## Directory layout

```
research-overseer/
├── CLAUDE.md              # this file
├── README.md
├── glossary.md
├── _tools/                # bash/python scripts (rclone + openpyxl)
├── docs/
│   ├── adr/               # 6 ADRs documenting the design choices
│   ├── domain/            # register-shape.md and others
│   ├── strategy/          # roadmap, themes, gaps (β responsibility)
│   └── planning/          # future-work backlog
├── analysis/              # cross-project meta-investigations (α)
├── .tickets/              # local tracker; .tickets/inbox/ for cross-repo
└── .claude/skills/        # symlinks into ~/AgenticEngineering/skills/<name>/
```

## SharePoint scope & mirror

- **Write access**: `sharepoint_planning:` only ([ADR-0005](docs/adr/0005-write-scope-sharepoint-planning-only.md)).
- **Read-only**: `sharepoint:` (operational farm data) — context for meta-investigations, never written.
- **Overseer self-sync**: this repo's working state mirrors bidirectionally to `sharepoint_planning:Research overseer/` via `/sharepoint-sync`. Filter excludes code, `.git/`, `.venv/`, `_tools/` outputs.

## Git conventions

- Remote: **none**. Local-only on `rndcomputer`. The SharePoint mirror is the offsite copy of the working state.
- Main branch: `main`.
- Commit messages: imperative tense.

## Documentation philosophy

Every fact has a single canonical home. **No orphans** — every document reachable from this file via a chain of links. Skills wrap procedure; library carries declarative knowledge.

## Documentation map

- **[`README.md`](README.md)** — human-facing entry; links back to this file.
- **[`glossary.md`](glossary.md)** — overseer-specific vocabulary (register, entry-yaml, slug, drift, reconcile, ...). Read before naming anything.
- **[`docs/adr/`](docs/adr/README.md)** — 6 ADRs covering the canonical-yaml decision, the slug column, the 1:1:1 mapping, the tiered auth gate, write-scope, and the /finish hook.
- **[`docs/domain/`](docs/domain/README.md)** — non-vocabulary domain knowledge. Today: [register-shape](docs/domain/register-shape.md).
- **[`docs/strategy/`](docs/strategy/)** — research roadmap, themes, gaps (β).
- **[`docs/planning/future-work.md`](docs/planning/future-work.md)** — pre-decision backlog. Items move to `.tickets/` when work starts.
- **[`analysis/`](analysis/)** — cross-project meta-investigations under `YYYY-MM-DD-<topic>/INVESTIGATION.md`, indexed in `analysis/analysis-landscape.md`.
- **[`.tickets/`](.tickets/)** — local issue tracker; `.tickets/inbox/` for cross-repo tickets routed in via `/file-cross-repo-ticket`.
- **[`_tools/`](_tools/)** — bash/python scripts wrapped by skills.

## Skills

`.claude/skills/<name>/SKILL.md` — procedural workflows. Skills are warehouse-symlinked; do not edit them in place.

**Overseer-specific skills (new, canonical in `~/AgenticEngineering/skills/`):**

- `/reconcile-register` — single-batch sweep + apply. Walks all per-project entry.yaml files, applies clean diffs to the register XLSX, queues conflicts, uploads.
- `/detect-drift` — read-only variant of reconcile; produces a drift report without writing.
- `/sweep-sharepoint-cleanup` — produces the proposed plan for high-tier destructive ops, writes to `.tickets/sharepoint-cleanup-<date>.md`.
- `/apply-sharepoint-cleanup <ticket>` — applies a previously-approved cleanup ticket; logs to `analysis/YYYY-MM-DD-sharepoint-restructure/audit.md`.

**Warehouse skills also installed:**

- `/sharepoint-sync` (pull/push for self-mirror)
- `/start-analysis`, `/finish-analysis` (analyse chain)
- `/file-cross-repo-ticket`, `/check-inbox` (cross-cutting)
- `/finish` (end-of-work ritual)
- `/diagnose`, `/zoom-out`, `/improve-codebase-architecture` (cross-cutting)
- `/schedule` (weekly reconcile cadence)

**Reach-into-other-repos skill (new, canonical in warehouse, symlinked into research-template projects — not into this repo):**

- `/update-register-entry` — per-project skill that maintains `.register/entry.yaml`. Auto-called from `/finish` in research-template projects ([ADR-0006](docs/adr/0006-update-register-entry-auto-invoked-from-finish.md)).

## Update rules

- **New ADR-level decision** → `docs/adr/NNNN-slug.md`.
- **New term resolved** → `glossary.md`.
- **New `_tools/` script or skill** → update this file's Skills section and `_tools/README.md`.
- **New domain knowledge about the register or SharePoint** → `docs/domain/`.
- **New planned work** → `docs/planning/future-work.md`.
- **Strategy / themes change** → `docs/strategy/`.
- **End of session** → `/finish` (orphan sweep + sharepoint push).

## No orphans

Every document reachable from this file via a chain of links. The `/finish` skill sweeps for orphans.

## Portability

This file also satisfies AGENTS.md. Symlink `AGENTS.md` → `CLAUDE.md` at scaffold time.
