<!-- TEMPLATE META — delete this block when putting the template to use.

Tool-integration variant of the library template. Differs from the library
template in:
- Skills-heavy, library-light. Knowledge about how to operate external tools
  lives in `.claude/skills/<surface>-<verb>/` rather than in docs/reference/.
- Adds `_tools/` directory at the repo root for the underlying bash scripts
  that skills wrap. Skills are the human/agent interface; _tools/ is the
  implementation.
- docs/reference/ is optional — may be empty if there is no first-party code
  worth documenting beyond the tool wrappers.
- Per-artifact directories (e.g. one per exported flow, one per app) are
  organised by the artifact's display name with a `*-meta.json` recording
  GUIDs and provenance.

Sections marked FIXED are part of the philosophy. Sections marked
PLACEHOLDER are project-specific.

Target length: under 80 lines.
-->

# CLAUDE.md — <PLACEHOLDER: project name>

*This project was scaffolded from the AgenticEngineering warehouse. The warehouse's own `CLAUDE.md` describes the warehouse, not this project — do not load it as authoritative; this file is.*

<!-- FIXED -->
## Working approach

State your reading of the task before acting. If the task is ambiguous or underspecified, stop and ask rather than guessing.

**Skills-heavy pattern.** Don't try to recall how each tool works cold. Load the matching skill on demand — the skills wrap the underlying scripts in `_tools/`.

<!-- FIXED -->
## Secrets & `.env`

Never shell-source a `.env` file (`source .env`, `. .env`, `set -a; . .env`). Sourcing executes it as shell code — a secret value containing `&` or spaces (e.g. a URL that is itself the credential) gets run as a background job and echoed into the session log, leaking it. Load `.env` with `python-dotenv`: `load_dotenv()` in code, or `python -c 'from dotenv import dotenv_values; print(dotenv_values()["KEY"])'` for a one-off. A `PreToolUse` hook (`.claude/hooks/guard-env-source.py`) blocks the unsafe form.

<!-- PLACEHOLDER — describe what this integration does:
     WHAT: which external platform, which surfaces (flows, apps, etc.).
     WHY:  why we maintain a Linux/CLI workflow for it.
     HOW:  how the skills + _tools/ combine; how to authenticate.
     Do NOT bake in design decisions (eviction policies, error-handling strategies,
     retry semantics, etc.) — those go in docs/adr/. CLAUDE.md describes shape;
     ADRs describe choices. -->
## What this project is

<WHAT / WHY / HOW.>

<!-- PLACEHOLDER — fill in the structure for this integration. -->
## Directory layout

```
<project>/
├── _tools/                 # reusable bash scripts (called by the skills)
├── <surface-a>/            # one folder per artifact (named by display name)
│   └── <Artifact_Name>/
│       ├── <surface>-meta.json     # {id-fields, displayName, exportedAt}
│       └── ...
├── <surface-b>/            # ...
└── .claude/skills/         # progressive-disclosure knowledge for agents
```

<!-- PLACEHOLDER -->
## Git conventions

- Remote: <PLACEHOLDER>
- Main branch: `main`
- Commit messages: imperative tense.

<!-- PLACEHOLDER — only if applicable -->
## Secrets

Real API keys live in `.secrets/` (gitignored, mode 700). Committed artifact files use `__<NAME>_PLACEHOLDER__` strings for secret-bearing variables; `_tools/<surface>-update.sh` substitutes the real value at push time.

<!-- FIXED -->
## Documentation philosophy

Skills wrap procedure. Library carries knowledge. For tool-integration projects, most useful knowledge **is** procedural ("how to export a flow") and lives in `.claude/skills/`. The library half (`glossary.md`, `docs/`) is lighter but not absent — vocabulary and durable architectural choices still need a home.

**No orphans** — every document reachable from this file via a chain of links.

<!-- FIXED + PLACEHOLDER pointer adjustments -->
## Documentation map

- **`README.md`** — human-facing entry; links back to this file.
- **`glossary.md`** — domain vocabulary (e.g. environment, solution, connector, ...). Read before naming anything.
- **`docs/reference/`** — first-party code documentation, if any. May be sparse or absent for tool-integration projects.
- **`docs/adr/`** — Architecture Decision Records (e.g. why pull-only vs push, why secrets live in `.secrets/`). 3-of-3 admission test.
- **`docs/domain/`** — non-vocabulary domain knowledge (platform-specific mechanics, gotchas, deprecation tracks).
- **`docs/planning/`** — open backlog (`future-work.md`, often: new surfaces to support) and the boundary rule vs. `.tickets/`. Indexed in `docs/planning/README.md`.
- **`analysis/YYYY-MM-DD-<topic>/INVESTIGATION.md`** — investigations.
- **`analysis/analysis-landscape.md`** — narrative across investigations.
- **`.tickets/`** — local issue tracker.
- **`.tickets/inbox/`** — incoming cross-repo tickets.
- **`_tools/`** — bash scripts wrapped by skills. See [`_tools/README.md`](_tools/README.md).
- **`<surface>/README.md`** — surface-specific conventions (display-name normalisation, meta-field semantics, push-vs-pull policy). One per declared surface dir. Does not list specific artifacts — artifacts churn, conventions stay stable.

<!-- FIXED -->
## Skills

`.claude/skills/<name>/SKILL.md` — procedural workflows. **The primary knowledge surface for this kind of project.** One skill per "how to do X with the tool" — discover, export, update, push, etc.

<!-- FIXED -->
## Memory

This project owns its knowledge in versioned docs, not in Claude's per-conversation auto-memory. When you learn something durable about this project — vocabulary, a domain mechanic, a decision, a fact about how the work is run — write it into its canonical home (`glossary.md` / `docs/domain/` / `docs/adr/` / `docs/planning/future-work.md`) rather than into a memory file. Auto-memory is for user preferences and cross-project habits; project facts belong in the repo, where they are versioned, reviewable, and visible to every other agent and every other machine.

## What does NOT belong in CLAUDE.md

How a specific tool surface works (write a skill). Step-by-step recipes (write a skill). Deep platform mechanics (`docs/domain/`). Anything that applies only to some tasks (put it where it belongs and let the agent find it).

<!-- FIXED -->
## Update rules

- **New tool surface or new verb** → add a skill in `.claude/skills/`.
- **Underlying bash logic** → add or update a script in `_tools/`.
- **Architectural decision passing 3-of-3** → new `docs/adr/NNNN-slug.md`.
- **New domain term resolved** → `glossary.md`.
- **New planned work** → `docs/planning/future-work.md`.
- **New artifact exported/imported** → the per-artifact subdirectory + `*-meta.json`.
- **New surface added** → create `<surface>/README.md` documenting the surface's conventions.

<!-- FIXED -->
## No orphans

Every document reachable from this file via a chain of links. The `/finish` skill sweeps for orphans.

<!-- FIXED -->
## Portability

This file also satisfies AGENTS.md.
