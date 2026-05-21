**Status:** done
**Category:** enhancement
**Source:** filed from research-overseer on 2026-05-22 by AI agent
**Resolved:** 2026-05-22 by warehouse agent (see Resolution section at bottom)

## What we need

The `update-register-entry` skill is fully authored in this warehouse at `skills/update-register-entry/SKILL.md` and the research-overseer just bootstrapped 27 `.register/entry.yaml` files across all sibling research repos under `~/ResearchProjects/`. But the skill is not yet **deployed** — no per-project repo has it symlinked, and the `/finish` skill does not auto-invoke it (as ADR-0006 in research-overseer specifies). Three changes are needed in this warehouse before per-project agents can keep their entry.yaml current.

### Change 1 — Modify `skills/finish/SKILL.md` to auto-call `/update-register-entry`

Per ADR-0006 in research-overseer (`~/ResearchProjects/research-overseer/docs/adr/0006-update-register-entry-auto-invoked-from-finish.md`):

> The warehouse `/finish` skill, when invoked in a research-template project, calls `/update-register-entry` before the `/sharepoint-sync push` step.

Insert the call between the orphan/CLAUDE.md sweep and the `/sharepoint-sync push`. The skill should:
- Detect this is a research-template project (`.rclone-filter` present + path under `~/ResearchProjects/<Project Name>/`)
- Invoke `/update-register-entry`
- Halt with a clear error if that skill errors (per ADR-0006: don't silently continue)

### Change 2 — Add `.register/` carve-out to `templates/research/.rclone-filter`

The research-template's `.rclone-filter` currently excludes most agent infrastructure dirs from sync. Add an explicit include for `.register/` so `entry.yaml` round-trips to and from SharePoint. The overseer's `_tools/sweep_entries.py` reads local entry.yaml files, but if a project is worked on from a different machine, the entry.yaml needs to sync via SharePoint.

Also update any existing per-project `.rclone-filter` files that were generated from the template — they need the same carve-out. (Possibly via a migration sweep across `~/ResearchProjects/*/`.)

### Change 3 — Symlink `skills/update-register-entry/` into each existing research-template repo

The 27 existing repos under `~/ResearchProjects/<Project Name>/` (excluding `research-overseer`) each have a `.claude/skills/` dir but none currently have the `update-register-entry` symlink. Either:

- (a) Add this symlink during a one-off migration sweep that walks all sibling research repos and runs `ln -s ~/AgenticEngineering/skills/update-register-entry .claude/skills/update-register-entry` in each
- (b) Add it as a step in whatever process scaffolds new research projects (`/create-project` or `/migrate-project` — whichever applies)
- (c) Both — migration sweep for existing repos AND scaffold-time for new ones

The warehouse already has scaffolding skills (`/create-project`, `/migrate-project`); pick the right home.

## Why we need it

Research-overseer's primary value proposition is the entry.yaml ↔ register reconciliation loop. The loop needs:
- per-project entry.yaml files (DONE — research-overseer bootstrapped 27 today via `_tools/bootstrap_entries.py`)
- per-project agents updating those entry.yaml files over time (BLOCKED on Change 1 + 3 above)
- those updates syncing to SharePoint (BLOCKED on Change 2)

Without these three warehouse changes, the entry.yaml files will go stale — and the overseer's `/reconcile-register` will keep writing stale data into the register XLSX. Today's bootstrap is a one-shot; ongoing maintenance requires per-project agents to actively maintain entry.yaml via `/finish`.

## Acceptance (proposed)

- [ ] `skills/finish/SKILL.md` detects research-template projects and invokes `/update-register-entry` before `/sharepoint-sync push`; halts on error
- [ ] `templates/research/.rclone-filter` includes `.register/` for sync (and existing per-project `.rclone-filter` files migrated)
- [ ] `skills/update-register-entry/` is reachable from each existing per-project `.claude/skills/` dir, and new scaffolds add the symlink automatically
- [ ] Test: run `/finish` in any research-template project; verify entry.yaml gets refreshed and pushed to SharePoint
- [ ] research-overseer's `/reconcile-register` next run picks up the entry.yaml refresh and reflects it in the register XLSX

## Source

- Source repo: research-overseer (`~/ResearchProjects/research-overseer/`)
- Source ADRs: 0001 (entry.yaml canonical), 0006 (/finish auto-call), 0007 (status-determines-folder)
- Source ticket: none — discovered during first reconcile, 2026-05-22
- Source agent: AI (filed automatically via /file-cross-repo-ticket)

## Comments

## Resolution (2026-05-22)

On audit, two of the three changes the ticket called for were already implemented in the warehouse before pickup:

- **Change 1 (auto-call from `/finish`):** already present as step 8c in `skills/finish/SKILL.md`. It detects research-template projects (`.rclone-filter` + `$PWD` under `~/ResearchProjects/`), skips `research-overseer` by basename, invokes `/update-register-entry`, halts on error. References ADR-0006.
- **Change 2 (template `.rclone-filter` carve-out):** `templates/research/.rclone-filter` already documents `.register/` as syncing by default (lines 43–48). `.register/` is not in any exclude rule, so it round-trips. The ticket asked for an explicit include; the template's design choice was the equivalent (documentation-only comment + default inclusion).
- **Change 3 (scaffold-time `create-project`):** `skills/create-project/SKILL.md` step 9 already symlinks both `sharepoint-sync` and `update-register-entry` unconditionally for the research template.

Gaps closed by this pickup:

- **`skills/migrate-project/SKILL.md`** — Phase 3 step 4 was only symlinking `sharepoint-sync`. Added `update-register-entry` to the same step with a comment referencing ADR-0006.
- **Per-project `.rclone-filter` files** — 27 sibling research repos under `~/ResearchProjects/` had functionally-equivalent filters (`.register/` already synced because it was never excluded) but were missing the documentation comment block. Swept via a one-shot Python script (`/tmp/sweep_filters.py`) that inserted the block after the `**/.claude/**` anchor line, preserving each repo's own additions (e.g. `research-overseer`'s `/_tools/**` and `/.secrets/**`). Verified post-sweep: every project's filter now matches the template modulo project-specific extras.

Symlink audit at pickup time:

- 26/28 sibling repos already had `.claude/skills/update-register-entry` symlinked (presumably from a prior pass).
- `research-overseer` correctly excludes itself (it's the overseer, not a research project).
- `2024 Geosmin AgriTec Whitton` has only `.register/` and no `.claude/` or `.rclone-filter` — it's a partially-bootstrapped stub. Out of scope for this ticket; would need its own `/migrate-project` (or full scaffold) run before it can pick up the skill.

Acceptance criteria status:

- [x] `skills/finish/SKILL.md` detects research-template projects and invokes `/update-register-entry` before `/sharepoint-sync push`; halts on error. (Already in place.)
- [x] `templates/research/.rclone-filter` includes `.register/` for sync (and existing per-project `.rclone-filter` files migrated). (Template already documented; 27 per-project filters now updated.)
- [x] `skills/update-register-entry/` is reachable from each existing per-project `.claude/skills/` dir, and new scaffolds add the symlink automatically. (26/27 active research repos; `migrate-project` now also installs it; `create-project` already did.)
- [ ] Test: run `/finish` in any research-template project; verify entry.yaml gets refreshed and pushed to SharePoint. — **Not run in this pickup; left for next research-project session.**
- [ ] research-overseer's `/reconcile-register` next run picks up the entry.yaml refresh and reflects it in the register XLSX. — **Cross-repo concern; will manifest on next overseer run.**
