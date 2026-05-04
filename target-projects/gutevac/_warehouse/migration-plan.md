# Migration plan — gutevac

For `/migrate-project gutevac` to execute against `/home/rndmanager/PycharmProjects/GutEvac`. Produces a working tree on the user's machine; commits and code refactors are explicitly deferred (see "Deferred" at the end).

## Phase 0 — Pre-flight

- Initialise git: `git init`. Local-only, main branch.
- Add `.gitignore` from `templates/analysis/.gitignore`. Append project-specific patterns:
  - `data/raw/Farm 04 Oxygen Reports/*.xlsx`
  - `output/`
  - `__pycache__/`
  - `.venv/`
  - `*.pyc`

## Phase 1 — Create directory skeleton

```
src/gut_clearance/
scripts/
data/raw/
docs/{adr,domain,reference,planning,proposal}/
reports/
archive/
analysis/2026-04-16-warm-band-fit/
output/
.tickets/inbox/
.claude/skills/
```

Add `.gitkeep` to `output/` and `.tickets/inbox/`.

## Phase 2 — Move existing files (no content changes)

| From (source repo) | To | Notes |
|---|---|---|
| `Data trimmed.xlsx` | `data/raw/Data trimmed.xlsx` | tracked |
| `raw data/degree_hours_recalculated.csv` | `data/raw/degree_hours_recalculated.csv` | tracked |
| `raw data/Farm 04 Oxygen Reports/*.xlsx` | `data/raw/Farm 04 Oxygen Reports/*.xlsx` | gitignored after move |
| `raw data/Farm 04 Oxygen Reports/*.csv` | `data/raw/Farm 04 Oxygen Reports/*.csv` | tracked |
| `raw data/Farm 04 Oxygen Reports/processed/*.csv` | `data/raw/Farm 04 Oxygen Reports/processed/*.csv` | tracked |
| `raw data/Farm 04 Oxygen Reports/process_temperature.py` | `scripts/process_temperature.py` | tracked |
| `gut_clearance_implementation_spec_v2.md` | `docs/reference/model-spec.md` | tracked; the operative spec |
| `Stage 1 draft proposal 16-12-2025.docx` | `docs/proposal/stage-1-2025-12-16.docx` | tracked; preserved verbatim |
| `gut_clearance_report.docx` | `reports/gut_clearance_report.docx` | tracked |
| `16_04_2025 interim report.pptx` | `reports/2026-04-16-interim.pptx` | rename to ISO date order; the file's content is the April 2026 interim |
| `old analysis/` | `archive/old_analysis/` | tracked, kept for provenance |
| `gut_clearance.py` | `src/gut_clearance/__main__.py` | makes `python -m gut_clearance` work; submodule split deferred |
| `working_notes_for_future_runs.txt` | `archive/working_notes_2026-04.txt` | content already promoted to `docs/domain/known-issues.md` and `docs/planning/future-work.md`; kept for provenance |
| `__pycache__/` | (deleted) | regenerable |

`process_temperature.py` resolves paths via `Path(__file__).resolve().parent` — it'll keep working after the move because the script and the data both relocate. **Verification step**: after move, run `python scripts/process_temperature.py` and confirm outputs match.

## Phase 3 — Add files from staging

For every file under `target-projects/gutevac/` (except `_warehouse/`), copy to the matching path in the source repo:

- `CLAUDE.md` → `CLAUDE.md`
- `glossary.md` → `glossary.md`
- `README.md` → `README.md` (overwrite the staging placeholder; project-specific README is the user's to write or extend)
- `docs/adr/0001-divergence-from-stage-1-proposal.md`
- `docs/adr/0002-two-meal-hump-binomial-likelihood.md`
- `docs/adr/0003-harvest-threshold-convention.md`
- `docs/domain/model.md`
- `docs/domain/data-shape.md`
- `docs/domain/known-issues.md`
- `docs/planning/future-work.md`

## Phase 4 — Add files NOT from staging (template-style scaffolding)

- `AGENTS.md` → symlink to `CLAUDE.md`.
- `.claude/settings.json` from `templates/analysis/.claude/settings.json`. If the source repo's `.claude/settings.local.json` has user overrides, preserve it (do not overwrite).
- `analysis/README.md` from `templates/analysis/analysis/README.md`.
- `analysis/analysis-landscape.md` from `templates/analysis/analysis/analysis-landscape.md`. Add one entry for the warm-band run (see Phase 5).
- `docs/adr/README.md` from `templates/analysis/docs/adr/README.md`. Update its index to list ADRs 0001–0003.
- `docs/domain/README.md` from `templates/analysis/docs/domain/README.md`. Update its index to list `model.md`, `data-shape.md`, `known-issues.md`.
- `docs/reference/README.md` from `templates/analysis/docs/reference/README.md`. Update its index to list `model-spec.md`.
- `docs/planning/README.md` — one-line index pointing to `future-work.md`. (Create if absent in template.)
- `docs/proposal/README.md` — short doc explaining the proposal is preserved verbatim and pointing readers to ADR-0001 for the divergence.
- `reports/README.md` — index of `gut_clearance_report.docx` and `2026-04-16-interim.pptx` with one-line descriptions.
- `archive/README.md` — explains contents are superseded; lists `old_analysis/` and `working_notes_2026-04.txt`.
- `.tickets/README.md` from `templates/analysis/.tickets/README.md`.
- `pyproject.toml` — minimal, bare-name deps:
  - `numpy`, `scipy`, `pandas`, `matplotlib`, `openpyxl`.
  - `[project.scripts]` entry: `gut-clearance = "gut_clearance.__main__:main"`.

## Phase 5 — Retrofit Investigation #1 (warm-band run)

Create `analysis/2026-04-16-warm-band-fit/REPORT.md`. Short doc (~1 page) summarising the warm-band run:

- Dates: April 2026.
- Data: 4 ponds, 26 timepoints, 17–28 °C.
- Method: two-meal hump model, binomial likelihood, parametric bootstrap CIs (B = 500). Cross-link to ADR-0002.
- Headline: DH at 5 % = 1218 (95 % CI 1072–1351), ≈ 61 h at 20 °C.
- Goodness-of-fit: chi-square p = 0.011 (stomach), 0.028 (intestine). Borderline — see KI-05.
- Outputs: `output/` (regenerated by re-running pipeline) and `reports/gut_clearance_report.docx` (canonical write-up for this run).
- Issues surfaced: KI-01 through KI-06 — all fed into `docs/domain/known-issues.md`.
- Next steps: cold-band data (FW-DC-01); see `docs/planning/future-work.md`.

Add an entry for this run in `analysis/analysis-landscape.md`.

## Phase 6 — Skills installation

Symlink from the warehouse into `.claude/skills/`:

- `start-analysis`, `finish-analysis` (analyse-chain — primary)
- `grill`, `to-prd`, `to-issues`, `triage`, `work-issue`, `finish` (build-chain — for pipeline edits and ticket work)
- `diagnose` (cross-cutting; useful when a fit goes weird)
- `improve-codebase-architecture` (will be useful for the deferred `gut_clearance.py` refactor)
- `file-cross-repo-ticket`, `check-inbox` (cross-cutting)

Skip warehouse-only skills: `intake-target-project`, `create-project`, `migrate-project`.

## Phase 7 — Verify

- Every dir referenced in `CLAUDE.md` exists.
- Every `docs/<area>/README.md` lists its files.
- `glossary.md` cross-links resolve to existing files (model-spec.md, known-issues.md, future-work.md, ADRs).
- `analysis/analysis-landscape.md` lists every dir under `analysis/`.
- No broken markdown links inside the migrated tree.

## Deferred — NOT done by `/migrate-project`

These get tracked as tickets after migration:

1. **Code refactor.** Split `src/gut_clearance/__main__.py` (the existing 2k-line module) into submodules: `load.py`, `model.py`, `fit.py`, `derived.py`, `plots.py`, `report.py`, `cli.py`. File a ticket; use `/improve-codebase-architecture` to plan it.
2. **Three commits.** After the migration working tree is in place, make:
   - Commit 1: import existing files as-is (pre-migration snapshot).
   - Commit 2: migration moves and renames (Phase 2).
   - Commit 3: warehouse docs and scaffolding (Phases 3–6).
   The user (or a follow-up agent session) drives this; not part of `/migrate-project` per its skill spec.
3. **End-to-end Python DH pipeline** — already tracked as FW-MA-04 in `future-work.md`.
4. **Tighten `w_arr` lower bound + fitted *c*** — already tracked as FW-MA-01 in `future-work.md`.
