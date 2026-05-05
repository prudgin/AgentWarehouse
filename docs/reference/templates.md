# Templates

Project skeletons under `templates/<type>/`. Each is a directory tree that can be copied wholesale into a new project location and customised by filling `<PLACEHOLDER>` markers.

## Available

### `library/`

For Python packages, libraries, and standalone projects with a clear public API. Closest analogue in the user's existing repos: `FishGrowthFittingSGRpackage`.

Includes: `CLAUDE.md`, `README.md`, `glossary.md`, `docs/{reference,adr,domain,planning}/`, `analysis/`, `.tickets/`, `.claude/skills/`, baseline `.gitignore` and `.claude/settings.json`.

[Browse →](../../templates/library/)

### `pipeline/`

For multi-stage data pipelines, often with a shared venv across siblings. Closest analogue: `MercatusDataFeed`.

Differs from `library/`: CLAUDE.md adds a "Pipeline areas" table and an optional "Shared venv" section. `docs/reference/` README encourages one file per stage (instead of per module). `docs/domain/` README pre-suggests `data-model.md`, `mechanics.md`, `known-anomalies.md` (created lazily as you go).

[Browse →](../../templates/pipeline/)

### `tool-integration/`

For wrappers around external tools or platforms. Closest analogue: `MicrosoftFlowsApps`.

Differs from `library/`: skills-heavy, library-light pattern (CLAUDE.md says "load skill on demand"). Adds a `_tools/` directory at the repo root for tool-wrapping bash scripts (skills wrap these). `docs/reference/` is optional / sparse — most procedural knowledge lives in skills.

[Browse →](../../templates/tool-integration/)

### `analysis/`

For research projects whose primary deliverable is a body of investigations (INVESTIGATIONs + plots + interpretation), not a public API or a multi-stage pipeline. Closest analogue: `GutEvac` (gut-clearance research on Murray cod), and the `analysis/` portion of `FishGrowthFittingSGRpackage`.

Differs from `library/`: analyse chain dominant (CLAUDE.md leads with `/start-analysis` → `/finish-analysis`); `analysis/` promoted to first place in the doc map; `docs/reference/` marked optional (often empty for pure-research projects); `docs/domain/` pre-suggests `model.md`, `data-shape.md`, `known-issues.md`. No `working-notes.md` (per ADR-0007 — content splits between `known-issues.md`, `future-work.md`, and ADRs). Adds the **findings provenance** rule: every promoted claim links the INVESTIGATION that produced it.

[Browse →](../../templates/analysis/)

## Customising a template

Placeholder markers used in templates:

- `<!-- FIXED -->` — section is part of the convention; do not edit between projects.
- `<!-- PLACEHOLDER ... -->` — section needs project-specific content; comment is a hint.
- `<PLACEHOLDER: ...>` — inline value to replace.

The `/create-project` skill substitutes the project name automatically and asks about the rest.
