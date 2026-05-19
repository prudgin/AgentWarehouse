# Scaffold plan — aquna-farm-reports-ingestion

Mode: **cold-start**. Consumed by `/create-project`.

## Target

- **Install path**: `/home/rndmanager/MicrosoftFlowsApps/flows/Aquna_Farm_Reports_Ingestion/`
- **Template**: `tool-integration`
- **Display name**: Aquna Farm Reports Ingestion

## Step list

1. **Scaffold from template** `templates/tool-integration/` into the install path. Copy:
   - `CLAUDE.md` (will be overwritten by the staged version)
   - `README.md` (will be overwritten)
   - `glossary.md` (will be overwritten)
   - `docs/` tree
   - `_tools/` if present
2. **Overlay staged content** from `target-projects/aquna-farm-reports-ingestion/`:
   - `CLAUDE.md`, `README.md`, `glossary.md` → top of install path.
   - `docs/adr/0001-sender-allowlist-only.md`, `docs/adr/0002-folder-layout-sender-first.md`.
   - `docs/domain/flow-spec.md`.
   - `docs/planning/future-work.md`.
3. **Add flow-package placeholders**:
   - Create empty `flow-package/` directory with a `.gitkeep`.
   - Add a `flow-package/README.md` explaining: "After first export from Power Automate, unzip into this directory and commit. The `.zip` itself is also kept at the project root for easy re-import."
4. **`.gitignore`**: from the template, plus:
   - `*.tmp`
   - `.DS_Store`
   - Do **not** ignore `*.zip` or `*.json` — the exported package and definition are part of the source.
5. **Symlink** `AGENTS.md` → `CLAUDE.md` at the project root.
6. **`.claude/skills/`**: install the standard cross-cutting + build-chain symlinks from `~/.claude/skills/` (canonical sources live in the warehouse). Specifically: `grill`, `to-prd`, `to-issues`, `triage`, `work-issue`, `finish`, `diagnose`, `zoom-out`, `file-cross-repo-ticket`, `check-inbox`. Skip research-only skills.
7. **Initialise git**: `git init`; first commit message "scaffold from warehouse tool-integration template".
8. **Do NOT push yet**: remote URL is `<to be set>` in CLAUDE.md. Leave for the user.

## Post-scaffold (out of `/create-project` scope, the next human/agent step)

- Open Power Automate, build the flow per `docs/domain/flow-spec.md`.
- Export the package; commit `flow-package.zip` + extracted `flow-package/` + `flow-definition.json`.
- Turn the flow on; verify with one test email from each sender.

## Pre-known facts

- Sibling flow projects under `/home/rndmanager/MicrosoftFlowsApps/flows/` use Pascal_Snake naming and contain exported Power Automate packages.
- The user's SharePoint root URL is `https://murraycod.sharepoint.com`; library is `Planning  Development` (literal double space).
