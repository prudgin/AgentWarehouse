# Migration plan — 2026 Stanbridge gut evac

This is a **cold-start**, not a migration. `/create-project stanbridge-gutevac` consumes this plan.

## Resolved decisions

- **Project name (Title Case)**: `2026 Stanbridge gut evac`. Used for both the SharePoint folder and the local directory under `~/ResearchProjects/`.
- **Template**: `research` (bidirectional SharePoint mirror).
- **Mode**: cold-start.
- **Sibling reference**: `target-projects/juvenile/` (2026 Juvenile gut evac at Bilbul) — structural and methodological source.

## Execution steps for `/create-project`

### 1. Local scaffold

- Target directory: `~/ResearchProjects/2026 Stanbridge gut evac/`.
- Confirm it does not yet exist; refuse to overwrite if it does.
- Copy `templates/research/` into the target directory.
- `git init` in the target; no remote (sibling convention).

### 2. Transfer staged content

From `target-projects/stanbridge-gutevac/` into the target repo:

| Staging path | Target path |
|---|---|
| `CLAUDE.md` | `CLAUDE.md` (overwrites template default) |
| `glossary.md` | `glossary.md` (overwrites template default) |
| `README.md` | leave staging placeholder behind; use template's `README.md` |
| `docs/adr/0001-t0-anchor-via-prefast-and-sentinel.md` | `docs/adr/0001-t0-anchor-via-prefast-and-sentinel.md` |
| `docs/adr/0002-normalisation-by-t0-batch-mean.md` | `docs/adr/0002-normalisation-by-t0-batch-mean.md` |
| `docs/adr/0003-three-family-aic-kinetic-comparison.md` | `docs/adr/0003-three-family-aic-kinetic-comparison.md` |
| `docs/adr/README.md` | `docs/adr/README.md` |
| `docs/domain/data-shape.md` | `docs/domain/data-shape.md` |
| `docs/domain/README.md` | `docs/domain/README.md` |
| `docs/planning/future-work.md` | `docs/planning/future-work.md` |
| `docs/planning/README.md` | `docs/planning/README.md` |
| `_warehouse/*` | **do not transfer** — staging-internal only |

### 3. Symlink warehouse skills

Install the research-template skill set as symlinks from `~/AgenticEngineering/skills/<name>/`:

- Build chain: `grill`, `to-prd`, `to-issues`, `triage`, `work-issue`, `finish`.
- Analyse chain: `start-analysis`, `finish-analysis`.
- Cross-cutting: `diagnose`, `file-cross-repo-ticket`, `check-inbox`.
- Research-specific: `sharepoint-sync`.

Do **not** symlink the warehouse-only lifecycle skills (`intake-target-project`, `create-project`, `migrate-project`).

### 4. SharePoint folder

- Verify: `rclone lsd "sharepoint_planning:PROJECTS/2026 Stanbridge gut evac"` — currently **does not exist**.
- Create the folder on SharePoint with the canonical subfolders: `Articles/`, `Proposal/`, `Data/`, `Reports/`, `Expenses/` (and `Reports/bi reports/` only if the project later needs it; do not pre-create).
- Initial push: run `/sharepoint-sync push` from the new local repo to seed the SharePoint folder with the scaffolded agent infrastructure (`CLAUDE.md`, `glossary.md`, `docs/`, etc.).

### 5. `.rclone-filter`

Use the research-template default. No project-specific overrides identified during intake — every dataset under `Data/` is small Excel and there's nothing huge to exclude. Revisit if `Data/` grows.

### 6. Seed `Proposal/Stanbridge_GER_trial_proposal.md`

Lift the structural skeleton from the Bilbul proposal (`~/ResearchProjects/2026 Juvenile gut evac/Proposal/Bilbul_GER_trial_proposal.md`) with site-specific sections (Cohorts, Scope, Feed sizes) marked TODO. The actual authoring is the user's job — tracked as [FW-PR-01](../docs/planning/future-work.md).

If the Bilbul proposal is not accessible at create-project time, seed the file with a stub heading list and the user fills it manually.

### 7. Initial commit

Commit message: `init: scaffold 2026 Stanbridge gut evac from research template (intake-staged)`.

## Open items at hand-off

- **Cohort count and weight brackets** (FW-PR-02) — resolved during pond selection, not at create-project time. `glossary.md` "Cohort" entry has a TBD placeholder table.
- **`docs/reference/pond-selection.md`** (FW-PR-03) — author after operations confirms static-pond-fast feasibility (FW-PR-05). Currently the `Stanbridge scope` glossary entry references it as a forward link; the link will resolve once the doc lands.
- **`/select-trial-ponds` skill** (FW-PR-04) — implement after the reference doc exists.

These do not block `/create-project`; they are normal post-scaffold work items.
