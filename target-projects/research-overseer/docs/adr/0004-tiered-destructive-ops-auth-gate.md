# ADR-0004 — Tiered destructive-ops auth gate

**Status**: Accepted (intake 2026-05-21)

## Context

The research-overseer has write access to `sharepoint_planning:` and is asked to maintain the register, delete empty folders, restructure old stuff. These actions span low-risk (mechanical XLSX cell writes from canonical `entry.yaml` truth) to high-risk (irrecoverable SharePoint folder deletes / renames on shared state). A uniform "always ask" gate is too friction-heavy; a uniform "yolo" gate is dangerous.

## Decision

Three tiers, matched to risk:

| Tier | Action class | Gate |
|---|---|---|
| **Low** | `/reconcile-register` cell writes from canonical `entry.yaml` | Auto-apply, summary printed at end of the run |
| **Medium** | Add Slug column to register; extend OptionsLists with a new enum value; create a new register row from an `entry.yaml` with no matching slug | Single batch confirm per `/reconcile-register` session — "I'm about to: A, B, C — OK?" |
| **High** | Delete SharePoint folder; rename/move SharePoint folder | Overseer writes the proposed plan to a `.tickets/sharepoint-cleanup-<date>.md` markdown first. Human explicitly OKs the ticket (changes its state). Then the overseer applies. Every applied destructive op is logged to a dated `analysis/YYYY-MM-DD-sharepoint-restructure/audit.md` |

The "write the plan to a ticket first" pattern for the high tier means destructive intent survives across sessions — you can come back next day and review queued deletes. The overseer never holds destructive intent in volatile session memory.

## Consequences

**Positive:**
- Friction matches risk.
- High-tier actions get an audit trail (analysis dir) — what was deleted, when, why.
- Manager can interrupt a queued destructive plan before it runs.

**Negative:**
- The skill code is more complex than a uniform gate.
- "Medium" requires a single confirm, but the human can't selectively reject some items in the batch — it's all-or-nothing per session. (Mitigation: list items explicitly so they can be edited in the `entry.yaml` before re-running.)

## Alternatives considered

- **(i) Always ask per operation.** Rejected: friction kills routine maintenance.
- **(ii) Uniform batch confirm.** Rejected: low-risk cell writes shouldn't require human-in-the-loop.
- **(iv) Dry-run by default, `--apply` flag.** Rejected: doesn't differentiate risk; still requires per-skill flag management.

## Related

- [[0001-entry-yaml-canonical]]
- [[reconcile-register]]
- [[sharepoint-cleanup]]
