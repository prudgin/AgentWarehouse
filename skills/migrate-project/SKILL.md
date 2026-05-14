---
name: migrate-project
description: Convert an existing repository onto the AgenticEngineering warehouse conventions. Reads the staged decisions from target-projects/<name>/ (produced by /intake-target-project), audits the source repo, proposes a migration plan, and executes it interactively. Use when the user wants to "migrate this project", "update this repo to the new template", "reset the agentic setup", or "bring this in line with the warehouse". Auto-mode safe for reversible local actions; pauses with explicit confirmation requests for destructive or shared-state ones.
---

# Migrate Project

Walk an existing repo, compare its agentic setup against the warehouse conventions, propose a migration plan, and execute it under user direction. Consumes the staging output of `/intake-target-project`.

This skill is auto-mode safe. It does the reversible work autonomously (transferring staged content, moves, renames) and pauses to surface any **destructive or shared-state** action (conversions, deletions, conflicts where existing target-repo content would be overwritten, git mutations beyond `add`/`commit`) for explicit confirmation. See [ADR-0016](../../docs/adr/0016-mixed-mode-for-migrate-and-create.md).

## Mixed mode

This skill follows the same pattern as `/work-issue` and `/finish`: auto for reversible local actions; pause-and-surface for destructive or shared-state ones.

### Auto-runnable (no confirmation)

- `add` items from staging — copy `target-projects/<name>/<file>` into the source repo at the matching path, where no target-side content exists.
- `move` items — relocate existing source content to its warehouse-shaped path.
- `rename` items — rename a file to its warehouse-shaped name.
- Symlink installs under `.claude/skills/` (additive, reversible).
- Reading and diffing source content.
- Writing the audit and migration plan for user review (Phase 1, Phase 2).
- `git add` and `git commit` of staged migration changes (only if the user explicitly asked for the migration to be committed).
- For `research` template: drop `.rclone-filter` from the template, symlink `sharepoint-sync`, `mkdir -p ~/ResearchProjects` if missing.

### Destructive-op set (pause and surface)

Stop and request explicit confirmation before any of these:

- **`convert` items** — format changes such as splitting an append-only `decisions.md` into per-ADR files. Loses information shape.
- **`delete` items** — removing obsolete files (`.claude/agents/*`, stale docs, `.claude/state/working-notes.md`). High risk if user-authored.
- **Conflict resolution where existing target-repo content would be overwritten** — when a transfer-target path already exists in the source repo and staged content disagrees with it, surface the diff and ask how to merge.
- **Any `git`-mutating operation beyond `add`/`commit`** — `git push`, `git merge`, `git reset`, `git rebase`, `git branch -D`, `git rm`, force operations, history rewrites.
- **Cross-repo writes** — writing into any repo other than the source repo being migrated. Use `/file-cross-repo-ticket` instead.
- **For `research` template: moving the project to `~/ResearchProjects/<Project Name>/`** — typically `mv ~/PycharmProjects/<old-name> ~/ResearchProjects/<New Name>` plus a Title Case rename. Surface the move; ask before executing.
- **For `research` template: SharePoint folder rename** — `rclone move "sharepoint_planning:PROJECTS/<old-name>" "sharepoint_planning:PROJECTS/<New Name>"` (typo fixes, casing fixes, subfolder name standardisation like `Articles and background/` → `Articles/`). Surface each rename and ask. Server-side moves on OneDrive are fast but irreversible-without-undo.
- **For `research` template: first push to SharePoint** — uploads the source repo's full library (CLAUDE.md, glossary.md, docs/, .tickets/, analysis/) to SharePoint. Surface the push candidate count and total bytes; ask before executing. Pull first to surface any prior remote state.

In auto mode without a user, **surface what's pending and stop short of the destructive op**. Leave the migration in a state the user can confirm on return — do not silently default to a destructive choice.

## Refuse outside the warehouse

This skill expects to find `target-projects/<name>/` relative to the cwd. Verify by checking that `templates/library/CLAUDE.md` exists. If not:

> `/migrate-project` runs from inside the AgenticEngineering warehouse. Please `cd` to the warehouse and re-invoke.

## Process

### Phase 0 — Locate staging

Resolve the target name from the invocation argument (e.g. `/migrate-project gutevac`) or ask the user.

Check `target-projects/<name>/`:

- **Exists with `_warehouse/status.md` marked `ready-for-transfer`**: read the staged content and the migration plan in `_warehouse/migration-plan.md`. Proceed to Phase 1.
- **Exists but `partial`**: tell the user the intake is incomplete. Offer to resume `/intake-target-project` first, or proceed with what's staged (with a warning).
- **Does not exist**: tell the user:

  > No staging found at `target-projects/<name>/`. Run `/intake-target-project <name>` first to interview about the project, then re-invoke `/migrate-project <name>`.

  Then exit.

The source repo path is recorded in `_warehouse/status.md`.

### Phase 1 — Audit source repo

Read the source repo's state and compare to the staged drafts:

- **Top-level docs**: CLAUDE.md? README.md? glossary.md? AGENTS.md?
- **`docs/` tree**: `reference/`, `planning/`, `domain/`, `adr/`?
- **Decision log**: `decisions.md`? Append-only? How many entries?
- **Analysis pattern**: `analysis/<dated>/INVESTIGATION.md`? `scratch/`? Other?
- **Tickets**: `.tickets/`? `.scratch/`? GitHub Issues? None?
- **`.claude/`**: `settings.json`? `agents/`? `skills/`? `state/`?
- **Subagent definitions**: `.claude/agents/*` — do they exist, what do they do?
- **Working notes**: `.claude/state/working-notes.md`?
- **Glossary content**: if `glossary.md` exists, does it follow the warehouse content contract?
- **For `research` template**: source repo location (likely `~/PycharmProjects/<old-name>/`); existing local subdir names (`data/` → must rename to `Data/`; `reports/` → `Reports/`); presence of `.rclone-filter` (likely absent — drop from template); SharePoint counterpart (`rclone lsd "sharepoint_planning:PROJECTS/<staged-name>"` — exists / typo / different name). If a SharePoint folder exists with a similar but non-matching name, propose a rename in Phase 2.

Diff against:

- The warehouse template the staging targets (default: `templates/library/`).
- The staged drafts in `target-projects/<name>/`.

Surface the audit as a structured report. Categorise each item:

- **Already correct** — present in source and matches target shape.
- **Drift to fix** — present but wrong shape or location.
- **Missing — staged** — absent in source; staging has a draft to transfer.
- **Missing — needs creation** — absent in source and not staged (rare; usually means intake was incomplete).
- **Source-only** — present in source, no staged counterpart, decision needed (keep / move / archive / delete).

Wait for user acknowledgement before proceeding.

### Phase 2 — Plan

Compose the migration plan from `_warehouse/migration-plan.md` plus the audit findings. Categorise each item:

- **Add (from staging)** — copy `target-projects/<name>/<file>` (outside `_warehouse/`) into the source repo. Trivial reversibility.
- **Move** — relocate existing source content (low risk, reversible).
- **Rename** — change file name (low risk).
- **Convert** — change format, e.g. split append-only `decisions.md` into per-ADR files. Medium risk.
- **Delete** — remove obsolete file. High risk if user-authored.
- **Skip** — staged content the user explicitly declines this run.

Present the plan. For each item:

- What the change is.
- Why (which ADR, warehouse convention, or staged decision drives it).
- Reversibility.
- Whether it consumes a staged file (so the user knows what's coming from intake).

Iterate until approved.

### Phase 3 — Execute

Execute approved items one by one. After each:

- Show the diff or the file written.
- For `add` (from staging), `move`, `rename`: proceed in auto mode without per-item confirmation (already approved at plan time, fully reversible).
- For `convert`, `delete`, or any item where execution would overwrite existing target-repo content: **pause and surface** before applying. In auto mode without a user, stop here — leave a marker in the report and continue with the remaining auto-runnable items only.

#### Transfer rule for staging

For every file under `target-projects/<name>/` **except** `_warehouse/`, transfer to the source repo at the matching path:

```
target-projects/<name>/glossary.md           → <source>/glossary.md
target-projects/<name>/CLAUDE.md             → <source>/CLAUDE.md
target-projects/<name>/docs/adr/0001-foo.md  → <source>/docs/adr/0001-foo.md
target-projects/<name>/docs/domain/x.md      → <source>/docs/domain/x.md
target-projects/<name>/docs/planning/...     → <source>/docs/planning/...
```

`_warehouse/` stays in the warehouse — it's the durable record of the intake, not part of the target.

If a target path already exists in the source repo and the staged content is a draft (not a replacement), surface the conflict and ask the user how to merge.

#### Common conversions

**Splitting `decisions.md` into ADRs:**

Read the append-only log. For each entry:

- Apply the **3-of-3 admission test**. If the entry doesn't pass, **don't migrate it** — note in a "discarded entries" list.
- For passing entries: assign a sequential ADR number (continuing past any staged ADRs from intake), derive a slug, write `<source>/docs/adr/NNNN-slug.md`.

After processing, show the user:

- ADRs created from the log.
- Entries discarded (didn't pass 3-of-3).
- Original `decisions.md`: archive to `docs/adr/_legacy-decisions-log.md` for reference. Don't delete.

**Updating CLAUDE.md:**

If `target-projects/<name>/CLAUDE.md` was composed during intake, transfer it directly (after diffing against the source's existing CLAUDE.md and resolving any conflict with the user). Otherwise:

- Show the user the current CLAUDE.md alongside the warehouse template.
- Identify FIXED sections (template) vs. PLACEHOLDER sections (project-specific).
- Compose a draft and let the user edit before writing.

**Strip the TEMPLATE META block.** If the CLAUDE.md being transferred (whether from staging or composed from a warehouse template) begins with a leading `<!-- TEMPLATE META — ... -->` HTML comment, delete the entire comment plus any leading blank lines before writing it into the source repo.

Detection: line 1 starts with `<!--` and the comment body contains the literal phrase `TEMPLATE META`. The block extends to the matching `-->`, possibly many lines down. After stripping, the first non-blank line (typically `# CLAUDE.md — <project name>`) must be line 1.

After transfer, verify `grep -c 'TEMPLATE META' <source>/CLAUDE.md` returns `0`.

**Dropping subagents and ephemeral notes:**

- `.claude/agents/*` — confirm with user, then delete. Functionality lives in skills now.
- `.claude/state/working-notes.md` — confirm, then archive (if recent state matters) or delete.

**Setting up `.claude/skills/`:**

Symlink each skill listed in `target-projects/<name>/CLAUDE.md`'s skills section from `~/AgenticEngineering/skills/<name>` into `.claude/skills/<name>`. Suggest at minimum: `grill`, `to-prd`, `start-analysis`, `finish`. Full list in the warehouse's `skills/README.md`.

**For `research` template — SharePoint mirror setup:**

After the standard transfer/move/rename items complete, run the research-specific bring-up. Each item below is **destructive-op** unless noted; surface and confirm before executing.

1. **Move project to `~/ResearchProjects/<Project Name>/`** (destructive-op).
   ```bash
   mkdir -p ~/ResearchProjects
   mv "<source-path>" ~/ResearchProjects/"<Project Name>"
   ```
   Title Case with spaces (e.g. `2026 Gut Clearance`), matching the SharePoint folder name verbatim. After the move, `cd` to the new path; subsequent commands run there.

2. **Local subdir renames** (auto if listed in the migration plan; else surface): `data/` → `Data/`, `reports/` → `Reports/` (and similar). Use plain `mv` — git tracks renames automatically on next commit.

3. **Drop `.rclone-filter`** (auto): copy from `<warehouse>/templates/research/.rclone-filter` into the project root.

4. **Symlink the skill** (auto):
   ```bash
   ln -s <warehouse>/skills/sharepoint-sync .claude/skills/sharepoint-sync
   ```

5. **SharePoint folder cleanup to canonical template shape** — **auto** for renames that pull state toward the template's canonical subfolder names; **surface and confirm** only for renames that require user judgement (typo fixes on the *project* name, ambiguous shape decisions).

   Auto-apply (no per-item confirmation): the subfolder mapping is part of the template contract, not a judgement call. Common cases:
   ```bash
   rclone move "sharepoint_planning:PROJECTS/<New Name>/Articles and background" "sharepoint_planning:PROJECTS/<New Name>/Articles"
   rclone move "sharepoint_planning:PROJECTS/<New Name>/Report"                  "sharepoint_planning:PROJECTS/<New Name>/Reports"
   ```
   After moves, run `rclone lsd "sharepoint_planning:PROJECTS/<New Name>"` and `rclone rmdir` any empty (`0 items`) non-canonical leftovers (e.g. a stray `Report/` that had only the singular-form filename in it before the move). `rmdir` is safe — it refuses on non-empty dirs.

   Surface and confirm (judgement): renaming the **project** folder itself (`<old-name>` → `<New Name>`) — typo fixes, casing fixes. This affects shareable URLs.
   ```bash
   rclone move "sharepoint_planning:PROJECTS/<old-name>" "sharepoint_planning:PROJECTS/<New Name>"
   ```

   Rationale: pulling canonical shape is the *job* of this skill — leaving it as "pending user call" notes in the migrated CLAUDE.md is the failure mode this step exists to prevent. See sharepoint-sync SKILL.md "What is fine to run directly".

6. **First sync — pull then push** (destructive-op for push; pull is auto-safe). Use the exact flag set from `skills/sharepoint-sync/SKILL.md` including `--ignore-size --ignore-checksum`:
   ```bash
   rclone copy "sharepoint_planning:PROJECTS/<New Name>" "$PWD" \
     --update --filter-from .rclone-filter --ignore-size --ignore-checksum --progress
   rclone copy "$PWD" "sharepoint_planning:PROJECTS/<New Name>" \
     --update --filter-from .rclone-filter --ignore-size --ignore-checksum --progress
   ```
   Pull first (brings down anything new on remote), then push (sends up the source repo's library plus any local-only data). Report counts and bytes per direction. Surface any "size differs" warnings explicitly — they are expected for `.xlsx`/`.docx`/`.pptx` due to SharePoint's rewrite-on-upload (see `skills/sharepoint-sync/SKILL.md`), data is fine.

7. **Note duplications** — when local and SharePoint both have the same files at *different paths* (a common pattern in long-diverged projects), report the duplication explicitly in Phase 6. Do not auto-deduplicate — the user picks the canonical path; cleanup is manual on both sides per the never-deletes contract.

### Phase 4 — Verify

Run the equivalent of `/finish` on the migrated project:

- No orphans (every doc in indexed dirs is listed in its parent README).
- No broken internal links.
- CLAUDE.md mentions every top-level directory.
- glossary.md exists (even if minimal) and follows the content contract.
- Reachability: every doc reaches CLAUDE.md via a link chain.
- For `research` template: `.rclone-filter` exists at project root; `sharepoint-sync` is symlinked under `.claude/skills/`; project lives under `~/ResearchProjects/`; `rclone lsd "sharepoint_planning:PROJECTS/<Project Name>"` succeeds; first sync produced no unrecoverable errors.

Report any remaining issues for the user to fix manually.

### Phase 5 — Mark staging complete

Update `target-projects/<name>/_warehouse/status.md`:

- Status: `migrated`
- Completion date: today's date
- Target path: source repo path
- Skill version: this migrate-project version

The `_warehouse/` dir stays as institutional memory. Future warehouse-agent sessions can read it for "how did we set up this project?". Post-handoff feedback can be appended to `_warehouse/feedback.md`.

### Phase 6 — Final report

- **Migrated**: project path, what changed (categorised).
- **From staging**: count of glossary entries, ADRs, domain docs, future-work items transferred.
- **ADRs from decisions.md**: list of new ADRs derived from the source log.
- **Discarded decisions**: list (didn't pass 3-of-3).
- **Skills installed**: list.
- **Remaining manual fixes**: any items the migration deferred.
- **Suggested next step**: "Open a fresh session in the migrated project and run `/grill` against any in-flight feature work to validate the new setup."

## What this skill does NOT do

- Does not run intake itself. If staging is missing, send the user to `/intake-target-project`.
- Does not migrate code (only docs, conventions, structure).
- Does not delete anything without explicit per-item confirmation (in auto mode without a user, surfaces and stops).
- Does not push or commit on the user's behalf — leaves the migration as a working-tree change.
- Does not modify other repos as part of this migration — even if cross-repo tickets are discovered, file them via `/file-cross-repo-ticket`.
- Does not auto-resolve naming conflicts with existing project conventions — surfaces them for the user.
- Does not delete the staging dir post-handoff (see [ADR-0015](../../docs/adr/0015-target-projects-staging.md)).
