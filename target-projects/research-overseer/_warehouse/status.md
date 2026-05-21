---
status: created
started: 2026-05-21
intake-completed: 2026-05-22
created: 2026-05-22
mode: cold-start
target-host: rndmanager@rndcomputer
target-path: ~/ResearchProjects/research-overseer/
scaffold-commit: 81bdcd0
phases-completed:
  - Phase 1 (scaffold)
  - Phase 2 (install existing warehouse skills as symlinks)
phases-deferred:
  - Phase 3 (warehouse-side new skills + /finish hook + research template tweaks)
  - Phase 4 (register bootstrap — Slug column, seed entry.yaml for existing repos, cardinality conflicts)
  - Phase 5 (first operational sweep)
  - Phase 6 (weekly schedule)
open-ends:
  - SharePoint folder `sharepoint_planning:Research overseer/` not yet created (high-tier destructive — needs explicit OK)
  - Weekly schedule day/time
  - Strategy doc shape (single rolling vs per-theme dir)
  - Cardinality conflicts: gutevac vs stanbridge-gutevac, feeding-frequency split-or-merge
---

# Status

Cold-start intake for an **overarching research agent** that maintains the master research projects register and tracks overall research across all individual research projects.

Lives on `rndcomputer` under `~/ResearchProjects/`. Sibling at the same dir level as per-project research repos (`2026 Gut Clearance/`, `2025 Frequency RAS/`, etc. — those are intaken separately in `target-projects/`).
