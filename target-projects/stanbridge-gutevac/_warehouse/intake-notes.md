# Intake notes — Stanbridge gut evac

Raw notes from the intake conversation. The user's exact phrasing for fuzzy or unresolved branches is preserved.

## Anchor

User: "I need to set up a new project. research. same as 2026 Juvenile gut evac but for Stanbridge. how do we begin?"

→ Read as: cold-start of a research project mirroring `target-projects/juvenile/` (the Bilbul GER trial), but conducted at the Stanbridge site. Template = `research` (bidirectional SharePoint mirror).

## Sibling reference

The Bilbul `2026 Juvenile gut evac` staging (`target-projects/juvenile/`) is the structural template:

- Template: `research`.
- SharePoint folder: `sharepoint_planning:PROJECTS/2026 Juvenile gut evac/`.
- Glossary: 16 entries (GER, cohort, t=0, sentinel fish, operational empty threshold, residual fraction y_rel, non-feeder fraction π, K_local, mush, pellet-count cross-check, binary clearance curve, Bilbul scope, OM5, SFR band, sinking-vs-floating feed, degree-hours).
- ADRs: 3 (t=0 anchor via pre-fast + sentinel; normalisation by t=0 batch mean; three-family AIC kinetic comparison).
- Domain docs: `data-shape.md`.
- Reference docs: `cage-selection.md`.
- Project-local skill: `/select-trial-cages`.

## Stanbridge context (from sibling staging `target-projects/stanbridge-feed-trial/`)

- Stanbridge is a freshwater **static-pond** site (not cages — different scope vocabulary from Bilbul).
- Existing project: `2025 Stanbridge Feed Trial` (Bubner / D'Antignana) — feed-ration refinement.
- Implication: Stanbridge GER will need its own "scope" entry analogous to Bilbul scope, but expressed in ponds rather than 96 cages. Cage-selection procedure won't transfer 1:1.

## Open questions to walk in this session

1. **Project Title Case name** — RESOLVED: `2026 Stanbridge gut evac`. Drives SharePoint folder + `~/ResearchProjects/<name>/`. (User picked the recommendation; matches the Bilbul sibling casing.)
2. **Cohort definition** — RESOLVED (partial): Stanbridge-specific brackets across the fish currently present at Stanbridge, roughly **200 g to 1.5 kg**. Number of cohorts and exact bracket boundaries decided later (probably at pond/scope-selection time). Headline metric and downstream purpose are the same as Bilbul: GER curve → time to 20 % residual → input to **feeding-frequency design** (NOT pre-harvest fasting; that question belongs to the `2026 Gut Clearance` sibling project). This trial covers a **higher-weight band** than Bilbul (200 g–1.5 kg vs Bilbul's 10–150 g) — it's complementary, not a site-replicate.

   Implication: this is not a "juvenile" trial in the Bilbul sense — the fish are grow-out / sub-harvest. The project name `2026 Stanbridge gut evac` is fine because it doesn't claim juvenile, but the glossary entry for "cohort" must replace Bilbul's A/B/C juvenile table with a Stanbridge weight-range placeholder.
3. **Trial-site selection** — RESOLVED: **each pond is the cohort unit** (one cohort per pond). Stanbridge appears in the same Mercatus published parquets (`cycle_ledger/units.parquet`) as Bilbul, so the selection plumbing transfers — just a different `AreaCode` filter. The Bilbul `docs/reference/cage-selection.md` becomes Stanbridge `docs/reference/pond-selection.md`; the project-local skill `/select-trial-cages` becomes `/select-trial-ponds` (or kept as `/select-trial-cages` if static ponds are still called "cages" in Mercatus — to confirm).
4. **Environment data** — RESOLVED: temperature + oxygen pulled from Mercatus, same source as Bilbul. OM5 (dissolved oxygen mg/L) reusable. Aggregation level (cluster = pond at Bilbul) may differ at Stanbridge; to verify against the cycle ledger.
5. **Proposal** — RESOLVED: **none yet, plan to author one before the trial**. Seed `Proposal/Stanbridge_GER_trial_proposal.md` as a stub during `/create-project`, lifting the Bilbul proposal structure. Stanbridge-specific sections (cohorts, pond scope, feed types) marked TODO. Drafting the actual proposal is the user's job, not the scaffolder's.
6. **What carries over verbatim** from the Bilbul project — CONFIRMED:
   - Methodology ADRs 0001 (t=0 anchor), 0002 (normalisation), 0003 (three-family AIC) — carry over with Context-section renames only ("Bilbul GER trial" → "Stanbridge GER trial").
   - Methodology glossary terms: GER, t=0, sentinel fish, operational empty threshold, residual fraction y_rel, non-feeder fraction π, K_local, mush, pellet-count cross-check, binary clearance curve, degree-hours.
   - These are site-agnostic protocol-level decisions.
7. **Stanbridge scope** — RESOLVED. From `/mnt/data/mercatus/cycle_ledger/units.parquet`:
   - AreaCode = `STA`, AreaName = `Stanbridge`
   - RegionCode = `OR` (Ongrowing region), OperationCode = `OG` (Ongrowing)
   - StructureType = `pond_in_cell` (all 78 units)
   - 6 cells: SC1 (15 ponds, UnitIds 1636–1651), SC2 (13, 1652–1664), SC3 (9, 1665–1673), SC4 (13, 1869–1881), SC5 (14, 1882–1895), SC6 (14, 1853–1866). Total 78. UnitIds non-contiguous (two blocks).
   - Friendly name pattern: `Stanbridge Cell N Pond NN`.
   - All 78 ponds in scope; no operational exclusions called out.
   - Filter: `AreaCode == 'STA'` (analogous to Bilbul's `AreaCode == 'BIL'`).

8. **What needs Stanbridge-specific replacement** in the glossary vs Bilbul:
   - `Bilbul scope` → `Stanbridge scope` (different filter, different unit count, different structure).
   - `Cohort` — keep canonical term, but the table of weight brackets / pellet sizes is Stanbridge-specific and TBD (placeholder pending proposal).
   - `SFR band` — single threshold (all floating); no juvenile sinking-feed asymmetry.
   - `Sinking vs floating feed` — dropped; not relevant (confirmed by user).
   - `OM5` → renamed to `Pond oxygen`. **Per-pond oxygen lives in `vReportingBaselineInventoryByDay.csv` (`Oxygen` column).** The OM5 cluster-level feed in `vReportingBaselineEnvironment.csv` aggregates to cell granularity and is *not* the right source. (Original audit missed `InventoryByDay`; corrected when user flagged.)
   - Docs: `cage-selection.md` → `pond-selection.md`. Selection inputs are all pond-grain; procedure shape is a direct port of Bilbul's.
   - Project-local skill: `/select-trial-cages` → `/select-trial-ponds`.

9. **Corrections / closures after first walk** (2026-05-18, user pass):
   - Oxygen is **per pond**, not per cell. Source: `InventoryByDay.Oxygen`, audited 2026-05-18 — 78/78 ponds, ~770 days each, span 2024-03-27 → 2026-05-17.
   - Pre-fast feasibility (formerly FW-PR-05) confirmed with operations; dropped.
   - `src/` package decision (formerly FW-AN-03): **copy, no share.** Stanbridge gets its own derived package.
   - FW-DT-01 (recording template): schema is documented; producing the physical Excel is a post-scaffold trivial copy-and-rename.
   - All affected docs updated: glossary "Pond oxygen", data-shape §2.3, ADR-0001 Consequences, future-work.md.
