# Intake notes — gutevac

Raw conversation notes, fuzzy areas, exact user phrasing.

## Anchor

User: "This is an ongoing research project. it has a stage 1 draft proposal but in reality the research went in a bit different way. So far I have collected some data and did a preliminary analysis, but I will be collecting more data and doing more analysis."

Migration of `/home/rndmanager/PycharmProjects/GutEvac` to warehouse conventions.

## Audit (from pre-skill exploration)

- Single-module pipeline `gut_clearance.py` (~72 KB, ~2k lines) implementing two-meal hump model.
- Spec doc `gut_clearance_implementation_spec_v2.md` — operative spec the code follows.
- Working notes `working_notes_for_future_runs.txt` — known issues + priorities (April 2026).
- Stage 1 proposal `Stage 1 draft proposal 16-12-2025.docx` — research diverged from this.
- Interim report (pptx) and current report (docx).
- `output/` with text report + 6 diagnostic PNGs + presentation subset.
- `raw data/Data trimmed.xlsx` — actual fit data; 4 ponds × 26 timepoints, 17–27 °C.
- `raw data/Farm 04 Oxygen Reports/` — 3 years monthly oxygen reports + `process_temperature.py` + `processed/` hourly CSVs. Preliminary work for cold-band trial DH calculation.
- `old analysis/` — earlier methods (peasant, hump) superseded.
- `.claude/settings.local.json` exists; no skills, no CLAUDE.md, no docs structure.
- Not a git repo. Has `.venv` (undocumented deps). No `pyproject.toml` / `requirements.txt`.

Headline result: DH at 5% = 1218 (CI 1072–1351), ≈ 61 h at 20 °C.

## Resolved

- **Project shape**: research; pipeline is the working tool, deliverable is the external write-up. → analyse-chain dominant; build-chain for pipeline edits.
- **Template**: `analysis` (with `docs/reference/` opted in — single canonical Python module worth a writeup). Switched from initial `library` choice once the new `analysis` template variant landed; GutEvac is literally named as its closest analogue.
- **Code locus**: package — `src/gut_clearance/`, `pyproject.toml` with bare-name deps. Submodule split deferred to migration plan (suggest: `load.py`, `model.py`, `fit.py`, `derived.py`, `plots.py`, `report.py`, `cli.py`).
- **Temperature script**: `scripts/process_temperature.py`. Stays a sibling utility; promotion into the package is a future ticket (likely tied to cold-band data + end-to-end Python DH pipeline).
- **Data layout**: `raw data/` → `data/raw/` (and `data/raw/processed/`). `Data trimmed.xlsx` moves into `data/raw/`.
- **Versioning policy**:
  - Tracked: `Data trimmed.xlsx`, `degree_hours_recalculated.csv`, ChartData CSVs, `data/raw/processed/*.csv`, all writeups (move to `reports/`), Stage 1 proposal (move to `docs/proposal/`).
  - Gitignored: `Farm 04 Oxygen Reports/*.xlsx` (regenerable, grows monthly), `output/` (with `.gitkeep`), `.venv/`, `__pycache__/`.
  - `working_notes_for_future_runs.txt` → promote to `docs/domain/known-issues.md`.
  - `old analysis/` → move to `archive/` (tracked, for provenance).
- **Three-source-of-truth routing**:
  - `Stage 1 draft proposal 16-12-2025.docx` → `docs/proposal/stage-1-2025-12-16.docx` + `docs/proposal/README.md` explaining divergence + pointer to ADR-0001.
  - `gut_clearance_implementation_spec_v2.md` → `docs/reference/model-spec.md`.
  - `working_notes_for_future_runs.txt` → split: domain knowledge → `docs/domain/known-issues.md`; backlog items → `docs/planning/future-work.md`.
- **ADR-0001 drafted**: `docs/adr/0001-divergence-from-stage-1-proposal.md` — divergence from Stage 1 proposal. User confirmed divergence list matches reality. Framing: proposal is intention/rationale, not obligation; future departures may be filed as further ADRs.

- **Glossary**: 9 entries drafted in `glossary.md` — Degree-hours (DH), Pond, Eating fraction (c), Hump model, Two-meal combination, t=0 row, Today feed / Old feed, Harvest fasting period, DH at 5 %. Each entry uses warehouse contract (Avoid / definition / relationships / example / flagged / provenance).
- **ADRs drafted**:
  - 0001 — Divergence from Stage 1 proposal.
  - 0002 — Two-meal hump with standard binomial likelihood.
  - 0003 — Harvest threshold convention: fraction of all fish.
- **DH-precomputed rule**: kept as a hard sentence in `docs/domain/data-shape.md` rather than promoted to ADR.
- **Domain docs**: `model.md`, `data-shape.md`, `known-issues.md` drafted. `working-notes.md` dropped (overlaps with `known-issues.md` + `future-work.md` + per-REPORT meta — feed this back to the warehouse template as a future-work item).
- **Future-work**: 11 items drafted in `docs/planning/future-work.md`, grouped data-collection / model-and-analysis / operational. Promoted from the original `working_notes_for_future_runs.txt` items 7–10 plus script-level changes section.
- **First analysis dir**: retrofit `analysis/2026-04-16-warm-band-fit/REPORT.md` during migration, pointing at existing `output/` and `reports/gut_clearance_report.docx`. Labels existing work as Investigation #1; makes cross-references from glossary/ADRs/domain docs point somewhere real.
- **Tickets**: keep `.tickets/` (empty initially). Useful for short concrete code/protocol changes that aren't open-ended investigations.
- **Git**: local-only initially (no remote). Can add later. Three commits during migration: (1) import existing files as-is, (2) migration moves/renames, (3) add warehouse docs.

## Open branches
