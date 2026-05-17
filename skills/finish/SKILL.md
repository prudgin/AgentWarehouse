---
name: finish
description: Cleanup ritual at the end of a piece of work. Sweeps for orphan docs, verifies CLAUDE.md is still accurate, checks no-orphan reachability, optionally pushes. Use when the user says "finish up", "wrap this up", "we're done with this feature", or after the work portion of `/work-issue` is complete. Auto-mode safe; pauses for confirmations on push/merge/close.
---

# Finish

End-of-work ritual. The mechanical companion to `/work-issue` and the enforcer of the no-orphan rule.

This skill is auto-mode safe for the cleanup work. It pauses for explicit confirmation before any **shared-state** action (push, merge, ticket-close).

## Process

### 1. Verify the docs match the code

Walk through the changed files in the current branch (`git diff main --stat` or equivalent). For each touched module, check whether the relevant `docs/reference/` doc still describes it accurately. Update any drift.

If a doc references a function, type, or path that no longer exists, **stop and surface** — the user needs to decide whether the doc is wrong (update) or the change is wrong (revert).

### 2. Sweep for orphans

The no-orphan rule: every doc reachable from CLAUDE.md via a chain of links.

**Run the mechanical sweep:** `.claude/skills/finish/scripts/check-docs.sh --orphans` (the script anchors on `$PWD`, so invoke it from the project root; pass `--project-root <path>` to override). Surface findings to the user. Exit 0 means no orphans; exit 1 with `<path>` lines on stdout means orphans were found. Exit 2 means the script could not locate `CLAUDE.md` at the invocation root — re-run from the right directory. If the script is missing (older project not yet migrated), fall back to the prose procedure below.

The script derives its target dir list from CLAUDE.md's "Documentation map" section: any link target ending in `/` or pointing at a `README.md` inside a directory. For each such directory it lists every `*.md` file and verifies the file's basename appears in the directory's `README.md` (substring match). Files not mentioned are orphans.

Cross-check (agent judgment): list the project's top-level directories on disk. Any non-hidden, non-tooling directory (skip `.git/`, `node_modules/`, `.venv/`, build outputs) that is **not** referenced in the doc map is itself a CLAUDE.md-level orphan — surface it as "doc map omission: `<dir>/` exists but is not indexed in CLAUDE.md" and stop short of sweeping inside it. Fixing the omission is a CLAUDE.md edit, not a README edit.

**Fallback:** if CLAUDE.md is missing, the "Documentation map" heading is absent, or no directory references can be parsed from it, the script emits a warning on stderr and skips the orphan sweep. Do not silently fall back to a guessed list — silently missing is worse than skipping. Surface the problem in the final report so the next run (or the user) can fix CLAUDE.md.

Per-artifact-dir patterns (e.g. `tasks/<Name>/`, `<surface>/<Name>/`) are out of scope for this step — those need their own design and live in a later iteration.

For each orphan, decide (agent judgment):

- **Add to index** — the doc is real and belongs there. Edit the README.
- **Delete the file** — the doc is stale, never finished, or covered elsewhere. Confirm with user before deleting.
- **Move** — the doc belongs in a different directory. Confirm before moving.

In auto mode, only auto-fix the obvious case (file is real, just missing from index). Surface the others for user decision.

### 3. Sweep for broken links

Run `.claude/skills/finish/scripts/check-docs.sh --broken-links`. The script scans every `*.md` in scope for relative markdown links, resolves each target file (and verifies any `#anchor` matches a heading slug in that file), and prints `<source>:<line>:<link>` per broken link. Fenced code blocks, inline code spans, and HTML comments are skipped. Pre-instantiation / external dirs (`templates/`, `references/`, `target-projects/`) are excluded — placeholder content there isn't expected to resolve.

For each broken link reported, decide (agent judgment): auto-fix simple renames (link to old name, file is at new name with similar slug), surface anything ambiguous. If the script is missing, fall back to the manual prose check.

### 4. Verify CLAUDE.md is still accurate

(Agent judgment — no mechanical script for this step.)

Read the project's CLAUDE.md. Check:

- Every top-level directory mentioned still exists.
- Every directory that exists is mentioned (top-level only — subdirs are indexed by their parents).
- The project description still matches what the project does.
- The "Update rules" section reflects the current doc structure.
- **Pipeline projects only** — if CLAUDE.md contains a "Pipeline areas" section (detection: heading present and followed by a table), cross-check the table against `docs/reference/`: every stage row except *Orchestration* must have a matching `docs/reference/<stage>.md`, and every `docs/reference/<stage>.md` (excluding `README.md` and `conventions.md`) must correspond to a row in the table. Surface mismatches as judgment-call findings — do not auto-fix; the user decides whether to add the missing doc, remove the table row, or rename.

If CLAUDE.md is out of date, fix it. If the change is large enough that you're unsure, surface for the user to review before saving.

### 5. Verify the analysis tree is connected (if applicable)

If `analysis/` exists: every dated subdirectory must be linked from `analysis/analysis-landscape.md`. Apply the same orphan logic.

### 5b. Verify per-artifact-dir integrity (tool-integration projects only)

**Detection:** the project is tool-integration shape iff CLAUDE.md's "Documentation map" section references `_tools/`. If `_tools/` is not mentioned, skip this step entirely — non-tool-integration templates have no surface concept and this step is a no-op.

**Procedure:**

1. Parse CLAUDE.md's documentation map and collect every top-level directory referenced. Filter out the standard sweep targets (`docs/`, `analysis/`, `.tickets/`, `_tools/`, `.claude/`). The remaining top-level dirs are **candidate surface dirs**.
2. For each candidate surface dir `<surface>/`:
   - Verify `<surface>/README.md` exists. If missing, surface as **"missing surface README: `<surface>/README.md`"**.
   - For each subdirectory `<surface>/<Name>/` (one per artifact), verify a `<surface>-meta.json` file exists and parses as valid JSON (e.g. `python3 -m json.tool <file> >/dev/null`). Surface any missing or malformed file as **"surface integrity: `<surface>/<Name>/<surface>-meta.json` is missing"** or **"...is not valid JSON"**.

In auto mode, only surface findings — do not auto-create README stubs and do not auto-repair meta files. Both require human judgment (the README needs surface-specific conventions written out; a malformed meta usually means an interrupted export and the artifact dir itself may be partial).

### 6. Sweep for ticket-shaped future-work entries

The boundary rule (see `docs/planning/README.md`): **future-work** holds pre-decision proposals, watching-points, open questions, and refinement candidates; **`.tickets/`** holds post-decision tracked work with acceptance criteria. Same fact in both is drift.

Entries in `future-work.md` carry an explicit `**Type:**` tag (one of `proposal`, `watching`, `open-question`, `refinement-candidate`; see `docs/planning/README.md` for definitions). Only `proposal` entries are graduation candidates — the other three legitimately stay even when active.

**Mechanical sweep:** run the grep below from the project root. If `docs/planning/future-work.md` is absent, skip this step.

```sh
grep -nE '^\*\*Type:\*\* proposal' docs/planning/future-work.md
```

For each match, locate the enclosing entry (the nearest preceding heading) and surface the entry's title and body to the user as a graduation candidate:

> `<entry title>` is tagged `proposal` — ready to graduate to a ticket. Open one (`/to-prd` if it warrants a PRD, or a direct issue if not) and remove the future-work entry?

In auto mode without a user, list the candidates (titles + one-line summaries) in the final report and stop short of moving them. Do not silently rewrite `future-work.md` in auto mode — graduation is a confirmation point, not a mechanical fix.

If an entry has no `**Type:**` line at all, surface that as a finding too — every entry must carry a type per the entry-format rule. Do not guess the type; ask the user (or in auto mode, surface in the report).

### 7. Verify the ticket is in a finished state

If working a specific ticket:

- Acceptance criteria all checked.
- Status updated to `done` (or whatever the project uses for closed-and-shipped).
- Comments capture anything important the brief didn't.

Status update and ticket close: pause for confirmation.

### 8. Run final loop (if applicable)

Run the project's verification once more. Must pass before declaring done.

If a `tests/` directory exists with a runner: run it.
If a `typecheck` script exists: run it.
If a project-specific verification command is documented in CLAUDE.md: run it.

### 9. Confirm before shared-state actions

Pause and ask before:

- **Pushing the branch** to remote.
- **Merging** to main.
- **Closing the ticket**.
- **Deleting the feature branch** post-merge.

In auto mode without a user, surface what's pending and stop.

### 10. Report

- **What was changed:** files touched, modules affected.
- **Docs updated:** specific files.
- **Orphans handled:** what was indexed, deleted, moved.
- **Surface-integrity findings (tool-integration only):** missing surface READMEs, missing or malformed `<surface>-meta.json` files. Empty if not a tool-integration project or all surfaces clean.
- **Future-work graduation candidates:** entries flagged as ticket-shaped (and what was decided per entry, if interactive).
- **CLAUDE.md drift fixed:** specific changes.
- **Verification result:** pass/fail.
- **Confirmation pending:** what action(s) need yes/no.

## What this skill does NOT do

- Does not write new tests or new docs from scratch — only updates existing structure.
- Does not push, merge, or close without explicit confirmation.
- Does not delete files without confirmation (in auto mode, surfaces; in interactive mode, asks).
- Does not modify another repo as part of cleanup — that's `/file-cross-repo-ticket`.
