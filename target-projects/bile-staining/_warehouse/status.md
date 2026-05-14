# Status

- **Target**: bile-staining (staging name)
- **Final project name**: `2025 Bile Staining` (Title Case — SharePoint renamed to match)
- **Mode**: cold-start migration from SharePoint
- **Source repo**: none (no prior local repo — content lived only on SharePoint)
- **Target local path**: `~/ResearchProjects/2025 Bile Staining/`
- **SharePoint mirror**: `sharepoint_planning:PROJECTS/2025 Bile Staining/`
- **Template**: research (per ADR-0024)
- **Started**: 2026-05-14
- **Completed**: 2026-05-14
- **Status**: migrated
- **Skill version**: bulk-AFK driver (this session — see CLAUDE.md commit `013a0b1`)
- **Fast-path note**: ran as part of the 2026-05-14 bulk migration covering 22 SharePoint-only research projects. Skim-and-seed CLAUDE.md/glossary.md from `Proposal/Bile staining proposal 29-10-2025.docx`.

## Outcome

- ✅ SharePoint folder case-renamed: `2025 Bile staining` → `2025 Bile Staining` (two-step via `TMPCASE` intermediate)
- ✅ SharePoint subfolder renames: `Articles and background/` → `Articles/`, `Report/` → `Reports/`
- ✅ Local scaffold from research template at `~/ResearchProjects/2025 Bile Staining/`
- ✅ First pull: SharePoint → local (all content into canonical buckets, no remapping needed since SP shape was already template-aligned after subfolder renames)
- ✅ CLAUDE.md drafted (skim-and-seed from the proposal)
- ✅ glossary.md drafted (8 trial-design + outcome terms)
- ✅ First push: local → SharePoint (CLAUDE.md, glossary.md, docs/, .tickets/, analysis/, README.md)
- ✅ Git initialised (`main`, local-only) and initial commit created — 365 files

## Auto-applied canonical renames

- SP: `Articles and background/` → `Articles/`
- SP: `Report/` → `Reports/`

(Per [[feedback-canonical-pullback]] and [[feedback-reorg-is-the-point]] memories.)
