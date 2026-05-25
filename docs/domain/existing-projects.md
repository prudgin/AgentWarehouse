# Existing Projects

State of the user's existing repositories surveyed during the warehouse design, and what's planned for each.

## `~/PycharmProjects/`

### `FishGrowthFittingSGRpackage`

A Python package for fish growth simulation and fitting. The cleanest existing agentic setup — the closest match to the target shape. Has a 219-line CLAUDE.md, `docs/reference/` + `docs/planning/`, and (uniquely) the `analysis/YYYY-MM-DD-<topic>/INVESTIGATION.md` pattern (the warehouse renamed this file from the source repo's `REPORT` per ADR-0020) with 17+ dated investigation dirs and a cross-cutting landscape narrative.

**What's there now**: Strict single-canonical-home discipline, append-only `decisions.md`, the dated-analysis tree.

**What's missing vs the target**: `glossary.md` at root with the ubiquitous-language contract, `docs/adr/` (replacing `decisions.md`), `docs/domain/` (currently absent), `.claude/skills/`, `.tickets/`.

**Plan**: First migration target. Lowest distance from the template; highest signal that the migration playbook works. Will use `/migrate-project` (planned) once that skill exists.

### `MercatusDataFeed`

Aquaculture data pipeline (Mercatus OData → ledger → SGR → publish → Power BI). Most complex existing setup, 314-line CLAUDE.md, `docs/reference/` + `docs/planning/` + `docs/domain/`, `.claude/agents/` (subagents), `.claude/state/working-notes.md`.

**What's there now**: Most of the target structure is already in place. Has the `docs/domain/` directory the warehouse adopts. Documents three Python naming conventions, shared venv across siblings, two-zone data layout.

**What's missing vs the target**: Same as Fish (glossary contract, ADRs, no-orphan README indexes). Plus needs to drop subagents and working-notes ([ADR-0007](../adr/0007-no-subagents-no-ephemeral-notes.md)). The "Bash command style rules" section in CLAUDE.md is obsolete (auto mode obviates the safety-check workarounds) and should move out — the user noted a `/sudo-script` global skill replaces what's still useful.

**Plan**: Second migration target. Larger payoff (more drift to clean up) but trickier because of the multi-project shared venv and the satellite repos that read from this one.

### `GrowthModels`

Support package — `growth_models.sgr`, `growth_models.sfr`, `growth_models.fcr`. No CLAUDE.md; no `.claude/`. Pip-installed editable into `MercatusDataFeed`'s shared venv.

**Plan**: Set up agentically when the user starts work on it. The user wants it self-contained — should have its own CLAUDE.md and not transitively rely on Mercatus's context. Use the `library` template via `/create-project`.

### `ModellingFishGrowth`

Per-cycle iterative refit of `SGR(T, W)` for Murray cod (*Maccullochella peelii*) from operational pond data. Cold-started 2026-05-21 from the `analysis` template via `/intake-target-project` → `/create-project`. Consumes `growth_models` and `FishGrowthFittingSGRpackage` as editable installs; converged surface ships back to `growth_models` (ADR-0001 inside the project).

**What's there now**: Warehouse-shape from day one — CLAUDE.md, glossary.md, 5 ADRs (canonical-surface-home, iterative-refit-vs-NLME, per-cycle α structure, Glencross-2012 starting form, log-space residuals), `docs/domain/{model.md, sgr-conventions.md, literature-review.md}`, `docs/design/initial-idea.md` (frozen 2026-05 design doc), `src/modelling_fish_growth/`, `pyproject.toml`, 13 skill symlinks, AGENTS.md alias. Remote `github.com/prudgin/ModellingFishGrowth` configured (not yet pushed).

**Plan**: First investigation will exercise the iterative refit against operational cycles from `/mnt/data`. Open ends: handoff format for the final coefficients into `growth_models`; whether intermediate artefacts get a project-level `artifacts/` dir or stay per-investigation. Convert to `pipeline` template once the fit stabilises.

### `PowerBI`

Power BI dashboards project. Sophisticated docs structure (architecture, conventions, data-contract, dashboards/, authoring/, planning/) but no CLAUDE.md. Called as a subprocess CLI by `MercatusDataFeed`.

**Plan**: Same as `GrowthModels` — set up when the user is ready, encapsulated, not transitively dependent.

### `GutEvac` → `~/ResearchProjects/2026 Gut Clearance/`

Active research project on gut-clearance kinetics in farmed Murray cod. Goal: produce a defensible pre-harvest fasting recommendation (DH-at-5% threshold) and validate whether clearance is invariant under thermal-time scaling.

**Migration status**: done. Migrated 2026-05-04 (initial intake + transfer of staging) onto the `analysis/` template, then bumped to `research/` template 2026-05-14 – 2026-05-22 (Title Case `Data/`/`Articles/`/`Proposal/`/`Reports/`, `.rclone-filter`, `.register/`, `sharepoint-sync` + `update-register-entry` skills). Canonical-pullback pass on 2026-05-25 removed leftover `docs/proposal/` duplicate, indexed `Articles/`, and brought CLAUDE.md path references from lowercase into Title Case. SharePoint mirror at `sharepoint_planning:PROJECTS/2026 Gut Clearance`.

**Validated**: the `/intake-target-project` → `/migrate-project` flow end-to-end, the `research/` template ([ADR-0024](../adr/0024-research-template-bidirectional-sharepoint-mirror.md)), `/sharepoint-sync`, the rename-on-SharePoint authority pattern (typo `clearence` → `Clearance`, `Articles and background/` → `Articles/`, `Report/` → `Reports/`), and the `working_notes_for_future_runs.txt` split per ADR-0007 (caveats → `docs/domain/known-issues.md`, follow-up priorities → `docs/planning/future-work.md`, methodology decisions → `docs/adr/`).

**Outstanding**: large uncommitted research-template bring-up in the project working tree (21 `D` lowercase-path deletes + 8 `??` Title Case adds + canonical-pullback edits) — captured by `/finish` in the project, not the warehouse. Surfaced (not auto-resolved): `Reports/16_04_2025 interim report.pptx` is a likely-SharePoint-rewrite duplicate of `Reports/2026-04-16-interim.pptx`. See `target-projects/gutevac/_warehouse/status.md` for the full record.

## `~/ResearchProjects/research-overseer/`

Overarching research agent. Cold-started 2026-05-22. Tool-integration-template based, with `analysis/` first-class and a new `docs/strategy/` dir for roadmap/themes/gaps. Local-only (no git remote); bidirectional SharePoint mirror at `sharepoint_planning:Research overseer/`. Sibling of the per-project research repos under `~/ResearchProjects/`.

**What's there now**: Six ADRs covering the canonical-yaml-not-XLSX trust direction, stable identity via a Slug column, 1:1:1 mapping (row : repo : entry.yaml), tiered auth gate for destructive SharePoint ops, write-scope limited to `sharepoint_planning:`, and the `/finish` hook for `/update-register-entry`. Domain doc captures the 32-column register schema and controlled vocabularies. Skills installed: `sharepoint-sync`, `start-analysis`, `finish-analysis`, `file-cross-repo-ticket`, `check-inbox`, `finish`, `diagnose`, `improve-codebase-architecture`, `zoom-out` (warehouse) + `reconcile-register`, `detect-drift`, `sweep-sharepoint-cleanup`, `apply-sharepoint-cleanup` (new, overseer-specific).

**What's missing vs the target**: The 27 existing register rows lack slugs (one-time migration on first `/reconcile-register`). The 28+ existing per-project repos under `~/ResearchProjects/` lack `.register/entry.yaml` (each gets one when its agent next runs `/update-register-entry`, typically from `/finish`). The `gutevac` vs `stanbridge-gutevac` and `feeding-frequency-2023` vs `feeding-frequency-juvenile` cardinality conflicts need a human decision on first sweep.

**Plan**: First operational sweep is a manual `/reconcile-register` to populate slugs and surface conflicts. Then weekly scheduled run for ongoing maintenance.

## `~/MicrosoftFlowsApps/`

**Status: migrated to tool-integration template on 2026-05-25** (4th migration; commits `604b119` / `ab323df` / `414e667` on `prudgin/MicrosoftFlowsApps@master`).

A workshop for Microsoft Power Platform on Linux (Power Automate flows, Power Apps, Dataverse). The migration:

- Installed warehouse scaffold: `glossary.md`, `docs/{adr,domain,planning,reference}/`, `analysis/`, `.tickets/` with READMEs.
- `.claude/skills/` now holds 23 symlinks to warehouse canonical sources — 10 Power Platform (`power-platform-auth`, `pac-cli-linux`, `flows-*`, `apps-*`, `proxy-flow-scaffolding`, `anthropic-api-integration`) + 13 warehouse-general (`grill`, `to-prd`, `to-issues`, `triage`, `work-issue`, `finish`, `start-analysis`, `finish-analysis`, `diagnose`, `improve-codebase-architecture`, `zoom-out`, `file-cross-repo-ticket`, `check-inbox`).
- Per-flow `CLAUDE.md` for each of 8 flows; per-app `CLAUDE.md` for `WQ_WaterQuality_sp`.
- Aquna-prefixed nested repo (`flows/Aquna_Farm_Reports_Ingestion/` with its own `.git/`) was absorbed: ADRs promoted to parent `docs/adr/`, glossary entries merged, folder renamed to `Farm_Reports_Ingestion`.
- 13 entries cleared from per-project Claude memory after distribution to durable docs.

**Validation outcome**: `tool-integration` template variant held up — the `_tools/` + `flows/*/` + `apps/*/` + skills-heavy shape was right. The optional `docs/reference/` decision held: project's `docs/reference/` is sparse (procedural knowledge lives in skills). `docs/domain/` is the heavy doc directory (cross-cutting facts: WQ data model, parameter labels, YSI dilution, tenant-specific SharePoint auth). One real surprise: the project had **drift between project-local and warehouse-canonical skill copies** because the project ran ahead during real use; the migration playbook needed a "harvest drift back into warehouse" step before symlinking. Warehouse skill bodies now carry the merged-back detail (commit `2ff0db5` on warehouse).

## Summary

| Repo | Has CLAUDE.md | Drift level | Migration order |
|---|---|---|---|
| `GutEvac` → `~/ResearchProjects/2026 Gut Clearance/` | Yes (warehouse-shape since 2026-05-04; research-template bump 2026-05-22; canonical-pullback 2026-05-25) | None (migrated) | done (1st, validated `research/`) |
| `FishGrowthFittingSGRpackage` | Yes (219 lines) | Low | 2nd |
| `MercatusDataFeed` | Yes (314 lines) | Medium | 3rd |
| `MicrosoftFlowsApps` | Yes (warehouse-shape since 2026-05-25) | None (migrated) | done (4th, validated `tool-integration/`) |
| `GrowthModels` | No | N/A | When activated |
| `ModellingFishGrowth` | Yes (warehouse-shape from day one) | None (cold-started 2026-05-21) | N/A |
| `PowerBI` | No | N/A | When activated |

The migration order is also the validation order: each migration tests a different aspect of the warehouse (intake-from-zero, library skeleton, pipeline complexity, tool-integration variant).
