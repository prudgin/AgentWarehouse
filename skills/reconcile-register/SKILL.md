---
name: reconcile-register
description: Sweep all per-project `.register/entry.yaml` files, compute the diff against the master R&D projects register XLSX, apply clean diffs in a single batch, queue conflicts, and upload. Single-batch operation per ADR-0009 in research-overseer. Use when the user says "reconcile the register", "sweep the register", "update master register", or for the weekly scheduled run. Auto-mode safe for the low-tier auto-apply path; pauses for medium-tier (Slug column, OptionsLists violations, new rows).
---

# Reconcile Register

The overseer's primary write skill. Runs end-to-end: sweep → diff → apply → upload. Implements the workflow from [ADR-0001](../../../ResearchProjects/research-overseer/docs/adr/0001-entry-yaml-canonical.md) (entry.yaml is canonical) and [ADR-0004](../../../ResearchProjects/research-overseer/docs/adr/0004-tiered-destructive-ops-auth-gate.md) (tiered auth gate).

## Where this skill applies

Only in the `research-overseer` project (`~/ResearchProjects/research-overseer/`). Refuse if invoked elsewhere.

## Process

### 1. Download the working copy

```bash
cd ~/ResearchProjects/research-overseer
.venv/bin/python _tools/register_io.py download
```

Working copy lands at `_tools/scratch/RnD projects register.xlsx`. This is the in-flight edit target.

### 2. Compute the diff

```bash
.venv/bin/python _tools/diff_register.py
```

Returns JSON with five lists:
- `clean_apply` — entry.yaml changes safe to apply without confirmation (low-tier).
- `new_rows` — entry.yaml without matching register row (medium-tier — confirm).
- `orphan_rows` — register rows with no local entry.yaml (drift report only — no action).
- `options_violations` — values not in OptionsLists (medium-tier — extend OptionsLists or ask human).
- `duplicate_slugs` — two entry.yaml files share an id (blocks reconciliation — must be resolved by the human).
- `errors` — structural problems (e.g. entry.yaml without an id field).

Also returns `has_slug_column` — if false, prepend the Slug-column migration step (4a below).

### 3. Handle blocking conditions

- **`duplicate_slugs` non-empty**: stop. Print which paths share which slug. Ask the human to resolve (merge two repos, or split into two slugs).
- **`errors` non-empty**: stop. Print errors. Fix in the offending repos and re-run.

### 4. Medium-tier confirmations (single batch)

Combine into one prompt:

> About to apply:
> - X clean field updates across Y rows (low tier — auto-apply)
> - Add Slug column + slugs for Z existing rows (one-time migration, medium tier)  ← only if `has_slug_column` is false
> - Add N new register rows: <slug list> (medium tier)
> - Extend OptionsLists with M new values: <field: value list> (medium tier)
>
> Drift (not modified):
> - Q orphan register rows: <slug list>
> - R repos with no entry.yaml: <path list>
>
> Proceed?

If `clean_apply` is the only non-empty bucket and there's no missing slug column, skip the prompt and auto-apply (true low tier — entirely mechanical reflection of canonical truth).

If the user says no, abort. No write is applied.

### 5. Apply

In order:

1. If Slug column missing: `.venv/bin/python _tools/register_io.py add-slug-column` → working copy now has Slug column with generated slugs for existing rows.
2. Extend OptionsLists for violations: edit the workbook to add the new value to the relevant column (`_tools/register_io.py` doesn't expose this directly — use openpyxl interactively or write a helper as needed).
3. Apply clean diffs and new rows:
   ```bash
   .venv/bin/python _tools/register_io.py write-back <changes.json>
   ```
   `changes.json` is the combined `clean_apply` + `new_rows` from the diff. The script handles both — slugs that match an existing row update fields; slugs that don't match append new rows.
4. Upload:
   ```bash
   .venv/bin/python _tools/register_io.py upload
   ```

### 6. Report

Print a summary:

- Slug column: added (with N slugs generated) | already present
- Field updates: A fields across B rows
- New rows: C
- OptionsLists extended: D entries
- Drift: E orphan register rows, F repos without entry.yaml
- Working copy: `_tools/scratch/RnD projects register.xlsx`
- Remote: uploaded to `sharepoint_planning:PROJECTS/RnD projects register.xlsx`

### 7. Optionally file a follow-up ticket for drift

If `orphan_rows` or "repos without entry.yaml" are non-empty, offer to file a `.tickets/drift-<date>.md` listing them — so the next human session can decide whether to backfill or delete.

## What this skill does NOT do

- Does not delete register rows (ADR-0001: entry.yaml is canonical for *content*, but deletion is a manager action).
- Does not modify SharePoint folders (that's `/sweep-sharepoint-cleanup` and `/apply-sharepoint-cleanup`).
- Does not seed `entry.yaml` for repos that lack one (that's `/update-register-entry` in each per-project repo, or the bootstrap script).

## Errors and recovery

- **Download fails**: rclone error. Check network and `sharepoint_planning:` config.
- **Upload fails with "file in use"**: someone has the xlsx open in Excel. Ask user to close, then re-upload via `_tools/register_io.py upload`.
- **OpenPyXL fails on workbook**: probably a SharePoint-rewrite issue. Re-download with `--ignore-checksum` (which is already on by default).

## Related

- `/detect-drift` — read-only variant; produces the same diff report without writing.
- `/update-register-entry` — runs in each per-project repo to maintain entry.yaml.
- ADRs 0001–0006 in `research-overseer/docs/adr/`.
