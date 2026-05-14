# Migration plan — 2026 Juvenile gut evac

For `/migrate-project juvenile` to execute. Source: `/home/rndmanager/PycharmProjects/FeedingFrequency/Juvenile`. Target: `~/ResearchProjects/2026 Juvenile gut evac/`. SharePoint mirror: `sharepoint_planning:PROJECTS/2026 Juvenile gut evac/`.

## Phase 0 — Pre-flight

- Create `~/ResearchProjects/` if it does not exist (this is the canonical location for research-template projects; see ADR-0024 in the warehouse).
- Create `~/ResearchProjects/2026 Juvenile gut evac/` as the target directory.
- Initialise git inside the target: `git init`. Local-only, `main` branch.

## Phase 1 — Create directory skeleton

```
~/ResearchProjects/2026 Juvenile gut evac/
├── Articles/                       # populated by sharepoint-sync pull (Phase 5)
├── Proposal/                       # populated by sharepoint-sync pull (Phase 5)
├── Data/                           # populated by sharepoint-sync pull (Phase 5)
├── Reports/                        # populated by sharepoint-sync pull (Phase 5)
├── Expenses/                       # populated by sharepoint-sync pull (Phase 5)
├── analysis/                       # empty for now; first /start-analysis populates
├── src/juvenile_ger/               # empty package skeleton
├── scripts/                        # populated in Phase 2
├── docs/{adr,domain,reference,planning}/
├── output/                         # .gitkeep
├── .tickets/inbox/                 # .gitkeep
└── .claude/skills/                 # populated in Phase 6
```

Add `.gitkeep` to `output/` and `.tickets/inbox/`. Add `__init__.py` to `src/juvenile_ger/`.

## Phase 2 — Move existing files from source repo

| From (source repo) | To (target) | Notes |
|---|---|---|
| `BilbulFishCensus/build_census.py` | `scripts/build_census.py` | tracked; standalone script (Q7-A: option (a) — keep flat in `scripts/`, not packaged). |
| `BilbulFishCensus/Bilbul_fish_census_2026-05-04.xlsx` | (deleted) | Regeneratable from `scripts/build_census.py`. The SharePoint `Data/Bilbul 12-05-2026.xlsx` is the in-flight trial dataset and supersedes this snapshot. |
| `CLAUDE.md` (461-line scope+selection doc) | (split — see Phase 3) | NOT copied verbatim. Content already split into staging dir; the source file is retired. |
| `BilbulFishCensus/` directory itself | (removed after move) | Empty after the moves above. |

After moves, the source repo can be archived or deleted. Recommend: leave it in place but stop touching it; the user may want to consult it.

## Phase 3 — Add files from staging

Copy every file under `target-projects/juvenile/` (except `_warehouse/`) to the matching path in the target repo:

- `CLAUDE.md` → `CLAUDE.md`
- `README.md` → `README.md` (overwrite the staging placeholder; the user can extend later)
- `glossary.md` → `glossary.md`
- `docs/adr/README.md`
- `docs/adr/0001-t0-anchor-via-prefast-and-sentinel.md`
- `docs/adr/0002-normalisation-by-t0-batch-mean.md`
- `docs/adr/0003-three-family-aic-kinetic-comparison.md`
- `docs/domain/README.md`
- `docs/domain/data-shape.md`
- `docs/reference/README.md`
- `docs/reference/cage-selection.md`
- `docs/planning/README.md`
- `docs/planning/future-work.md`

## Phase 4 — Add files from the research template

- `AGENTS.md` → symlink to `CLAUDE.md`.
- `.gitignore` from `templates/research/.gitignore`. Project-specific appends: `output/*` (keep `.gitkeep`), `__pycache__/`, `*.pyc`, `.venv/`, `/tmp/jge-pull/` if any.
- `.rclone-filter` from `templates/research/.rclone-filter`. No project-specific overrides needed for the first cut — re-evaluate after first push (`Data/` may grow large; if a single trial-date file exceeds tens of MB, consider a filter exclusion, but unlikely given current ~16 kB sizes).
- `.claude/settings.json` from `templates/research/.claude/settings.json`. Preserve any `.claude/settings.local.json` if present in source (none in this case).
- `analysis/README.md` from `templates/research/analysis/README.md`.
- `analysis/analysis-landscape.md` from `templates/research/analysis/analysis-landscape.md`. Initially empty body — first `/start-analysis` populates the first entry.
- `.tickets/README.md` from `templates/research/.tickets/README.md` (or `templates/analysis/.tickets/README.md` if research template doesn't have one yet — they're identical).
- `pyproject.toml` — minimal. Bare-name deps: `numpy`, `scipy`, `pandas`, `matplotlib`, `openpyxl`. `[project.scripts]` entry: `bilbul-census = "scripts.build_census:main"` (or skip the entry if scripts/ is treated as not-packaged — leave decision to first-time pyproject hand-edit by user; default: no entry, run as `python scripts/build_census.py`).
- `Reports/README.md` — index. Initially: "No interim reports yet — first investigation pending."
- `Articles/README.md` — index of the 5 reference PDFs once pulled.
- `Proposal/README.md` — one-line: "Canonical methods document is `Bilbul_GER_trial_proposal.md`. `Notes on trial design.docx` is supplementary."
- `Data/README.md` — references `docs/domain/data-shape.md` for the recording schema.
- `Expenses/README.md` — one-line: finance / receipts.

## Phase 5 — SharePoint folder convert + first sync

1. **Rename SharePoint subfolders** (destructive on remote — confirmed by user):
   - `Articles and background/` → `Articles/`
   - `Report/` → `Reports/`
   Use `rclone moveto` for each. Verify with `rclone lsd sharepoint_planning:"PROJECTS/2026 Juvenile gut evac"` afterwards.
2. **First pull** (target → from remote): `rclone copy sharepoint_planning:"PROJECTS/2026 Juvenile gut evac" "~/ResearchProjects/2026 Juvenile gut evac" --update --filter-from .rclone-filter`. This populates `Articles/`, `Proposal/`, `Data/`, `Reports/`, `Expenses/` from the existing SharePoint contents.
3. **First push** (local → remote): `rclone copy "~/ResearchProjects/2026 Juvenile gut evac" sharepoint_planning:"PROJECTS/2026 Juvenile gut evac" --update --filter-from .rclone-filter`. This pushes the new agent infrastructure (`CLAUDE.md`, `glossary.md`, `docs/`, ...). Code is filtered out by `.rclone-filter`.

Verify after both syncs: `Data/Bilbul 12-05-2026.xlsx`, `Proposal/Bilbul_GER_trial_proposal.md`, and the 5 PDFs in `Articles/` are present locally. `Reports/` is empty (or contains whatever was already there).

## Phase 6 — Skills installation

Symlink from `~/AgenticEngineering/skills/<name>/` into `.claude/skills/`:

**Analyse-chain (primary):**
- `start-analysis`
- `finish-analysis`

**SharePoint:**
- `sharepoint-sync`

**Build-chain (for edits to `src/juvenile_ger/` and `scripts/`):**
- `grill`
- `to-prd`
- `to-issues`
- `triage`
- `work-issue`
- `finish`

**Cross-cutting:**
- `diagnose`
- `file-cross-repo-ticket`
- `check-inbox`

**Skip:**
- `improve-codebase-architecture` (no code yet to improve)
- `intake-target-project`, `create-project`, `migrate-project` (warehouse-only)
- `sudo-script` (lives in `~/.claude/skills/`, globally installed)

## Phase 7 — Verify

- Every directory referenced in `CLAUDE.md` exists.
- Every `docs/<area>/README.md` lists its files.
- `glossary.md` cross-links resolve to existing files (data-shape.md, cage-selection.md, ADR-0001/0002/0003).
- `docs/adr/README.md` lists ADRs 0001–0003.
- `analysis/analysis-landscape.md` exists (empty initially).
- `Data/Bilbul 12-05-2026.xlsx` present.
- `Proposal/Bilbul_GER_trial_proposal.md` present.
- `AGENTS.md` resolves to `CLAUDE.md`.
- `rclone check` agreement between local and SharePoint for synced surface (modulo agent infra newly pushed).
- No broken markdown links inside the migrated tree.

## Deferred — NOT done by `/migrate-project`

These get tracked as tickets after migration:

1. **First investigation campaign.** Once Cohort C (the in-flight one) hits all six timepoints, run `/start-analysis` and create `analysis/<YYYY-MM-DD>-cohort-c-ger-fit/INVESTIGATION.md`. Implement the three-family AIC fit on Cohort C and report t at 20 % residual ± CI. File a ticket.
2. **`src/juvenile_ger/` package contents.** Shared loaders (long-form Excel reader, batch aggregator, π estimator, AIC fitter, bootstrap CI). Write as the first investigation needs them. File a ticket once the package shape settles.
3. **Cross-link to feeding-frequency sibling project.** When the user sets up the feeding-frequency project, file a cross-repo ticket from there to here referencing the GER curves as design input. Also reciprocal link in `docs/planning/future-work.md` FW-DN-01.
4. **First commit strategy.** After the migration working tree is in place, three commits:
   - C1: import existing files as-is (scripts/build_census.py).
   - C2: warehouse docs and scaffolding (CLAUDE.md, glossary, docs/, ADRs).
   - C3: first sharepoint-sync pull (Articles/, Proposal/, Data/, etc.).
   The user (or follow-up agent session) drives this; not part of `/migrate-project` per its skill spec.
