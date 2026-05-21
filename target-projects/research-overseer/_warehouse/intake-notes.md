# Intake notes — research-overseer

## Anchor (2026-05-21)

User: "I want to set up a new project that will sit in rndmanager@rndcomputer:~/ResearchProjects and will be an overarching research agent across all projects. It will have access to the whole rnd sharepoint and will keep track of the research projects register (available at root in remote sharepoint of projects folder) and will update it and keep track of overall research."

Confirmed: cold-start.

## Open questions

- Q3 — template variant: not `research` (that's for individual MCA projects). Candidates: `tool-integration` (wraps SharePoint + maintains the register file) or custom mix.

## Resolved

- **Mode**: cold-start.
- **Q2 — location**: `~/ResearchProjects/research-overseer/` on rndcomputer. Subdir alongside per-project research repos. Avoids git-in-git nesting; overseer reads `..` to discover sibling projects.
- **SharePoint scope**: agent needs access to the **whole R&D SharePoint**, not only the `PROJECTS/` subfolder. The research projects register happens to live at the root of `PROJECTS/` but is just one of many things the overseer touches.
- **Q3 — register file**: `sharepoint_planning:PROJECTS/RnD projects register.xlsx`. XLSX with two sheets: `Projects` (row-per-project, 32 used columns) and `OptionsLists` (controlled vocabularies). 27 populated rows as of 2026-05-21. See `docs/domain/register-shape.md`.
- **Q3 — update model**: per-project agent writes register-relevant data to a dedicated location; overseer sweeps those locations and reconciles against the master register. Bidirectional: human still owns the register; agent updates are diffs proposed to human, then applied.
- **Q4(A) — per-project artifact location**: `.register/entry.yaml` at each per-project repo root. Own dedicated dir; signals "infrastructure not deliverable." Research template's `.rclone-filter` needs a carve-out so `.register/` syncs to SharePoint.
- **Q4(B) — format**: YAML.
- **Q4(C) — column ownership**:
  - **Agent populates**: Title, Status, Actual start, Actual finish, Outcome document link, Outcome summary, Summary, Keywords, Next review date, Added on.
  - **Manager-only**: Approver, Decision, Decision date, Decision notes, Estimated cost, Budget, Actual cost, Estimated benefit, Priority, Confidential, Originator.
  - **Static-ish (TBD in Q5)**: Domain, Type, Operational area, Farms, Organisations involved, Estimated effort person hours, Estimated days span, Planned start, Planned finish, Supporting document link, Files (Sharepoint folder link).
- **Per-project skill design (key invariant)**: ONE skill (TBD name) callable on demand and from `/finish` (the work-loop finish skill). For each field: if populated → use; if null and not marked intentionally-blank → ask human, then save; if marked intentionally-blank → skip silently. The "intentionally blank" marker must be persistent so re-runs don't re-ask.
- **Q5(a) — static-ish field ownership**: agent populates Domain, Type, Operational area, Farms, Organisations involved, planned dates, supporting/files links. Set at intake from `target-projects/<name>/` staging; manager can override.
- **Q5(b) — intentional-blank shape**: sidecar list. `_meta.intentionally_blank: [field1, field2]` + `_meta.last_populated:` + `_meta.populated_by:` (agent | human).
- **Q5(c) — per-project skill**: name `update-register-entry`. Canonical in `~/AgenticEngineering/skills/update-register-entry/`, symlinked into each research-template project's `.claude/skills/`. Auto-invoked from `/finish` in research-template projects (requires warehouse-side change to `finish` skill or research-template CLAUDE.md hook).
- **Q6 — overseer scope (all in)**:
  - **(α) Cross-project meta-investigations** — `analysis/YYYY-MM-DD-<topic>/INVESTIGATION.md` first-class. Draws on data/reports across sibling repos and SharePoint.
  - **(β) Research-strategy / roadmap** — persistent docs tracking themes, gaps, priorities. Lives under `docs/strategy/` (tentative).
  - **(γ) Orphan / drift detection** — sweep finds register-row-without-folder, folder-without-row, local-repo-without-entry, stale Next review date. Surfaces as a queue.
  - **(δ) Cross-project ticket routing** — when overseer notices something a per-project agent should do, file ticket into that repo's `.tickets/inbox/` via existing `/file-cross-repo-ticket` skill.
  - **(ε) Whole-SharePoint awareness** — access to all of `sharepoint_planning:` and other rclone remotes if they exist. Specific other surfaces TBD.
    - Includes **maintenance tasks**: delete empty folders, restructure old stuff. **Destructive on shared state** — must be gated behind explicit human confirmation. Strong ADR candidate (3-of-3: hard to reverse, surprising scope for an agent, real trade-off between autonomy and safety).
    - Two configured rclone remotes (`rclone listremotes`): `sharepoint:` (operational — BILBUL, WHITTON, STANBRIDGE, MCFARLANES, HEALTH, HARVEST, SOPs, Juvenile sites, ...) and `sharepoint_planning:` (R&D — PROJECTS, PROPOSALS, Papers and literature, Fish health, Finance, Automation, Other).
    - **Primary R&D surface**: `sharepoint_planning:` — this is where the register, proposals, papers, finance, automation live. The overseer's "whole rnd sharepoint" scope is primarily this remote.
    - **Operational `sharepoint:`** likely read-only context for the overseer (e.g. cross-referencing farm SOPs, harvest data, fish health for meta-investigations). Worth confirming.
- **Q7 — remote write scope**: write access to `sharepoint_planning:` only. `sharepoint:` is read-only context. Confirmed. ADR candidate.
- **Q8 — template shape**: hybrid based on `tool-integration` template (skills + `_tools/`) with `analysis/` added first-class (borrowed from `research`/`analysis` templates) and a new `docs/strategy/` dir. Directory layout confirmed (see CLAUDE.md draft).
- **Q8(a) — overseer self-sync**: bidirectional sync of the overseer repo itself to `sharepoint_planning:Research overseer/`. Mirror analysis/, docs/strategy/, etc., so outputs are readable from SharePoint UI. Reuse `/sharepoint-sync` skill pattern from research template (with the overseer's own `.rclone-filter`).
- **Q9 — trust & workflow**:
  - **Trust direction**: `.register/entry.yaml` files are **canonical for ALL fields** (agent-populated + manager-only). The master XLSX is a downstream rendered view. **Critical implication: manual edits made directly to the XLSX do not survive the next sweep — they are overwritten by entry.yaml.** Strong ADR candidate.
  - **How manager-only fields get set**: human edits the per-project repo's `.register/entry.yaml` directly, or answers the per-project `/update-register-entry` skill's prompts. SharePoint UI editing of the XLSX is **not** a supported edit path.
  - **Write workflow**: `/reconcile-register` is a single-batch skill — full sweep across all per-project entry.yaml files, applies all clean diffs to the in-memory XLSX, queues conflicts (entry.yaml missing for an existing row, row missing for an entry.yaml, value conflict, options-list violation), uploads xlsx once at the end.
  - **Implied four orphan/drift classes** (handled by `/detect-drift` skill or as side effects of `/reconcile-register`):
    - Register row exists, no entry.yaml → likely a project not yet cloned locally; flag, don't delete.
    - entry.yaml exists, no register row → new project; add row.
    - Both exist, values differ → entry.yaml wins.
    - Cell value not in OptionsLists → conflict; either extend OptionsLists or ask human.
- **Q10(a) — git remote**: none. Local-only on `rndcomputer`. SharePoint mirror at `sharepoint_planning:Research overseer/` is the offsite copy of the working state.
- **Q10(b) — ticket backend**: local `.tickets/` only (markdown). `.tickets/inbox/` for cross-repo tickets via `/file-cross-repo-ticket`.
- **Q10(c) — sweep cadence**: manual via `/reconcile-register`, plus a weekly scheduled run (via `/schedule`). Schedule produces summary, applies clean diffs, leaves conflicts for human to resolve next interactive session.
- **Q11 — project identity**: add a `Slug` column to the register. Stable kebab-case identifier assigned at row creation, stored in both `register.Slug` and `entry.yaml.id`. One-time migration step: generate slugs for the 27 existing rows. Schema-change to OptionsLists not required.
- **Q11(b) — mapping cardinality**: **1:1:1.** One register row = one per-project repo = one entry.yaml. If two per-project repos point at the same slug (or vice versa), overseer flags the clash and asks the human to either merge into one project or split into two register rows. Implications for existing intakes:
  - `gutevac` and `stanbridge-gutevac` → currently one register row "Gut evacuation" (R26); needs split into two rows OR consolidation into one repo. First-sweep decision.
  - `feeding-frequency-2023` and `feeding-frequency-juvenile` → one register row "Feeding frequency" (R11); same: split or merge.
- **Q12 — destructive-ops auth gate (tiered)**:
  - Low risk (mechanical writes from canonical source): `/reconcile-register` cell writes auto-apply with summary at end.
  - Medium risk (schema/structure changes): add Slug column, extend OptionsLists values, add new register row — single batch confirm per `/reconcile-register` session.
  - High risk (irreversible on shared state): SharePoint folder deletes and renames/moves — overseer writes the proposed plan to a `.tickets/` markdown first (e.g. `.tickets/sharepoint-cleanup-<date>.md`), human explicitly OKs the ticket, then it applies. Every applied destructive op is logged to a dated `analysis/` audit trail.
