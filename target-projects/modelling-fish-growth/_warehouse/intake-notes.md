# Intake notes — modelling-fish-growth

Raw notes from the intake conversation. Captures user phrasing for fuzzy or unresolved branches.

## Source material audited (pre-intake)

- `idea.md` — Per-cycle iterative fitting approach. Murray cod. Five-step process: initial Glencross surface → per-cycle α fit (constant, then spline α(t)) → per-day quality weights → re-bin and refit Glencross coefficients → iterate. Downstream SFR/FCR derived from the two surfaces. Diagnostics: residual heat maps, bin-count heat maps, per-cycle α(t) plots, coefficient tracking. Joint NLME-ODE fit deferred to future-work.
- `docs/sgr_conventions.md` — Crane-correct SGR conventions (`%·d⁻¹`, never `100·g`). Per-cycle α scales the percent rate. Daily step formula. Restocking-as-jump biomass conservation. Glencross 2008 vs 2012 forms with coefficient tables; project starts from 2012.
- `docs/literature_review.md` — No published parametric SGR(T,W) for Murray cod (novel). Per-cycle deviation-spline iterative refit also methodologically novel. Alternatives: Björnsson-Steinarsson, Brière-2, Sharpe-Schoolfield-high. Cycle filtering context: iridovirus, EHN, hypoxia, percarbonate/formalin treatment windows.

## Decisions

- **Template:** `analysis` (2026-05-21). Reason: primary loop is "data → investigation → findings" for at least the first milestones; pipeline conversion deferred to future-work.
- **Future template migration:** once the iterative fit stabilises, convert to `pipeline` template (or layer pipeline shape on top of analysis). Stages roughly mirror `idea.md` §Process. See `docs/planning/future-work.md`.
- **Companion-package coupling:** editable installs (`pip install -e ~/PycharmProjects/GrowthModels` and `pip install -e ~/PycharmProjects/FishGrowthFittingSGRpackage`) into a project-local venv at `~/PycharmProjects/ModellingFishGrowth/.venv`. Companion-side edits picked up live.
- **Code locus:** `src/modelling_fish_growth/` from day one (not the analysis-template default of "scripts in analysis/<dated>/, promote later"). Reason: per-cycle fit + binning + weighted refit + convergence tracking already have clear abstractions in `idea.md`. Implication: `docs/reference/` is mandatory in this project (the analysis template marks it optional).
- **Data flow:**
  - **Inputs:** `/mnt/data` — external mount, gitignored. Repo loads cycles from there via config / env var.
  - **Intermediate artefacts:** in-repo. Includes per-iteration candidate surfaces, diagnostic plots, binning outputs, residual maps. Likely under `analysis/<dated>/artifacts/` per investigation, with the option of a project-level `artifacts/` if cross-investigation reuse emerges.
  - **Final artefact:** the converged Murray cod `SGR(T, W)` surface is written into `~/PycharmProjects/GrowthModels` so that package remains the canonical surface provider. Handoff protocol TBD — see Open questions.

## Open questions

- **Final-artefact handoff format.** Coefficients-only export (JSON/TOML committed into `GrowthModels`)? A new callable / variant in `growth_models.sgr`? Pickled model? Decision needed before the first round converges; not blocking scaffolding.
- **Intermediate-artefact layout.** Per-investigation (`analysis/<dated>/artifacts/`) is the analysis-template default and works for first rounds; a project-level `artifacts/` or `models/` dir would be needed if intermediate surfaces get shared across investigations. Defer until the second investigation surfaces the need.
- **Git remote.** No remote set in source repo yet. Need a value (likely a GitHub repo under `prudgin/`) before `/create-project` can wire it.
