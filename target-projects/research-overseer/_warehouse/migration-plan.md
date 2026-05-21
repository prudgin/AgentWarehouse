# Migration plan — research-overseer

Cold-start. Executable plan for `/create-project research-overseer`. The plan also includes warehouse-side changes (new skill, modifications to the research template and the `/finish` skill) because the overseer's design depends on them.

## Phase 0 — Pre-flight

- Confirm target host: `rndmanager@rndcomputer` (the user is currently on `rndcomputer`).
- Confirm `~/ResearchProjects/` exists. Create if missing.
- Confirm rclone remotes `sharepoint:` and `sharepoint_planning:` are configured and authenticated.

## Phase 1 — Scaffold the research-overseer repo

**Target directory**: `~/ResearchProjects/research-overseer/`.

**Base template**: hybrid — copy from `templates/tool-integration/` as the base, then layer additions.

1. `mkdir -p ~/ResearchProjects/research-overseer/` and `cd` there.
2. Copy from `templates/tool-integration/`:
   - `CLAUDE.md` → discard; use the one in `target-projects/research-overseer/CLAUDE.md` instead.
   - `glossary.md` → discard; use the staged one.
   - `README.md` → start fresh.
   - `_tools/` → keep skeleton; add overseer-specific scripts in Phase 3.
   - `docs/` skeleton.
3. Layer additions (not in tool-integration template):
   - `analysis/` with empty `analysis-landscape.md` (borrowed from research/analysis template).
   - `docs/strategy/` (new).
   - `.rclone-filter` (borrowed and adapted from research template).
4. Transfer staged content from `target-projects/research-overseer/`:
   - `CLAUDE.md` → `~/ResearchProjects/research-overseer/CLAUDE.md`
   - `glossary.md` → `~/ResearchProjects/research-overseer/glossary.md`
   - `docs/adr/*.md` (6 ADRs + README) → `~/ResearchProjects/research-overseer/docs/adr/`
   - `docs/domain/*.md` (register-shape + README) → `~/ResearchProjects/research-overseer/docs/domain/`
   - `docs/planning/*.md` → `~/ResearchProjects/research-overseer/docs/planning/`
5. `git init`. Initial commit `chore: scaffold from warehouse research-overseer staging`.
6. `AGENTS.md` → symlink to `CLAUDE.md`.
7. `.tickets/` empty + `.tickets/README.md` (warehouse standard).
8. `.gitignore` (standard + `.venv/`, `.secrets/`, `_tools/scratch/`).
9. `.rclone-filter` — adapt from research template; exclude `src/`, `_tools/`, `.git/`, `.venv/`, `.claude/`, build artefacts.

## Phase 2 — Install skills (symlinks)

In `~/ResearchProjects/research-overseer/.claude/skills/`:

- Symlink existing warehouse skills:
  - `sharepoint-sync`, `start-analysis`, `finish-analysis`, `file-cross-repo-ticket`, `check-inbox`, `finish`, `diagnose`, `zoom-out`, `improve-codebase-architecture`, `schedule`.
- Overseer-specific skills are created in Phase 4 (warehouse side first), then symlinked.

## Phase 3 — Warehouse-side: new and modified skills

This is where the dependencies on the warehouse live. **These changes ship before the overseer can do its job.**

### 3a. New skill `~/AgenticEngineering/skills/update-register-entry/`

Per-project skill. SKILL.md describes:
- Read existing `.register/entry.yaml` if present; else start blank.
- For each field, check `_meta.intentionally_blank`. If listed, skip. Else if null, prompt human. Else use stored value.
- Update `_meta.last_populated` and `_meta.populated_by` (`agent` if invoked auto from `/finish`, `human` if interactive).
- Write YAML.
- Idempotent.

Symlink into every research-template project's `.claude/skills/update-register-entry/`. Also symlink into the template itself (`templates/research/.claude/skills/`) so future projects scaffolded from it inherit the skill.

### 3b. Modify `~/AgenticEngineering/skills/finish/SKILL.md`

Add a research-template-detection branch that runs `/update-register-entry` before `/sharepoint-sync push`. If `/update-register-entry` errors, halt `/finish` with a clear message.

### 3c. Modify `~/AgenticEngineering/templates/research/CLAUDE.md`

Document the new auto-call. Update the Skills section.

### 3d. Modify `~/AgenticEngineering/templates/research/.rclone-filter`

Add carve-out so `.register/` syncs to SharePoint. The carve-out must be explicit: by default the filter excludes `_*`, `.<dotdir>/`, and similar; `.register/` needs an explicit `+` rule.

### 3e. New overseer-specific skills in `~/AgenticEngineering/skills/`

- `reconcile-register/` — single-batch sweep + apply.
- `detect-drift/` — read-only drift report.
- `sweep-sharepoint-cleanup/` — produce destructive-ops plan as a `.tickets/` markdown.
- `apply-sharepoint-cleanup/` — apply an approved cleanup ticket with audit logging.

Each skill is symlinked into `~/ResearchProjects/research-overseer/.claude/skills/` from the canonical warehouse path.

### 3f. Warehouse documentation updates

- Add new skills to `docs/reference/skills.md` and `skills/README.md`.
- Add the research-overseer to `docs/domain/existing-projects.md`.
- Add an entry to the warehouse-level future-work for anything still TBD (weekly schedule day/time, strategy doc shape).

## Phase 4 — Bootstrap the register

**This is the destructive Phase. Run only after Phases 1–3 are committed and reviewed.**

### 4a. Add Slug column to register (medium tier per ADR-0004)

- Download `sharepoint_planning:PROJECTS/RnD projects register.xlsx` to a working copy.
- Add a `Slug` column (recommended position: between `Title` and `Status` for visibility, or at end if minimising visual change is preferred).
- Generate slugs for the 27 existing rows from current Titles. Algorithm: lowercase, replace non-alphanumeric with `-`, collapse multiples, strip leading/trailing. Append year-suffix on collision.
- Confirm with human (single batch confirm per ADR-0004 medium tier).
- Upload.

### 4b. Seed entry.yaml for existing per-project repos

For each existing per-project repo under `~/ResearchProjects/`:
- Identify the matching register row (by Title, with human confirmation on ambiguous matches — recall the cardinality conflicts in [ADR-0003](../docs/adr/0003-one-to-one-to-one-mapping.md)).
- Run `/update-register-entry` interactively, pulling initial values from the register row, then prompting for missing fields.
- Commit `.register/entry.yaml` in the per-project repo.

### 4c. Resolve cardinality conflicts (per ADR-0003)

For each of:
- `gutevac` vs `stanbridge-gutevac` → register row "Gut evacuation" (R26).
- `feeding-frequency-2023` vs `feeding-frequency-juvenile` → register row "Feeding frequency" (R11).

Ask human: merge or split? Apply accordingly:
- Merge: pick one repo as canonical, archive/delete the other, single entry.yaml.
- Split: keep both repos, create a second register row with a new slug, write a second entry.yaml.

## Phase 5 — First operational sweep

- Run `/reconcile-register` end-to-end. Verify the XLSX reflects all entry.yaml values.
- Run `/detect-drift` separately. Verify report matches expectations.
- Run `/sweep-sharepoint-cleanup` for a discovery-only pass; review the proposed ticket; do NOT apply on first run.

## Phase 6 — Schedule

- Set up a weekly `/reconcile-register` schedule via `/schedule`. Default proposal: **Mondays 08:00 local** (so the manager sees results at start of week). Confirm with user.

## Phase 7 — Wrap

- `/finish` in the overseer repo.
- Confirm `_warehouse/status.md` flips to `ready-for-transfer` → `transferred`.
- Note in `target-projects/research-overseer/_warehouse/status.md` that scaffold is complete.

## Open ends (resolve before Phase 4)

- **Weekly schedule day/time**: default Monday 08:00; needs confirmation.
- **Strategy doc shape (β)**: single rolling doc vs per-theme dir. Decide before first strategy pass.
- **Slug-generation collision policy**: append year on collision is the proposal; sanity-check during 4a.
- **Cardinality conflicts**: split-or-merge decisions per ADR-0003 are pending human input in Phase 4c.
