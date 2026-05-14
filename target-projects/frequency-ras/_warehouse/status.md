# Status

- **Target**: frequency-ras (staging name)
- **Final project name**: `2026 RAS feeding frequency`
- **Mode**: migration
- **Source repo**: `/home/rndmanager/PycharmProjects/FeedingFrequency/FrequencyRAS`
- **Target local path**: `/home/rndmanager/ResearchProjects/2026 RAS feeding frequency/`
- **SharePoint mirror**: `sharepoint_planning:PROJECTS/2026 RAS feeding frequency/`
  - URL: https://murraycod.sharepoint.com/Planning%20%20Development/Forms/AllItems.aspx?id=%2FPlanning%20%20Development%2FPROJECTS%2F2026%20RAS%20feeding%20frequency
- **Template**: research (per ADR-0024)
- **Started**: 2026-05-14
- **Migration completed**: 2026-05-14 (initial), 2026-05-14 (canonical-pullback fix-up)
- **Status**: migrated
- **Skill version**: migrate-project (pre-`7f7d129`, before canonical-pullback was made auto)

## Fast-path note

This staging dir was created **post-hoc on 2026-05-14**, after a follow-up session noticed the original migration had left non-canonical SharePoint shape (`Articles and background/` not renamed, empty `Report/` folder). The original migration ran without an intake interview, inheriting decisions from sibling `juvenile/` (`2026 Juvenile gut evac`) and `gutevac/` (`2026 Gut Clearance`) — i.e. "clone the juvenile setup" fast path.

Implicit decisions taken from siblings:
- Title Case project name with year prefix.
- Research template.
- `.rclone-filter` excluding `src/`, `scripts/`, `data/`, `output/`, build artefacts, agent install.
- Canonical local subdir names from `templates/research/`: `Articles/`, `Proposal/`, `Data/`, `Reports/`, `Expenses/`, `analysis/`, `docs/`.

What the fast path **missed** that an interview would have caught:
- The SharePoint folder had `Articles and background/` instead of `Articles/` — this should have been renamed during migration, but the previous skill version surfaced it as a per-item confirmation and the rename was deferred with a "pending user call" stub in CLAUDE.md.
- A stray empty `Report/` folder (singular) existed alongside `Reports/` on SharePoint, not pruned.

## Auto-applied canonical renames (2026-05-14, post-hoc cleanup)

- Local: `git mv "Articles and background" Articles` (commit `d3800c2` in target repo).
- Local docs updated: CLAUDE.md (2 refs), README.md (1 ref), `Articles/README.md` (rewritten).
- SharePoint: `rclone move sharepoint_planning:PROJECTS/2026 RAS feeding frequency/Articles\ and\ background sharepoint_planning:PROJECTS/2026 RAS feeding frequency/Articles` — 5 files relocated.
- SharePoint: `rclone rmdir sharepoint_planning:PROJECTS/2026 RAS feeding frequency/Report` — empty stray removed.

## Outcome of this case

Surfaced the bug behind `7f7d129` (warehouse commit, 2026-05-14): `migrate-project` Phase 3 step 5 and `sharepoint-sync` line 110 both treated canonical-pullback renames as destructive-ops requiring per-item confirmation. The fix made canonical-pullbacks auto and narrowed sharepoint-sync's refusal list to genuine data-destructive ops. Future migrations on either the staged path or the fast path will auto-apply these renames.

Also surfaced the need for post-hoc staging on the fast path (this very file) — added to `skills/migrate-project/SKILL.md` Phase 5.

## Sibling context

Third of three FeedingFrequency-family migrations:

1. `juvenile/` — `2026 Juvenile gut evac` (migrated 2026-05-14, staged interview)
2. `feeding-frequency-2023/` — `2023 Feeding Frequency` (staged 2026-05-14, ready-for-transfer)
3. **`frequency-ras/`** — `2026 RAS feeding frequency` — this one (fast-path migration, post-hoc record)
