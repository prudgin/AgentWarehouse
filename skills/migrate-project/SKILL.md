---
name: migrate-project
description: Convert an existing repository onto the AgenticEngineering warehouse conventions. Reads the staged decisions from target-projects/<name>/ (produced by /intake-target-project), audits the source repo, proposes a migration plan, and executes it interactively. Use when the user wants to "migrate this project", "update this repo to the new template", "reset the agentic setup", or "bring this in line with the warehouse". Interactive — refuses auto mode.
---

# Migrate Project

Walk an existing repo, compare its agentic setup against the warehouse conventions, propose a migration plan, and execute it under user direction. Consumes the staging output of `/intake-target-project`.

## Refuse auto mode

If auto mode is active, respond:

> Migration requires your direction on each move/rename/addition. Please switch to interactive mode and re-invoke `/migrate-project`.

Then exit.

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
- **Analysis pattern**: `analysis/<dated>/REPORT.md`? `scratch/`? Other?
- **Tickets**: `.tickets/`? `.scratch/`? GitHub Issues? None?
- **`.claude/`**: `settings.json`? `agents/`? `skills/`? `state/`?
- **Subagent definitions**: `.claude/agents/*` — do they exist, what do they do?
- **Working notes**: `.claude/state/working-notes.md`?
- **Glossary content**: if `glossary.md` exists, does it follow the warehouse content contract?

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
- Confirm before the next item if the change is `convert` or `delete`.
- For `add` (from staging), `move`, `rename`: proceed without per-item confirmation (already approved).

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

### Phase 4 — Verify

Run the equivalent of `/finish` on the migrated project:

- No orphans (every doc in indexed dirs is listed in its parent README).
- No broken internal links.
- CLAUDE.md mentions every top-level directory.
- glossary.md exists (even if minimal) and follows the content contract.
- Reachability: every doc reaches CLAUDE.md via a link chain.

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
- Does not delete anything without explicit per-item confirmation.
- Does not push or commit on the user's behalf — leaves the migration as a working-tree change.
- Does not modify other repos as part of this migration — even if cross-repo tickets are discovered, file them via `/file-cross-repo-ticket`.
- Does not auto-resolve naming conflicts with existing project conventions — surfaces them for the user.
- Does not delete the staging dir post-handoff (see [ADR-0015](../../docs/adr/0015-target-projects-staging.md)).
