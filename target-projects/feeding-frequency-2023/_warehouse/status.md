# Status

- **Target**: feeding-frequency-2023 (staging name)
- **Final project name**: `2023 Feeding Frequency` (Title Case — SharePoint renamed to match)
- **Mode**: migration
- **Source repo**: `/home/rndmanager/PycharmProjects/FeedingFrequency/FeedingFrequency2023` (moved — original path no longer exists)
- **Target local path**: `~/ResearchProjects/2023 Feeding Frequency/`
- **SharePoint mirror**: `sharepoint_planning:PROJECTS/2023 Feeding Frequency/`
- **Template**: research (per ADR-0024)
- **Started**: 2026-05-14
- **Completed**: 2026-05-14
- **Status**: migrated
- **Skill version**: migrate-project as of 2026-05-14

## Outcome

- ✅ Local move: `mv FeedingFrequency2023 → ~/ResearchProjects/2023 Feeding Frequency`
- ✅ Local reorganisation: `data/ → Data/`, `source/* → Proposal/Reports/`, `extract.py → scripts/`, `pipeline/ → src/pipeline/`, `analyses/ → src/analyses/`, `docs/methodology_* → docs/domain/methodology-*` (kebab-case rename)
- ✅ Decisions log split: 4 ADRs extracted (ADR-0001..0004); residual operational entries archived to `docs/adr/_legacy-decisions-log.md`
- ✅ Staged content transferred: CLAUDE.md, glossary.md, ADRs, docs/domain/trial-design.md, docs/domain/README.md, docs/adr/README.md, docs/planning/{README,future-work}.md
- ✅ Research-template scaffolding: `.rclone-filter`, `AGENTS.md→CLAUDE.md` symlink, `analysis/analysis-landscape.md` stub, `.tickets/inbox/` empty dirs, 12 skill symlinks under `.claude/skills/`
- ✅ Code path adjustments: 7 scripts updated for the new tree layout; smoke tests pass (build_cage_day returns 1818 rows × 17 cols × 32 cages = canonical books-clean cohort)
- ✅ SharePoint folder renamed: `2023 Feeding frequency` → `2023 Feeding Frequency` (two-step case-only rename via TMPCASE intermediate)
- ✅ SharePoint subfolder remap: `McFarlane's feeding trial_DS data/ → Data/raw-mcfarlane-2023/`, `2026 review/ → Reports/2026-review/`, `Feed sheets strategy trial/ + Feeding strategy project/ → Proposal/`
- ✅ SharePoint root cleanup: 8 root files moved into Proposal/Reports
- ✅ First bidirectional sync: 48 files pulled, 80 files pushed (~24.4 MiB up)
- ✅ Git initialised: `main` branch, initial commit created. No remote.

## Smoke-test result

```
build_cage_day() → shape (1818, 17), 32 unique cages
First row: pond=1, cage=2, date=2023-07-20, sim_weight_g≈257.0, sfr_real_pct≈0.40
```

Matches the pre-migration canonical books-clean cohort. No regression.

## Open follow-ups (deferred — see docs/planning/future-work.md)

- `pyproject.toml` + `pip install -e .` to clean up sys.path inserts (low priority; works as-is)
- Threshold sensitivity sweep on the 9% books-noisy filter
- Bootstrap CIs on cross-plot points

## Sibling projects (status as of 2026-05-14)

1. `~/ResearchProjects/2026 Juvenile gut evac/` — migrated previously (warehouse staging at `target-projects/juvenile/`)
2. **`~/ResearchProjects/2023 Feeding Frequency/`** — migrated this session
3. `~/ResearchProjects/2026 RAS feeding frequency/` — migrated previously (no staging in warehouse — possibly migrated in a different session)
