---
name: sweep-sharepoint-cleanup
description: Discover SharePoint folders that may be cleanup candidates (empty folders, possibly-stale "old stuff"). Writes a proposal ticket to `.tickets/sharepoint-cleanup-<date>.md` for human review. NEVER deletes or renames anything — that's `/apply-sharepoint-cleanup`'s job. Auto-mode safe (read-only). Use when the user says "clean up sharepoint", "find empty folders", "what can we archive?", or for the weekly maintenance sweep.
---

# Sweep SharePoint Cleanup

Read-only discovery skill. Walks `sharepoint_planning:`, identifies cleanup candidates, and writes a proposal ticket. The ticket is the durable record of *intended* destructive ops — the human reviews and approves it, then `/apply-sharepoint-cleanup` executes.

This implements the **high-tier auth gate** from ADR-0004 in `research-overseer`: destructive intent is written to disk before it's applied, so it survives session boundaries and can be reviewed offline.

## Where this skill applies

Only in `~/ResearchProjects/research-overseer/`. Refuse elsewhere.

## Scope

- **Writes to `sharepoint_planning:` only.** `sharepoint:` is read-only context (ADR-0005). This skill does NOT propose any cleanup of `sharepoint:`.
- Scans these top-level dirs by default: `PROJECTS/`, `PROPOSALS/`, `Papers and literature/`, `Fish health/`, `Other/`, `Automation/`, `Finance/`.
- Skips `Research overseer/` (the overseer's own mirror — managed by `/sharepoint-sync`).

## Candidates surfaced

For now, **empty folders only**. "Restructure old stuff" requires heuristics that need real-world tuning (e.g. last-modified date + register-reference detection) — defer to future-work and revisit after a few weekly runs.

A folder is a cleanup candidate if `rclone lsf --dirs-only -R "<remote>/<folder>" | wc -l` reports zero entries AND `rclone lsf -R "<remote>/<folder>" | wc -l` also reports zero entries (no files at any depth).

## Process

1. `cd ~/ResearchProjects/research-overseer`
2. Walk each in-scope top-level dir with `rclone tree` or `rclone lsf -R --dirs-only`.
3. For each candidate empty folder, record:
   - Full remote path.
   - Date of last modification (`rclone lsl`).
4. Write the proposal ticket to `.tickets/sharepoint-cleanup-<YYYY-MM-DD>.md`:

```markdown
---
status: proposed
created: <date>
author: research-overseer / sweep-sharepoint-cleanup
risk: high
---

# SharePoint cleanup — proposed actions

Discovered by `/sweep-sharepoint-cleanup` on <date>. **None of these have been applied.** Review, edit if needed, then change `status:` to `approved` and run `/apply-sharepoint-cleanup .tickets/sharepoint-cleanup-<date>.md`.

## Empty folders to delete

- [ ] `sharepoint_planning:PROJECTS/<...>/` — last modified 2024-...
- [ ] `sharepoint_planning:Other/<...>/` — last modified 2023-...

## Folders to rename / move

(none surfaced this run — restructure heuristics not yet implemented)

## How to edit

Uncheck a box to skip that item. Add notes inline. The applier walks the checked items.
```

5. Report to the user: how many empty folders found, link to the ticket, suggest reviewing it.

## What this skill does NOT do

- Does not delete or rename anything.
- Does not touch `sharepoint:` (operational remote — read-only per ADR-0005).
- Does not surface "old" folders by date alone — that needs better heuristics.

## Related

- `/apply-sharepoint-cleanup` — execute an approved ticket.
- ADR-0004 in research-overseer — tiered auth gate.
- ADR-0005 — write-scope policy.
