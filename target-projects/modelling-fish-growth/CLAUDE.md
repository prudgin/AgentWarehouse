# CLAUDE.md — modelling-fish-growth

*This project was scaffolded from the AgenticEngineering warehouse's `analysis` template. The warehouse's own `CLAUDE.md` describes the warehouse, not this project — do not load it as authoritative; this file is.*

## Working approach

State your reading of the task before acting. If the task is ambiguous or underspecified, stop and ask rather than guessing. If multiple approaches exist, present tradeoffs — do not pick silently. For multi-step work, outline a brief plan with verification checks before starting.

**Analyse-first.** This is a research project. The default workflow is to start an investigation (`/start-analysis`), do the work in a dated dir, finalise it (`/finish-analysis`), and let findings settle into `glossary.md`, `docs/domain/`, `docs/adr/`, or `docs/planning/future-work.md`. The build chain is available — `src/modelling_fish_growth/` carries reusable fitter code from day one, and adding a CLI is fair game — but is not the centre of gravity yet.

**Pipeline conversion planned.** Once the iterative fit stabilises through a few analysis rounds, this project will convert to the `pipeline` template (or layer pipeline shape on top of the analysis tree). See `docs/planning/future-work.md`.

## What this project is

**WHAT.** Per-cycle iterative refit of a `SGR(T, W)` surface for Murray cod (*Maccullochella peelii*) from operational pond data — sparse noisy weight samples, feed records, harvest yields. The fit starts from the Glencross-2012 parametric form (barramundi coefficients as initial shape) and refits Murray cod coefficients across iteration rounds. Companion downstream surfaces: SFR and farm-realised FCR (waste feed, black loss, weighting error all baked in).

**WHY.** No published parametric `SGR(T, W)` surface exists for Murray cod (see `docs/domain/literature-review.md` §1). The iterative refit approach is also methodologically novel — closest precedent is Mayer/Estruch on seabream and the Dumas critique of single-curve TGC fits. The fitted surface ships back to `growth_models` (ADR-0001) where it becomes the canonical Murray cod `SGR(T, W)` for downstream consumers.

**HOW.** Five steps per iteration round: init surface → per-cycle α fit → per-day quality weights → re-bin and refit → check convergence. Driven from `src/modelling_fish_growth/`; investigations under `analysis/<dated>/` exercise the driver and write up findings. Input data lives at `/mnt/data` (gitignored, external mount). Intermediate / candidate surfaces and diagnostics live in this repo (under `analysis/<dated>/artifacts/`). Final converged surface ships to `~/PycharmProjects/GrowthModels`.

See `docs/domain/model.md` for the full methodology.

## Git conventions

- Remote: `https://github.com/prudgin/ModellingFishGrowth`
- Main branch: `main`
- Commit messages: imperative tense.

## Documentation philosophy

Every fact has a single canonical home. Other documents link to it rather than restate it. **No orphans** — every document reachable from this file via a chain of links. CLAUDE.md indexes top-level directories; each top-level directory has a `README.md` that indexes its contents.

CLAUDE.md lists what exists and when to read it. Skills (`.claude/skills/`) wrap procedural workflows. Library (`glossary.md`, `docs/`, `analysis/`) carries declarative knowledge. The centre of gravity is `analysis/` and `docs/domain/`.

**Findings provenance.** Claims that land in `glossary.md`, `docs/domain/`, or `docs/adr/` link back to the `analysis/<dated>/INVESTIGATION.md` that produced them. Provenance is what keeps the substrate honest as the research evolves. (The four ADRs and the initial domain docs predate any investigation — their provenance is `docs/design/initial-idea.md`.)

## Documentation map

- **`README.md`** — human-facing entry; links back to this file.
- **`glossary.md`** — project-specific vocabulary (SGR conventions, α, cycle, black loss, companion packages). Read before naming anything.
- **`analysis/YYYY-MM-DD-<topic>/INVESTIGATION.md`** — investigations. **The primary work surface.** Each dated dir holds scripts, `artifacts/`, and the writeup.
- **`analysis/analysis-landscape.md`** — narrative across all investigations. Single entry point that links every INVESTIGATION.
- **`docs/domain/`** — non-vocabulary domain knowledge:
  - `model.md` — distilled methodology (Steps 0–5, daily step, restocking jumps, two-stage α). The canonical methodology reference.
  - `sgr-conventions.md` — formula hygiene (Crane-correct `%·d⁻¹`), per-cycle α convention, daily step, Glencross 2008 / 2012 coefficient tables.
  - `literature-review.md` — Murray cod prior work, alternative parametric forms (Björnsson-Steinarsson, Brière-2, Sharpe-Schoolfield), cycle-filtering context (iridovirus, EHN, hypoxia, treatments).
  - `known-issues.md` — created lazily as issues surface.
- **`docs/design/`** — frozen design history.
  - `initial-idea.md` — original 2026-05 design doc this project was set up from. Frozen reference; current methodology lives in `docs/domain/model.md`.
- **`docs/adr/`** — Architecture Decision Records. 3-of-3 admission test. The five initial ADRs (0001–0005) cover canonical surface home, iterative-refit vs NLME, per-cycle α structure, Glencross-2012 starting form, log-space residuals.
- **`docs/reference/`** — module-level docs for `src/modelling_fish_growth/`. **Mandatory** in this project (the analysis-template default of "optional" doesn't apply — we have first-party code from day one).
- **`docs/planning/`** — open backlog (`future-work.md`) and the boundary rule vs. `.tickets/`.
- **`Articles/`** — PDFs of background literature (Glencross 2008, 2009, 2011; Crane SGR misuse). Read for the source material behind `sgr-conventions.md` and `literature-review.md`.
- **`src/modelling_fish_growth/`** — first-party code: iterative-refit driver, binning + weighted regression, convergence tracking, restocking integration on top of `FishGrowthFittingSGRpackage`. Documented per-module in `docs/reference/`.
- **`.tickets/`** — local issue tracker.
- **`.tickets/inbox/`** — incoming cross-repo tickets (e.g. from `growth_models` flagging a coefficient handoff need).

## Companion packages

This project consumes two sibling packages via editable installs into its own venv (`~/PycharmProjects/ModellingFishGrowth/.venv`):

- **`growth_models`** (`~/PycharmProjects/GrowthModels`) — owns the canonical `SGR(T, W)` callable, the `0.0067 %·d⁻¹` biological floor, and the formula conventions. This project's converged surface ships here (ADR-0001).
- **`FishGrowthFittingSGRpackage`** (`~/PycharmProjects/FishGrowthFittingSGRpackage`) — owns the per-cycle fitter (`alpha`, `log_alpha`, `SplineFit`, `simulation.py`). This project's iterative driver calls into it.

Editable installs mean companion-side edits are picked up live without reinstall. When a cross-repo change is needed (e.g. a new coefficient slot in `growth_models`), use `/file-cross-repo-ticket` to drop a ticket in that repo's inbox.

## Skills

`.claude/skills/<name>/SKILL.md` — procedural workflows. The most-used pair on a research project is `/start-analysis` and `/finish-analysis`. Symlinked from `~/AgenticEngineering/skills/<name>` so canonical edits propagate.

Installed: `start-analysis`, `finish-analysis`, `finish`, `grill`, `to-prd`, `to-issues`, `triage`, `work-issue`, `diagnose`, `improve-codebase-architecture`, `zoom-out`, `file-cross-repo-ticket`, `check-inbox`.

## What does NOT belong in CLAUDE.md

Methodology details (`docs/domain/model.md` or the relevant INVESTIGATION). Step-by-step procedures (a skill or `docs/reference/`). Specific findings (the INVESTIGATION they came from, plus a glossary/domain promotion). Code-level docs (`docs/reference/<module>.md`). Anything that applies only to some tasks.

## Update rules

When you change behaviour, update the doc that describes it. A task is not done until the docs match the state of the project.

- **Investigation completed** → finalise `analysis/<date>-<topic>/INVESTIGATION.md` and register in `analysis/analysis-landscape.md`. Promote findings to `glossary.md` / `docs/domain/` / `docs/adr/` / `future-work.md` as applicable.
- **Methodology decision passing 3-of-3** → new `docs/adr/NNNN-slug.md`, with provenance link.
- **New domain term resolved** → add to `glossary.md`, with provenance link.
- **New domain mechanic discovered** → add to or extend a file in `docs/domain/`, with provenance link.
- **First-party code change in `src/modelling_fish_growth/`** → update the relevant `docs/reference/<module>.md`.
- **Cross-repo change needed in `growth_models` or `FishGrowthFittingSGRpackage`** → `/file-cross-repo-ticket`.
- **New planned work** → `docs/planning/future-work.md`.
- **Project structure change** → update this file.

## No orphans

Every document reachable from this file via a chain of links. The `/finish` skill sweeps for orphans. Every analysis subdir must be linked from `analysis/analysis-landscape.md`.

## Portability

This file also satisfies the AGENTS.md convention. `AGENTS.md` is a symlink to this file.
