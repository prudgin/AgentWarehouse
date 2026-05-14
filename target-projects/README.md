# Target Projects

Per-target staging dirs for projects the warehouse is setting up (cold-starting via `/create-project`, or migrating via `/migrate-project`).

A subdir here is the **draft of the eventual project**, accumulated by `/intake-target-project` before any files land in the target repo. See [ADR-0015](../docs/adr/0015-target-projects-staging.md) for the rationale and [ADR-0014](../docs/adr/0014-warehouse-grill-vs-project-grill.md) for why this is a separate skill from the in-project `/grill`.

## Layout

```
target-projects/<name>/
├── _warehouse/                   # warehouse-side scratch — does NOT transfer
│   ├── intake-notes.md           # raw notes from /intake-target-project
│   ├── migration-plan.md         # concrete steps for /migrate-project or /create-project
│   ├── status.md                 # dates, skill versions, completion state
│   └── feedback.md               # post-handoff observations (optional)
├── README.md                     # one-liner: status, target path, completion date
├── CLAUDE.md                     # drafted for the eventual project
├── glossary.md                   # drafted for the eventual project
└── docs/
    ├── adr/NNNN-*.md
    ├── domain/*.md
    └── planning/future-work.md
```

## Transfer rule

`/migrate-project` and `/create-project` copy **everything outside `_warehouse/`** into the target repo. Files inside `_warehouse/` stay here as durable record. The underscore prefix is the marker — same convention used for any other meta dir.

## Lifecycle

1. **Open**: `/intake-target-project <name>` creates `target-projects/<name>/` with `_warehouse/status.md` marking the staging as open. Subsequent invocations resume.
2. **Active**: skill writes glossary terms, ADR drafts, domain docs into staging as decisions resolve. Raw notes accumulate in `_warehouse/intake-notes.md`.
3. **Ready**: skill summarises and marks `_warehouse/status.md` as ready-for-transfer. The user invokes `/migrate-project <name>` or `/create-project <name>`.
4. **Done**: transfer completes. `_warehouse/status.md` records the completion date and target path.
5. **Permanent**: the dir stays here. Future warehouse-agent sessions can read it for institutional memory ("how did we set up that project?"); post-handoff feedback can be appended.

## Index

All entries below are **migrated** — staging dir holds the durable record; the live project lives at `~/ResearchProjects/<Project Name>/` and is bidirectionally mirrored to `sharepoint_planning:PROJECTS/<Project Name>/`.

### MCA research projects (research template)

Bulk SharePoint migration completed 2026-05-14 — see `_warehouse/status.md` in each staging dir for the per-project audit trail.

| Slug | Final project name | SharePoint folder | Migrated |
|---|---|---|---|
| [bile-staining](bile-staining/) | 2025 Bile Staining | `sharepoint_planning:PROJECTS/2025 Bile Staining/` | 2026-05-14 |
| [chlorella-psb](chlorella-psb/) | 2025 Chlorella and PSB Stage 1 | `sharepoint_planning:PROJECTS/2025 Chlorella and PSB Stage 1/` | 2026-05-14 |
| [feeding-frequency-juvenile](feeding-frequency-juvenile/) | 2026 Feeding Frequency Juvenile | `sharepoint_planning:PROJECTS/2026 Feeding Frequency Juvenile/` | 2026-05-14 |
| [hydroacoustic](hydroacoustic/) | 2026 Hydroacoustic Biomass Estimation | `sharepoint_planning:PROJECTS/2026 Hydroacoustic Biomass Estimation/` | 2026-05-14 |
| [cages-round-vs-rectangular](cages-round-vs-rectangular/) | 2021 Cages Round vs Rectangular | `sharepoint_planning:PROJECTS/2021 Cages Round vs Rectangular/` | 2026-05-14 |
| [feed-trial-marine-2021](feed-trial-marine-2021/) | 2021 Feed Trial Marine vs Non Marine vs LAP | `sharepoint_planning:PROJECTS/2021 Feed Trial Marine vs Non Marine vs LAP/` | 2026-05-14 |
| [csiro-selective-breeding](csiro-selective-breeding/) | 2022 CSIRO Selective Breeding | `sharepoint_planning:PROJECTS/2022 CSIRO Selective Breeding/` | 2026-05-14 |
| [deakin-univ](deakin-univ/) | 2022 Deakin Univ | `sharepoint_planning:PROJECTS/2022 Deakin Univ/` | 2026-05-14 |
| [larval-weaning](larval-weaning/) | 2022 Larval Weaning | `sharepoint_planning:PROJECTS/2022 Larval Weaning/` | 2026-05-14 |
| [nanobubble-trial](nanobubble-trial/) | 2022 Nanobubble Trial | `sharepoint_planning:PROJECTS/2022 Nanobubble Trial/` | 2026-05-14 |
| [whitton-feed-trial-2022](whitton-feed-trial-2022/) | 2022 Whitton Feed Trial | `sharepoint_planning:PROJECTS/2022 Whitton Feed Trial/` | 2026-05-14 |
| [continuous-copper](continuous-copper/) | 2023 Continuous Copper | `sharepoint_planning:PROJECTS/2023 Continuous Copper/` | 2026-05-14 |
| [feeding-frequency-2023](feeding-frequency-2023/) | 2023 Feeding Frequency | `sharepoint_planning:PROJECTS/2023 Feeding Frequency/` | 2026-05-14 (earlier session) |
| [fish-carcass-composition](fish-carcass-composition/) | 2023 Fish Carcass Composition | `sharepoint_planning:PROJECTS/2023 Fish Carcass Composition/` | 2026-05-14 |
| [open-ponds-whitton](open-ponds-whitton/) | 2023 Open Ponds Whitton | `sharepoint_planning:PROJECTS/2023 Open Ponds Whitton/` | 2026-05-14 |
| [ras-feed-biomar-2023](ras-feed-biomar-2023/) | 2023 RAS Feed Biomar | `sharepoint_planning:PROJECTS/2023 RAS Feed Biomar/` | 2026-05-14 |
| [stocking-density](stocking-density/) | 2023 Stocking Density | `sharepoint_planning:PROJECTS/2023 Stocking Density/` | 2026-05-14 |
| [bioremediation](bioremediation/) | 2024 Bioremediation | `sharepoint_planning:PROJECTS/2024 Bioremediation/` | 2026-05-14 |
| [probiotics-trial](probiotics-trial/) | 2024 Probiotics Trial | `sharepoint_planning:PROJECTS/2024 Probiotics Trial/` | 2026-05-14 |
| [artemia-enrichment](artemia-enrichment/) | 2025 Artemia Enrichment | `sharepoint_planning:PROJECTS/2025 Artemia Enrichment/` | 2026-05-14 |
| [hatchery-feed-trial](hatchery-feed-trial/) | 2025 Hatchery Feed Trial | `sharepoint_planning:PROJECTS/2025 Hatchery Feed Trial/` | 2026-05-14 |
| [ras-feed-biomar-2025](ras-feed-biomar-2025/) | 2025 RAS Feed Biomar | `sharepoint_planning:PROJECTS/2025 RAS Feed Biomar/` | 2026-05-14 |
| [stanbridge-feed-trial](stanbridge-feed-trial/) | 2025 Stanbridge Feed Trial | `sharepoint_planning:PROJECTS/2025 Stanbridge Feed Trial/` | 2026-05-14 |
| [frequency-ras](frequency-ras/) | 2026 RAS feeding frequency | `sharepoint_planning:PROJECTS/2026 RAS feeding frequency/` | 2026-05-14 (earlier session) |
| [gutevac](gutevac/) | 2026 Gut Clearance | `sharepoint_planning:PROJECTS/2026 Gut Clearance/` | 2026-05-04 |
| [juvenile](juvenile/) | 2026 Juvenile gut evac | `sharepoint_planning:PROJECTS/2026 Juvenile gut evac/` | 2026-05-14 (earlier session) |

### Bulk-migration notes (2026-05-14)

22 SharePoint-only projects were brought local in a single AFK session. Mechanical pattern per project:

1. Case-normalise SharePoint folder name to Title Case (two-step rename via `TMPCASE` intermediate where case-only).
2. Reorganise SharePoint subfolders into the canonical buckets: `Articles/`, `Proposal/`, `Data/`, `Reports/`, `Expenses/`. Existing `Articles and background/` → `Articles/` and `Report/` → `Reports/`; ad-hoc dirs slotted by filename heuristic.
3. Scaffold `~/ResearchProjects/<Title Case Name>/` from `templates/research/`.
4. Pull SharePoint → local (clean shape lands in the right buckets).
5. Skim a top Proposal doc per project, write CLAUDE.md (WHAT/WHY/HOW) and glossary.md (4–8 domain terms).
6. Push local agent infrastructure (CLAUDE.md, glossary.md, docs/, .tickets/, analysis/) back to SharePoint.
7. `git init` + initial commit per project (local-only, no remote).
8. Stage in `target-projects/<slug>/` with `_warehouse/status.md`.

The reorg policy treats the warehouse template as ground truth — moving content into the canonical buckets is part of the migration, not optional. See [ADR-0024](../docs/adr/0024-research-template-bidirectional-sharepoint-mirror.md).
