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

For research projects whose primary deliverable is a body of investigations (INVESTIGATIONs + plots + interpretation), not a public API or a multi-stage pipeline. Local-only — no external mirroring. For investigations done on top of an existing repo, or quick research projects without stakeholder accounting.

Differs from `library/`: analyse chain dominant (CLAUDE.md leads with `/start-analysis` → `/finish-analysis`); `analysis/` promoted to first place in the doc map; `docs/reference/` marked optional (often empty for pure-research projects); `docs/domain/` pre-suggests `model.md`, `data-shape.md`, `known-issues.md`. No `working-notes.md` (per ADR-0007 — content splits between `known-issues.md`, `future-work.md`, and ADRs). Adds the **findings provenance** rule: every promoted claim links the INVESTIGATION that produced it.

[Browse →](../../templates/analysis/)

### `research/`

For "official" MCA research projects whose deliverables (data, proposals, reports, references) are accountable to a SharePoint folder under `sharepoint_planning:PROJECTS/`. Closest analogue: `GutEvac` (after migration: `~/ResearchProjects/2026 Gut Clearance/` mirroring `sharepoint_planning:PROJECTS/2026 Gut Clearance/`).

Differs from `analysis/`: adds five "synced surface" dirs at root (`Articles/`, `Proposal/`, `Data/`, `Reports/`, `Expenses/`) matching the user's existing SharePoint convention; ships a `.rclone-filter` defining what does NOT sync (code, build artefacts, secrets, agent install — everything else, *including* `CLAUDE.md`, `glossary.md`, `docs/`, `.tickets/`, `analysis/`, mirrors to SharePoint by design); ships the `/sharepoint-sync` skill in `.claude/skills/`. CLAUDE.md adds a "SharePoint mirror" section explaining the model. Project lives under `~/ResearchProjects/<Project Name>/` (Title Case, spaces, matches the SharePoint folder name verbatim). See [ADR-0024](../adr/0024-research-template-bidirectional-sharepoint-mirror.md).

[Browse →](../../templates/research/)

## Shared guardrails

Every template ships a `PreToolUse` Bash hook at `.claude/hooks/guard-env-source.py` (wired in `.claude/settings.json`) that **blocks shell-sourcing a `.env` file** (`source .env`, `. .env`, `set -a; . .env`). Sourcing executes the file as shell code, so a secret value containing `&` or spaces (e.g. a URL that is itself the credential) leaks into the session log; the hook blocks the call and points the agent at the safe `python-dotenv` loader. It is the content-aware companion to the curated allow/deny list ([ADR-0023](../adr/0023-templates-ship-curated-broad-allow-list.md)) — the deny list matches command prefixes, this hook inspects the whole command. See [ADR-0026](../adr/0026-pretooluse-hook-blocks-shell-sourcing-env.md). The warehouse itself ships the same hook (dogfooding).

## Customising a template

Placeholder markers used in templates:

- `<!-- FIXED -->` — section is part of the convention; do not edit between projects.
- `<!-- PLACEHOLDER ... -->` — section needs project-specific content; comment is a hint.
- `<PLACEHOLDER: ...>` — inline value to replace.

The `/create-project` skill substitutes the project name automatically and asks about the rest.
