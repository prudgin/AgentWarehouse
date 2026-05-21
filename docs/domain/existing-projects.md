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

### `GutEvac`

Active research project on gut-clearance kinetics in farmed Murray cod. Goal: produce a defensible pre-harvest fasting recommendation (DH-at-5% threshold) and validate whether clearance is invariant under thermal-time scaling.

**What's there now**: 1900-line `gut_clearance.py` analysis script, `gut_clearance_implementation_spec_v2.md` (a near-PRD-quality spec), `working_notes_for_future_runs.txt` (known model issues + data-collection priorities), `Data trimmed.xlsx` (26 timepoints across 4 ponds, 17–28 °C only), processed temperature data from oxygen reports, output report + diagnostic PNGs, an interim PowerPoint, and a stage-1 proposal that diverged from what was actually collected. No CLAUDE.md, no `glossary.md`, no `docs/`. Solid declarative artefacts but no warehouse-style scaffolding.

**What's missing vs the target**: everything structural (CLAUDE.md, glossary.md, docs/{adr,domain,reference,planning}/, .tickets/, .claude/skills/). But latent knowledge density is high — the spec and notes seed several glossary entries (DH, hump model, c, m_arr/m_clr/m_emp, t=0, yesterday-stomach validation), several ADR-eligible decisions (binomial likelihood vs. asymmetric, two-meal independence assumption, pool-all-ponds, c-imputation policy, "% old feed" as validation-only), and a clean future-work seed (cold-band data, t=0 per pond, larger n, c as fitted parameter).

**Plan**: First migration target. Will be the first real exercise of the `/intake-target-project` → `/migrate-project` flow, and of the new `research/` template ([ADR-0024](../adr/0024-research-template-bidirectional-sharepoint-mirror.md)) — chosen over `analysis/` because GutEvac has an "official" SharePoint folder (`sharepoint_planning:PROJECTS/2026 Gut clearence/`) with stakeholder-accountable deliverables. Concrete steps: rename SharePoint folder `2026 Gut clearence` → `2026 Gut Clearance` (typo fix); rename SharePoint subfolders `Articles and background/` → `Articles/` and `Report/` → `Reports/`; move local repo to `~/ResearchProjects/2026 Gut Clearance/`; drop in `.rclone-filter` from the template; first sync establishes merged state. The contents of `working_notes_for_future_runs.txt` split into the canonical homes per ADR-0007: caveats → `docs/domain/known-issues.md`, follow-up priorities → `docs/planning/future-work.md`, methodology decisions → `docs/adr/`. No working-notes.md.

## `~/MicrosoftFlowsApps/`

A workshop for Microsoft Power Platform on Linux (Power Automate flows, Power Apps, Dataverse). 81-line CLAUDE.md. Knowledge lives in `.claude/skills/` (7 skills). No `docs/` directory — already follows the trigger-style progressive-disclosure pattern.

**What's there now**: Closest existing match to the **skills** half of the warehouse philosophy. CLAUDE.md explicitly says "Don't try to recall this knowledge cold — load the matching skill on demand." Skills wrap PAC CLI, flow export/update, app export, auth.

**What's missing vs the target**: `glossary.md` (probably useful — Power Platform has dense vocabulary: environment, solution, connector, BAP, etc.), `docs/adr/` (a few ADRs would be valuable: the canvas-app-push-gap rationale, the secrets-as-files convention), `.tickets/`.

**Plan**: Third migration target. The library half is mostly absent and adding it should improve the agent's onboarding for new tool surfaces (Dataverse solutions, etc. when they get tackled). Use `/migrate-project` with a tool-integration template variant (not yet built).

## Summary

| Repo | Has CLAUDE.md | Drift level | Migration order |
|---|---|---|---|
| `GutEvac` | No | High (no scaffolding, rich latent knowledge) | 1st |
| `FishGrowthFittingSGRpackage` | Yes (219 lines) | Low | 2nd |
| `MercatusDataFeed` | Yes (314 lines) | Medium | 3rd |
| `MicrosoftFlowsApps` | Yes (81 lines) | Low (different shape) | 4th |
| `GrowthModels` | No | N/A | When activated |
| `ModellingFishGrowth` | Yes (warehouse-shape from day one) | None (cold-started 2026-05-21) | N/A |
| `PowerBI` | No | N/A | When activated |

The migration order is also the validation order: each migration tests a different aspect of the warehouse (intake-from-zero, library skeleton, pipeline complexity, tool-integration variant).
