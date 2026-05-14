# Research template uses bidirectional SharePoint mirror via `rclone copy --update`

"Official" MCA research projects (those with stakeholder-accountable deliverables on SharePoint) need their local directory and a SharePoint folder under `sharepoint_planning:PROJECTS/` to stay in sync. We add a new `research/` template (alongside `analysis/`) that ships five SharePoint-aligned root dirs (`Articles/`, `Proposal/`, `Data/`, `Reports/`, `Expenses/`), a `.rclone-filter`, and the `/sharepoint-sync` skill. The mirror is **symmetric except for code**: everything not in the filter — including agent infrastructure (`CLAUDE.md`, `glossary.md`, `docs/`, `.tickets/`, `analysis/`) — pushes to SharePoint, so another agent picking up the SharePoint folder sees the full project context. The sync engine is `rclone copy --update`, run once per direction (pull at session start, push at `/finish`) — newer-mtime wins per file, **deletes never propagate**, and there is no state file or baseline to maintain.

## Considered options

- **`rclone bisync`** for true bidirectional reconciliation. Rejected: needs `--resync` baseline, conflict policy, occasional manual recovery; for one-person ops the fragility outweighs the benefit.
- **Two-surface design** with a "synced surface" of human-facing dirs and a separate "code surface" of warehouse-style dirs (no agent infrastructure on SharePoint). Rejected by the user: agent infrastructure on SharePoint is a feature ("someone can plug the folder into another AI agent and they will know what's going on straight away"); duplicating shape between two audiences invents complexity for no payoff.
- **Name-mapping sync** (local `data/` ↔ remote `Data/`). Rejected: hidden translation makes round-trips surprising; better to have one canonical name on both sides.
- **Adopt SharePoint's existing layout as a brand-new `analysis/` variant** rather than a new template. Rejected: research projects have stakeholder/finance accountability that makes them genuinely different from local-only analysis projects, and the sync mechanics warrant their own scaffolding.

## Consequences

- **No accidental destruction.** `rclone copy --update` cannot delete; the worst-case bug is "stale file lingers", not "data lost".
- **Deletes and renames are manual on both sides.** The `/sharepoint-sync` skill states this prominently and refuses to invoke any rclone subcommand that could remove files. Documented friction; surfaced as a [refinement-candidate in `docs/planning/future-work.md`](../planning/future-work.md) once we have evidence on how often it bites.
- **Same-file edits silently lose the older version.** Newer mtime wins. Low risk for solo workflow with tight pull→edit→push cycles; flagged as a watching-point.
- **The local dir name is the sync key.** The skill derives the remote path as `sharepoint_planning:PROJECTS/$(basename "$PWD")` — which means renaming the local dir without renaming SharePoint silently breaks sync. Mitigated by `/create-project` and `/migrate-project` enforcing the naming convention at setup time.
- **Auth is per-user via rclone**, not per-project. The warehouse does not provide tokens; it assumes the canonical remote `sharepoint_planning:` exists in `~/.config/rclone/rclone.conf`. One-time setup is out of scope for the skill.
- **The `analysis/` template stays** for ad-hoc investigations on top of other repos — the new `research/` template doesn't supersede it. Templates inventory in [docs/reference/templates.md](../reference/templates.md) distinguishes the two.
