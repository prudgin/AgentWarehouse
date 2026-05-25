# Status

- **Target**: gutevac
- **Mode**: migration
- **Original source repo**: `/home/rndmanager/PycharmProjects/GutEvac` (now defunct; moved out)
- **Current target local path**: `/home/rndmanager/ResearchProjects/2026 Gut Clearance/`
- **SharePoint mirror**: `sharepoint_planning:PROJECTS/2026 Gut Clearance`
- **Template**: started as `analysis`; subsequently bumped to `research` (Title Case `Data/`/`Articles/`/`Proposal/`/`Reports/`, `.rclone-filter`, `.register/`, `sharepoint-sync` + `update-register-entry` skills)
- **Started**: 2026-05-04
- **Intake completed**: 2026-05-04
- **Migration completed**: 2026-05-04 (initial); research-template bring-up landed in working tree 2026-05-14 – 2026-05-22 (uncommitted at time of audit)
- **Canonical-pullback pass**: 2026-05-25
- **Status**: migrated
- **Skill version**: migrate-project (current; see `skills/migrate-project/SKILL.md`)

## Auto-applied canonical renames / cleanups (2026-05-25)

- Dropped `docs/proposal/` — `.docx` was byte-identical to `Proposal/Stage 1 draft proposal 16-12-2025.docx`; `README.md` content (proposal-vs-reality framing) was moved into `Proposal/README.md` with the ADR-0001 link path updated to `../docs/adr/0001-divergence-from-stage-1-proposal.md`.
- Added `Articles/README.md` (research-template canonical index, was missing).
- `CLAUDE.md`: project name `gutevac` → `2026 Gut Clearance`; switched all path references from lowercase `data/`/`reports/`/`docs/proposal/` to Title Case `Data/`/`Reports/`/`Proposal/`; indexed `Articles/` (was missing from the documentation map).
- `glossary.md` line 21: provenance path `docs/proposal/stage-1-2025-12-16.docx` → `Proposal/Stage 1 draft proposal 16-12-2025.docx`.
- `Data/README.md`: layout heading and example paths updated from lowercase `data/` to Title Case `Data/`.

## Surfaced (not auto-applied) — pending user decision

- `Reports/16_04_2025 interim report.pptx` (2 733 232 bytes) sits alongside `Reports/2026-04-16-interim.pptx` (2 727 577 bytes). Same content, different bytes — almost certainly a SharePoint rewrite-on-upload normalisation. The migration plan instructed renaming to ISO; `Reports/README.md` only indexes the ISO version. Per the migrate-project skill's "duplications" rule, local-vs-SharePoint same-content duplicates are reported, not auto-deduplicated.

## Note on git state

At the canonical-pullback pass, the project working tree was a large uncommitted research-template bring-up (21 `D` entries for the old lowercase `data/`/`reports/` paths, 8 `??` entries for the new Title Case dirs + research scaffolding). The cleanup above adds further unstaged changes on top. Committing is deferred to the user.
