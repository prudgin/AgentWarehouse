# Migration plan — feeding-frequency-2023

Concrete step list for `/migrate-project feeding-frequency-2023` to execute against `/home/rndmanager/PycharmProjects/FeedingFrequency/FeedingFrequency2023`.

Final state:
- Local path: `~/ResearchProjects/2023 Feeding Frequency/`
- SharePoint mirror: `sharepoint_planning:PROJECTS/2023 Feeding Frequency/` (Title-Case-renamed from current `2023 Feeding frequency`)
- Template: `research`
- Git: `git init` post-migration; no remote yet.

## Phase 0 — Pre-flight

- [ ] Verify source repo path: `/home/rndmanager/PycharmProjects/FeedingFrequency/FeedingFrequency2023`.
- [ ] Verify SharePoint folder exists at `sharepoint_planning:PROJECTS/2023 Feeding frequency`.
- [ ] Verify no existing `~/ResearchProjects/2023 Feeding Frequency/` (would conflict). `~/ResearchProjects/` itself exists.
- [ ] Verify no in-flight unsaved work in the source repo. No git, so check for recently-edited files outside the well-known artefact dirs (`pipeline/fits/`, `pipeline/working/`, etc.).

## Phase 1 — Local move + rename (destructive-op: surface + confirm)

**1.1** Move project to `~/ResearchProjects/2023 Feeding Frequency/`:
```bash
mkdir -p ~/ResearchProjects
mv /home/rndmanager/PycharmProjects/FeedingFrequency/FeedingFrequency2023 "/home/rndmanager/ResearchProjects/2023 Feeding Frequency"
cd "/home/rndmanager/ResearchProjects/2023 Feeding Frequency"
```

After this, subsequent commands run inside the new location. Confirm before executing.

## Phase 2 — Local subdir renames + content moves (auto-runnable)

These reorganise the existing tree to the research template shape. Code moves under `src/` and `scripts/`; data renames per template convention; canonical inputs/reports move out of the local-only `source/` dir into the synced surface.

| From (in source repo) | To (in target shape) | Op |
|---|---|---|
| `data/` | `Data/` | rename |
| `data/raw_weight_samples_2023/` | `Data/raw-mcfarlane-2023/` | rename + kebab-case (parent dir already renamed in line above; this is the same dir) |
| `source/Data analysis feeding strategy.xlsx` | `Proposal/Data analysis feeding strategy.xlsx` | move (per user decision) |
| `source/Final report McFarlane's_DS.docx` | `Reports/Final report McFarlane's_DS.docx` | move (per user decision) |
| `source/` (now empty) | — | delete |
| `extract.py` | `scripts/extract.py` | move + adjust internal sys.path inserts |
| `pipeline/` | `src/feeding_frequency_2023/pipeline/` | move (whole tree) |
| `analyses/` | `src/feeding_frequency_2023/analyses/` | move (whole tree) |
| (none) | `src/feeding_frequency_2023/__init__.py` | create (empty) |
| (none) | `src/feeding_frequency_2023/pipeline/__init__.py` | create (empty if absent) |
| (none) | `src/feeding_frequency_2023/analyses/__init__.py` | create (empty if absent) |
| `docs/data_pipeline.md` | `docs/domain/data-pipeline.md` | move + rename (kebab) |
| `docs/filters_and_drops.md` | `docs/domain/filters-and-drops.md` | move + rename (kebab) |
| `docs/methodology_sgr.md` | `docs/domain/methodology-sgr.md` | move + rename (kebab) |
| `docs/methodology_sfr.md` | `docs/domain/methodology-sfr.md` | move + rename (kebab) |
| `docs/methodology_cross.md` | `docs/domain/methodology-cross.md` | move + rename (kebab) |
| `docs/methodology_pretrial.md` | `docs/domain/methodology-pretrial.md` | move + rename (kebab) |
| `docs/decisions_log.md` | `docs/adr/_legacy-decisions-log.md` | move + archive (kept for reference; ADR-0001..0004 extracted decisions from it) |
| Existing `README.md` | (overwritten by staged README.md, after preserving §"Cohort and trial design" and §"Headline results" into `docs/domain/trial-design.md` — done in Phase 3) | replace |

**Internal references to fix** (search-and-replace inside the moved files after moves complete):
- `docs/data_pipeline.md` and `docs/filters_and_drops.md` reference each other and `decisions_log.md` — paths change.
- `data/` → `Data/` everywhere (in docs and code defaults).
- `source/` → `Proposal/` / `Reports/` where it appears (in `extract.py`, `docs/data_pipeline.md`).
- Underscore → hyphen in cross-doc links (e.g. `filters_and_drops.md` → `filters-and-drops.md`).
- `pipeline/` → `src/feeding_frequency_2023/pipeline/` where it appears in docs.
- `analyses/` → `src/feeding_frequency_2023/analyses/` where it appears in docs.
- `extract.py` → `scripts/extract.py` in docs and any cross-reference.

**Code-side path fixes** (in `scripts/extract.py`, `src/feeding_frequency_2023/pipeline/build_*.py`, `src/feeding_frequency_2023/analyses/_common.py`, etc.):
- Default output dir for extract: `data/` → `Data/` (relative to project root; should be parameterised to project-root-relative if not already).
- `sys.path` inserts for `growth_models` (absolute) — unchanged.
- `sys.path` inserts for `MercatusDataFeed` (absolute) — unchanged.
- Any reads from `pipeline/audits/...` need to resolve to `src/feeding_frequency_2023/pipeline/audits/...` (or the code should use `__file__`-relative resolution which it likely already does — verify).
- Any reads from `source/...` → updated to `Proposal/...` for the xlsx.

This is the largest single source of breakage risk. After all renames, run `scripts/extract.py` end-to-end as a smoke test (Phase 7).

## Phase 3 — Transfer staged content (auto-runnable)

For every file under `target-projects/feeding-frequency-2023/` **except `_warehouse/`**, transfer to the target repo at the matching path:

| From staging | To target |
|---|---|
| `CLAUDE.md` | `CLAUDE.md` (overwrite the existing one; strip TEMPLATE META block first, though staged copy already has none) |
| `README.md` | `README.md` (overwrite — minimal one-liner pointing to CLAUDE.md; the existing content-rich README's load-bearing tables are preserved in `docs/domain/trial-design.md`) |
| `glossary.md` | `glossary.md` |
| `docs/adr/0001-trajectory-anchored-endpoint-sgr.md` | same |
| `docs/adr/0002-books-clean-filter-at-nine-percent.md` | same |
| `docs/adr/0003-spline-forecasting-mode.md` | same |
| `docs/adr/0004-hybrid-feed-source-workbook-and-mdf.md` | same |
| `docs/adr/README.md` | same |
| `docs/domain/README.md` | same |
| `docs/domain/trial-design.md` | same |
| `docs/planning/README.md` | same |
| `docs/planning/future-work.md` | same |

**Conflict handling**: the existing `README.md` has load-bearing tables (cohort sizes, headline results). These have been **distilled into** `docs/domain/trial-design.md` (already in staging). After transferring the staged README.md (which just points at CLAUDE.md), the existing content lives in `trial-design.md` and is reachable via CLAUDE.md → docs/domain/README.md → trial-design.md. Verify the headline-results and cohort-table content is fully captured before letting the staged README.md overwrite.

**CLAUDE.md** — staged copy has no TEMPLATE META block (already authored project-specific). Direct overwrite is fine.

## Phase 4 — Scaffolding from research template (auto-runnable)

- [ ] Create empty `Articles/` (no content yet — staged for future literature; `.gitkeep` if Git complains).
- [ ] Verify `Proposal/`, `Data/`, `Reports/`, `Expenses/` exist (will after Phase 2 moves; `Expenses/` is empty — `.gitkeep`).
- [ ] Drop `.rclone-filter` from `~/AgenticEngineering/templates/research/.rclone-filter` into project root.
- [ ] Create `.gitignore` carrying over the existing gitignore patterns plus standard research-template additions (`.venv/`, `__pycache__/`, `*.pyc`, `output/`, `pipeline/state/`, `pipeline/working/`, etc.).
- [ ] Create `analysis/` directory (empty; `.gitkeep`) and `analysis/analysis-landscape.md` (stub).
- [ ] Create `.tickets/` directory with `inbox/` subdir, both with `.gitkeep`.
- [ ] Create `output/` directory (empty; `.gitkeep` or omit if `.gitignore` covers).
- [ ] Symlink `AGENTS.md` → `CLAUDE.md`.

## Phase 5 — SharePoint folder rename + subfolder remap (destructive-op: surface each + confirm)

All operations are server-side `rclone move`. Fast but irreversible-without-undo. Surface each rename and confirm before executing.

**5.1** Rename the top-level folder for casing convention:
```bash
rclone move "sharepoint_planning:PROJECTS/2023 Feeding frequency" "sharepoint_planning:PROJECTS/2023 Feeding Frequency"
```

After this, subsequent rclone paths use the new name.

**5.2** Remap non-standard subfolders into template dirs:

```bash
rclone move "sharepoint_planning:PROJECTS/2023 Feeding Frequency/McFarlane's feeding trial_DS data" \
            "sharepoint_planning:PROJECTS/2023 Feeding Frequency/Data/raw-mcfarlane-2023"
rclone move "sharepoint_planning:PROJECTS/2023 Feeding Frequency/2026 review" \
            "sharepoint_planning:PROJECTS/2023 Feeding Frequency/Reports/2026-review"
rclone move "sharepoint_planning:PROJECTS/2023 Feeding Frequency/Feed sheets strategy trial" \
            "sharepoint_planning:PROJECTS/2023 Feeding Frequency/Proposal/Feed sheets strategy trial"
rclone move "sharepoint_planning:PROJECTS/2023 Feeding Frequency/Feeding strategy project" \
            "sharepoint_planning:PROJECTS/2023 Feeding Frequency/Proposal/Feeding strategy project"
```

**5.3** Move root protocol/treatment docs into `Proposal/` (also server-side):

```bash
rclone move "sharepoint_planning:PROJECTS/2023 Feeding Frequency/Twice daily feeding protocol.docx" \
            "sharepoint_planning:PROJECTS/2023 Feeding Frequency/Proposal/"
rclone move "sharepoint_planning:PROJECTS/2023 Feeding Frequency/Twice daily feeding protocol DS COPY.docx" \
            "sharepoint_planning:PROJECTS/2023 Feeding Frequency/Proposal/"
rclone move "sharepoint_planning:PROJECTS/2023 Feeding Frequency/Feeding strategy protocol.docx" \
            "sharepoint_planning:PROJECTS/2023 Feeding Frequency/Proposal/"
rclone move "sharepoint_planning:PROJECTS/2023 Feeding Frequency/mcfarlane treatment allocation.xlsx" \
            "sharepoint_planning:PROJECTS/2023 Feeding Frequency/Proposal/"
rclone move "sharepoint_planning:PROJECTS/2023 Feeding Frequency/mcfarlane treatment allocation DS.xlsx" \
            "sharepoint_planning:PROJECTS/2023 Feeding Frequency/Proposal/"
```

**5.4** Move root canonical inputs to their template targets:

```bash
rclone move "sharepoint_planning:PROJECTS/2023 Feeding Frequency/Data analysis feeding strategy.xlsx" \
            "sharepoint_planning:PROJECTS/2023 Feeding Frequency/Proposal/"
rclone move "sharepoint_planning:PROJECTS/2023 Feeding Frequency/Final report McFarlane's_DS.docx" \
            "sharepoint_planning:PROJECTS/2023 Feeding Frequency/Reports/"
rclone move "sharepoint_planning:PROJECTS/2023 Feeding Frequency/Final report McFarlane's_DS.pdf" \
            "sharepoint_planning:PROJECTS/2023 Feeding Frequency/Reports/"
```

After 5.4 the SharePoint root should be clean (only template dirs at root: `Articles/`, `Proposal/`, `Data/`, `Reports/`, `Expenses/`).

Verify with `rclone lsf "sharepoint_planning:PROJECTS/2023 Feeding Frequency/" --max-depth 1`.

## Phase 6 — Skills installation (auto-runnable)

```bash
mkdir -p .claude/skills
ln -s /home/rndmanager/AgenticEngineering/skills/start-analysis    .claude/skills/start-analysis
ln -s /home/rndmanager/AgenticEngineering/skills/finish-analysis   .claude/skills/finish-analysis
ln -s /home/rndmanager/AgenticEngineering/skills/sharepoint-sync   .claude/skills/sharepoint-sync
ln -s /home/rndmanager/AgenticEngineering/skills/finish            .claude/skills/finish
ln -s /home/rndmanager/AgenticEngineering/skills/diagnose          .claude/skills/diagnose
ln -s /home/rndmanager/AgenticEngineering/skills/check-inbox       .claude/skills/check-inbox
ln -s /home/rndmanager/AgenticEngineering/skills/file-cross-repo-ticket .claude/skills/file-cross-repo-ticket
ln -s /home/rndmanager/AgenticEngineering/skills/grill             .claude/skills/grill
ln -s /home/rndmanager/AgenticEngineering/skills/to-prd            .claude/skills/to-prd
ln -s /home/rndmanager/AgenticEngineering/skills/to-issues         .claude/skills/to-issues
ln -s /home/rndmanager/AgenticEngineering/skills/triage            .claude/skills/triage
ln -s /home/rndmanager/AgenticEngineering/skills/work-issue        .claude/skills/work-issue
```

(Match the set installed in the juvenile sibling.)

## Phase 7 — First SharePoint sync (destructive-op for push: surface + confirm)

**7.1** Pull (auto-safe, picks up SharePoint state for any items we haven't accounted for):
```bash
rclone copy "sharepoint_planning:PROJECTS/2023 Feeding Frequency" "$PWD" \
  --update --filter-from .rclone-filter --ignore-size --ignore-checksum --progress
```

Report counts and bytes.

**7.2** Push (destructive-op; surface count and total bytes; confirm):
```bash
rclone copy "$PWD" "sharepoint_planning:PROJECTS/2023 Feeding Frequency" \
  --update --filter-from .rclone-filter --ignore-size --ignore-checksum --progress
```

Surface any "size differs" warnings — expected for .xlsx/.docx/.pptx due to SharePoint rewrite-on-upload (data is fine).

## Phase 8 — Verify

- [ ] `.rclone-filter` exists at project root.
- [ ] `sharepoint-sync` symlinked under `.claude/skills/`.
- [ ] Project lives at `~/ResearchProjects/2023 Feeding Frequency/`.
- [ ] `rclone lsd "sharepoint_planning:PROJECTS/2023 Feeding Frequency"` succeeds.
- [ ] First sync produced no unrecoverable errors.
- [ ] No orphans: every doc in indexed dirs is listed in its parent README. Run a simple grep audit (every `*.md` outside `_legacy-decisions-log.md` should be linked from a `README.md` or `CLAUDE.md`).
- [ ] No broken internal links: `grep -roE '\(\.\.?/[^)]+\.md\)' --include='*.md' .` and spot-check each target exists.
- [ ] CLAUDE.md mentions every top-level directory.
- [ ] glossary.md follows the contract (canonical term, Avoid, definition, relationships, example, provenance).
- [ ] Run `scripts/extract.py` end-to-end (writes to `Data/*.csv`) — smoke test that path fixes in Phase 2 didn't break extraction.
- [ ] Run `src/feeding_frequency_2023/analyses/sgr/run.py` (or `$PY -m feeding_frequency_2023.analyses.sgr.run`) — smoke test that path fixes didn't break analyses.

Smoke tests are the most likely source of post-migration breakage. Surface failures explicitly with their tracebacks.

## Phase 9 — Git init (auto-runnable, NOT pushed)

```bash
git init
git add -A
git commit -m "Initial commit: migrated from PycharmProjects/FeedingFrequency/FeedingFrequency2023, reorganised onto AgenticEngineering research template"
```

No remote. User may add one later.

## Phase 10 — Mark staging complete

Update `_warehouse/status.md`:
- Status: `migrated`
- Completion date: today
- Target path: `~/ResearchProjects/2023 Feeding Frequency/`

Leave `_warehouse/` in the warehouse as institutional memory.

## Deferred (post-migration tickets, not blocking)

- `pyproject.toml` + `pip install -e .` (per "Open question 1" in `_warehouse/intake-notes.md`).
- Threshold sensitivity sweep on the 9% books-noisy filter (`docs/planning/future-work.md`).
- Bootstrap CIs on cross-plot points (`docs/planning/future-work.md`).
