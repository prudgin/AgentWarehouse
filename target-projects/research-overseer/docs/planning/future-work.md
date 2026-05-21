# Future work — research-overseer

Pre-decision backlog. When an item moves past "we will probably do this" to "we are doing this now," it migrates to `.tickets/` and the entry here is deleted (per warehouse boundary rule).

## Bootstrap migration (first reconcile)

- [ ] Add `Slug` column to the register; generate slugs for the existing 27 rows.
- [ ] Resolve cardinality conflicts at first sweep:
  - `gutevac` vs `stanbridge-gutevac` — currently one register row "Gut evacuation" (R26). Split into two rows or consolidate into one repo. Asks the human.
  - `feeding-frequency-2023` vs `feeding-frequency-juvenile` — currently one register row "Feeding frequency" (R11). Split or consolidate.
- [ ] For each existing per-project repo under `~/ResearchProjects/`, create an initial `.register/entry.yaml` populated from the existing register row (reverse direction, one-off).

## Strategy / roadmap (β responsibility)

- [ ] Decide structure of `docs/strategy/` — single rolling doc (`themes.md`) or per-theme dir (`docs/strategy/<theme>/`)?
- [ ] Define what "research themes" look like as data — tags? An OptionsLists column? Free text?
- [ ] First strategy pass: read all 27 register entries, propose initial themes/gaps writeup.

## SharePoint maintenance (ε responsibility)

- [ ] Discovery sweep: enumerate empty folders under `sharepoint_planning:PROJECTS/` and other top-level dirs. Output to `.tickets/sharepoint-cleanup-<date>.md`.
- [ ] Restructure pass: identify "old stuff" that should be archived or reorganized. Heuristics TBD (last-modified > N years? not referenced by any register row?).
- [ ] Audit-trail format for `analysis/YYYY-MM-DD-sharepoint-restructure/audit.md`.

## Schedule

- [ ] Weekly `/reconcile-register` schedule (Q10c). Day/time TBD. Probably Monday morning so the manager sees results at start of week.

## Cross-project meta-investigations (α)

- [ ] First meta-investigation candidate (when overseer is running): cross-cutting feed trial findings across "Feed" domain rows. Or: water quality trends across farms.

## Per-project skill propagation

- [ ] `/update-register-entry` symlinked into every existing per-project research repo (currently: `2026 Gut Clearance`, others as they migrate).
- [ ] Warehouse-side: modify `/finish` skill in research-template branch to auto-call `/update-register-entry`.
- [ ] Warehouse-side: add `.register/` carve-out to `templates/research/.rclone-filter`.
