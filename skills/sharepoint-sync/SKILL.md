---
name: sharepoint-sync
description: Bidirectionally mirror an MCA research project with its SharePoint folder. Pulls newer files from SharePoint at session start; pushes newer files up at /finish. Uses `rclone copy --update` (never deletes). Use when the user says "pull from sharepoint", "push to sharepoint", "sync sharepoint", or at the start/end of a session in a research project. Auto-mode safe.
---

# SharePoint Sync

Bidirectional file mirror for research projects, backed by `rclone copy --update`. Newer-file wins; no deletes propagate.

This skill is auto-mode safe.

## When to invoke

- **`/sharepoint-sync pull`** — at session start (before any work). Brings down anything that changed on SharePoint since the last push.
- **`/sharepoint-sync push`** — at end of session, typically chained from `/finish`. Sends up anything newer locally.
- **`/sharepoint-sync status`** — dry-run both directions, report differences without transferring.

If the user says "sync" without a direction, default to `status` and surface the diff before doing anything.

## Where this skill applies

Only in projects scaffolded from the `research/` template (or migrated to it). A project is sync-eligible if **all** of these hold:

1. The project root contains a `.rclone-filter`.
2. The project lives under `~/ResearchProjects/<Project Name>/`.
3. The local dir name matches an existing folder under `sharepoint_planning:PROJECTS/`.

If any of these fail, refuse and surface what's wrong. Do not invent a sync path.

## Conventions (no per-project config)

The remote path is **derived by convention from the local directory name**:

```
remote = "sharepoint_planning:PROJECTS/$(basename "$PWD")"
```

Examples:
- Local `~/ResearchProjects/2026 Gut Clearance/` ↔ remote `sharepoint_planning:PROJECTS/2026 Gut Clearance/`.
- Local `~/ResearchProjects/2026 Hydroacoustic Biomass Estimation/` ↔ remote `sharepoint_planning:PROJECTS/2026 Hydroacoustic Biomass Estimation/`.

If the local dir name does not match an existing SharePoint folder, refuse — do not create the remote folder silently. Creation is a project-setup-time decision (handled by `/create-project` or `/migrate-project`), not a sync-time decision.

## Mechanics

### The SharePoint xlsx-rewrite issue

SharePoint silently rewrites uploaded `.xlsx`, `.docx`, and `.pptx` files (adds metadata, re-saves in current OOXML), changing their byte size and hash. By default rclone reads this as "corrupted on transfer: sizes differ" and reports an error per file. The data is actually fine on SharePoint — it's just bigger after SharePoint's rewrite.

**All sync invocations therefore include `--ignore-size --ignore-checksum`** to suppress the false-positive verification failures. Trade-off: rclone will not catch *real* corruption either. Acceptable for solo workflow against a trusted SharePoint tenant.

After the first round-trip, sizes stabilise — the local file gets pulled back at the SharePoint-rewritten size, and subsequent syncs are quiet.

### Pull

```bash
rclone copy "sharepoint_planning:PROJECTS/<Project Name>" "$PWD" \
  --update \
  --filter-from .rclone-filter \
  --ignore-size --ignore-checksum \
  --progress
```

`--update` transfers a file only if the source is newer than the destination, or the destination is missing. Files newer locally are not touched.

### Push

```bash
rclone copy "$PWD" "sharepoint_planning:PROJECTS/<Project Name>" \
  --update \
  --filter-from .rclone-filter \
  --ignore-size --ignore-checksum \
  --progress
```

Same logic, opposite direction.

### Status (dry-run)

```bash
rclone copy "sharepoint_planning:PROJECTS/<Project Name>" "$PWD" \
  --update --filter-from .rclone-filter \
  --ignore-size --ignore-checksum --dry-run 2>&1 | tee /tmp/sp-pull-preview.txt

rclone copy "$PWD" "sharepoint_planning:PROJECTS/<Project Name>" \
  --update --filter-from .rclone-filter \
  --ignore-size --ignore-checksum --dry-run 2>&1 | tee /tmp/sp-push-preview.txt
```

Report each side's count + total bytes. If both directions have non-zero transfers, surface that there's two-way drift and recommend `pull` first, then re-run.

## CRITICAL: Deletes do not propagate

**`rclone copy --update` only ever transfers — it never removes.**

- If you delete a file locally, **the next push will not remove it from SharePoint**. The file persists on SharePoint until you delete it there too.
- If a file is deleted on SharePoint, **the next pull will not remove it locally**. The file persists locally.
- If both sides have the same path but different content, the **newer mtime wins silently**. There is no conflict file produced.

Why this is the design: for one-person research workflows the cost of accidental destruction (data, reports, raw measurements) is much higher than the cost of leaving a stale file around. The sync is conservative on purpose.

**To delete a file from the project, do it on both sides explicitly:**

1. `rm <path>` locally.
2. Delete it via the SharePoint web UI, or `rclone deletefile sharepoint_planning:PROJECTS/<Project Name>/<path>`.
3. Document the deletion in the relevant ticket or INVESTIGATION (so it isn't mistaken for sync drift later).

**Renames are deletes-plus-creates from rclone's point of view.** If you rename a file on one side, push/pull will leave both names present on the other side. Either rename on both sides explicitly, or accept the duplicate and delete one side.

This skill **refuses to invoke `rclone delete`, `rclone deletefile`, `rclone purge`, `rclone sync`, `rclone bisync`, `rclone move`, or `rclone moveto`**. Those are destructive in ways the user must do consciously, not automatically.

## Process

### 1. Verify environment

Run in parallel, fail fast:

- `rclone listremotes` includes `sharepoint_planning:` — required.
- `.rclone-filter` exists at the project root — required.
- `$PWD` is under `~/ResearchProjects/` — required (refuse politely otherwise; this skill only runs in research projects).
- `rclone lsd "sharepoint_planning:PROJECTS/$(basename "$PWD")"` returns 0 (folder exists on remote) — required for sync direction commands; for `status` give a clearer error if missing.

If any check fails, print the specific failure, suggest the fix, and exit. Do not proceed.

Token-expiry hint: if `rclone` returns an auth error (typically "couldn't fetch token"), tell the user to run `rclone config reconnect sharepoint_planning:` and re-run the skill. Do not attempt to refresh tokens automatically.

### 2. Resolve direction from invocation

- `pull`, `push`, `status` are explicit.
- No argument → default to `status` and surface the preview to the user before doing anything else. If user then says "go ahead", run pull then push.

### 3. Run the appropriate `rclone` command

Use the exact command shapes above. Stream stderr to the user so progress is visible.

For `pull` and `push`: also run a dry-run first if there are more than ~50 files queued for transfer (lightweight sanity gate against an unexpected mass transfer — for example, if `.rclone-filter` is missing or wrong).

### 4. Report

Concise summary, both directions where applicable:

- Direction (pull / push / both via status).
- File count transferred (or "would transfer" for dry-run).
- Total bytes.
- Any errors per file (file path + rclone's error message).
- Reminder if any deletes look obvious (e.g. local has a file at path X that's clearly the renamed version of remote's Y — surface this for the user to handle manually, but **do not act**).

### 5. What this skill does NOT do

- Does not create the SharePoint folder if it doesn't exist (that's project-setup).
- Does not delete anything on either side.
- Does not handle renames.
- Does not refresh OAuth tokens.
- Does not modify `.rclone-filter` (the user owns it).
- Does not commit anything to git (`/finish` handles that).

## Auth — one-time setup notes (for the user, not the agent)

Auth lives in `~/.config/rclone/rclone.conf`, per-user. Already configured for the canonical remote `sharepoint_planning:` (Murray Cod Australia "Planning & Development" library). Tokens refresh automatically on most calls; manual refresh is `rclone config reconnect sharepoint_planning:`.

Adding the same remote on a new machine: `rclone config` (interactive), pick `onedrive`, paste the `drive_id` and `drive_type` from the existing config. The skill assumes the canonical remote exists; setting it up is out of scope.

## Composition with other skills

- **`/finish` (in a research project)** — invokes `/sharepoint-sync push` after the orphan sweep and CLAUDE.md drift check, before the optional git push. If `/sharepoint-sync push` reports errors, `/finish` should surface them and not consider the session "finished".
- **Session start** — agents working in a research project should run `/sharepoint-sync pull` early, before reading the project's library. If pull surfaces newer files in `analysis/`, `glossary.md`, `docs/`, or `.tickets/`, the agent's loaded context may be stale; re-read those before starting work.
- **`/start-analysis` and `/finish-analysis`** — no direct dependency. Their outputs (the dated analysis dir) sync automatically because nothing in `.rclone-filter` excludes `analysis/`.
