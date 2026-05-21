# Migration plan — modelling-fish-growth

Executable handoff for `/create-project modelling-fish-growth`. Cold-start.

## Inputs

- **Source repo:** `~/PycharmProjects/ModellingFishGrowth` (git init, zero commits, ~5 existing files).
- **Template:** `templates/analysis/`.
- **Target directory:** `~/PycharmProjects/ModellingFishGrowth` (already exists; scaffold *into* it, do not re-create).
- **Ticket backend:** `.tickets/` local.
- **Git remote:** `https://github.com/prudgin/ModellingFishGrowth` (already created on GitHub).
- **Companion repos:**
  - `~/PycharmProjects/GrowthModels` → editable install.
  - `~/PycharmProjects/FishGrowthFittingSGRpackage` → editable install.

## Step 1 — Scaffold the analysis template into the existing dir

Copy contents of `templates/analysis/` into `~/PycharmProjects/ModellingFishGrowth/`. **Preserve** the existing source files (`idea.md`, `docs/sgr_conventions.md`, `docs/literature_review.md`, `Articles/`, `.git/`) — they get moved/ported in Step 2.

Substitute placeholders in the template files:
- `<PLACEHOLDER: project name>` → `modelling-fish-growth`
- `<PLACEHOLDER>` git remote → `https://github.com/prudgin/ModellingFishGrowth`

Strip TEMPLATE META comment blocks.

## Step 2 — Transfer staged content from `target-projects/modelling-fish-growth/`

Replace the template's stubs with staged content:

| Staging source                                     | Project destination                                          | Action  |
|----------------------------------------------------|--------------------------------------------------------------|---------|
| `CLAUDE.md`                                        | `CLAUDE.md`                                                  | Replace |
| `glossary.md`                                      | `glossary.md`                                                | Replace |
| `docs/adr/0001-canonical-surface-lives-in-growth-models.md` | `docs/adr/0001-canonical-surface-lives-in-growth-models.md` | Copy    |
| `docs/adr/0002-iterative-refit-vs-nlme.md`         | `docs/adr/0002-iterative-refit-vs-nlme.md`                   | Copy    |
| `docs/adr/0003-per-cycle-alpha-structure.md`       | `docs/adr/0003-per-cycle-alpha-structure.md`                 | Copy    |
| `docs/adr/0004-glencross-2012-starting-form.md`    | `docs/adr/0004-glencross-2012-starting-form.md`              | Copy    |
| `docs/adr/0005-log-space-residuals.md`             | `docs/adr/0005-log-space-residuals.md`                       | Copy    |
| `docs/domain/model.md`                             | `docs/domain/model.md`                                       | Copy    |
| `docs/planning/future-work.md`                     | `docs/planning/future-work.md`                               | Copy    |

After copying, append an entry to `docs/adr/README.md` (or create it from the template index) listing the five initial ADRs.

## Step 3 — Port existing source content

In the project repo (paths relative to project root):

| Source path                  | Project destination               | Action |
|------------------------------|-----------------------------------|--------|
| `idea.md`                    | `docs/design/initial-idea.md`     | Move + create `docs/design/` and `docs/design/README.md` (one-line index) |
| `docs/sgr_conventions.md`    | `docs/domain/sgr-conventions.md`  | Move (analysis-template `docs/domain/` already exists; remove the `sgr_conventions.md` file from `docs/` root after move) |
| `docs/literature_review.md`  | `docs/domain/literature-review.md`| Move (same as above) |
| `Articles/`                  | `Articles/`                       | Keep at root; add an entry to `CLAUDE.md` docmap (already drafted) |

Update `docs/domain/README.md` to index the three files (`model.md`, `sgr-conventions.md`, `literature-review.md`) and to mention `known-issues.md` is created lazily.

## Step 4 — Create src/ scaffolding

This project differs from the analysis-template default by carrying first-party code from day one (see CLAUDE.md and intake-notes Step 5c).

- Create `src/modelling_fish_growth/__init__.py` (empty stub with module docstring).
- Create `docs/reference/README.md` indexing `src/modelling_fish_growth/`. Mark the dir as **mandatory** (override of analysis-template default).
- Create `pyproject.toml`:
  - Package name: `modelling-fish-growth`.
  - Bare-name dependencies (no version pins): `growth-models`, `fish-growth-fitting-sgr-package`, plus the usual suspects (`numpy`, `scipy`, `pandas`, `matplotlib`).
  - Optional deps `[test]`: `pytest`, `pytest-cov`.
- Create `tests/` directory with a placeholder `tests/test_smoke.py` (assert `import modelling_fish_growth`).

## Step 5 — Venv + editable installs

```
cd ~/PycharmProjects/ModellingFishGrowth
python -m venv .venv
source .venv/bin/activate
pip install -e ~/PycharmProjects/GrowthModels
pip install -e ~/PycharmProjects/FishGrowthFittingSGRpackage
pip install -e ".[test]"
```

Verify with `python -c "import growth_models; import fish_growth_fitting_sgr_package; import modelling_fish_growth"`.

## Step 6 — `.gitignore`

Carry the template default; add project-specific entries:

```
.venv/
/mnt/data
*.pkl
analysis/*/artifacts/  # intermediate per-iteration surfaces, diagnostic plots
# but DO commit the INVESTIGATION.md and source scripts in each analysis dir
!analysis/*/INVESTIGATION.md
!analysis/*/*.py
```

(Question for create-project: confirm exclusion pattern works for the existing PDFs in `Articles/` — those should be tracked, not gitignored. Default template `.gitignore` doesn't exclude PDFs, so this should be a no-op. Verify.)

## Step 7 — Install skills

Symlink the standard skill set into `.claude/skills/` from `~/AgenticEngineering/skills/<name>`:

- Build chain: `grill`, `to-prd`, `to-issues`, `triage`, `work-issue`, `finish`.
- Analyse chain: `start-analysis`, `finish-analysis`.
- Cross-cutting: `diagnose`, `improve-codebase-architecture`, `zoom-out`, `file-cross-repo-ticket`, `check-inbox`.

Skip research-specific skills (`sharepoint-sync`) — not applicable.

## Step 8 — `AGENTS.md` portability

Create `AGENTS.md` as a symlink to `CLAUDE.md`.

## Step 9 — Initial commit and push

```
cd ~/PycharmProjects/ModellingFishGrowth
git add -A
# do NOT git add data/ or .venv/
git commit -m "Scaffold from AgenticEngineering analysis template with intake-staged content"
git branch -M main  # source repo defaults to master; rename to main per CLAUDE.md convention
git remote add origin https://github.com/prudgin/ModellingFishGrowth.git
git push -u origin main
```

(Source repo currently has `master` branch with no commits; rename to `main` is harmless.)

## Step 10 — Verification

After scaffolding:

- `/finish`-style doc audit: every file in the repo reachable from `CLAUDE.md` via link chain.
- `python -c "import modelling_fish_growth"` succeeds.
- `growth_models.sgr` callable from inside the project venv.
- `git log` shows the initial commit; `git remote -v` shows the GitHub URL; `git push` succeeded.

## Open questions for create-project to surface (not block on)

- **Final-artefact handoff format** to `growth_models` — coefficients file, callable variant, pickle? Not blocking scaffolding; will be resolved during first investigation.
- **Intermediate artefact layout** — per-investigation under `analysis/<dated>/artifacts/` initially; project-level `artifacts/` may emerge if cross-investigation reuse appears.
