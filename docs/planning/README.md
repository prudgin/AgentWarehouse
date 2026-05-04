# Planning

Where work gets staged before it becomes work. Sits upstream of `.tickets/` in the build chain.

## What's here

- [`future-work.md`](future-work.md) — the open backlog: proposals, open questions, watching-points, refinement candidates.

## Boundary: future-work vs `.tickets/`

Both hold "things not done yet". The distinction is **phase**, not content.

| | `docs/planning/future-work.md` | `.tickets/` |
|---|---|---|
| Phase | **Pre-decision** | **Post-decision** |
| Question it answers | "Should we do X?" / "What about Y?" | "Build X. Status?" |
| Shape | Vague title, "open questions" line, no AC | Concrete title, status line, AC checklist, blocked-by graph |
| Examples | "Templates to refine — watch for X." "Open question: at what scale does plain-folders flip?" "Migrate FishGrowthFitting (when ready)." | "PRD: pipeline-template MVP." "Issue 03: extract orphan-sweep script from `/finish`." |
| Lifetime | Long (months); items may sit, get refined, or be deleted as they age out. | Short (days–weeks); a ticket is open or closed. |
| Owner | Maintainer's notebook. | The build chain. |

If an entry has acceptance criteria and you'd say *yes, do this* if asked — it belongs in `.tickets/`, not here. If it's still "we should think about it", it belongs here, not there.

## Transition rule

When a future-work entry graduates to actionable work — meaning a ticket is opened for it — **delete the future-work entry**. Same fact, two homes is the failure mode this rule prevents.

Two paths to graduate:

1. **Build chain**: `/grill` against the entry → `/to-prd` → `/to-issues`. The PRD is the new home; the future-work entry is deleted as part of `/to-prd`.
2. **By hand**: open a ticket directly (small change, no PRD needed) and delete the future-work entry in the same commit.

The future-work entry can leave a one-line back-pointer in `docs/planning/future-work.md` only if there's broader rationale that didn't fit in the PRD or ticket — and even then, the back-pointer's body is "see `<ticket-link>`", not a duplicate of the ticket's content.

## What stays here even when active

Some content is genuinely planning-shaped and should *not* graduate:

- **Open questions** — undecided trade-offs, design tensions waiting for evidence. Become ADRs or domain docs once decided, not tickets.
- **Watching-points** — "watch how X plays out in real use; revisit if Y." No deliverable, just a flag for future judgment.
- **Refinement candidates** — "this skill / template might want sharpening once we use it more." Resolved by *use*, not by a worked ticket.

These belong here permanently (or until they age out as no-longer-relevant).

## Update cadence

- Top of file = next up.
- Append to the bottom for new low-priority entries; reorder when priorities shift.
- Resolved entries are **deleted**, not struck through. The git history is the audit trail.
- The `/finish` skill flags ticket-shaped entries as graduation candidates during cleanup sweeps.

## Entry format

Each entry in `future-work.md` is short — one paragraph or a small section. Format:

```md
## <short title>

**What:** one or two sentences describing the proposed work.
**Why:** what problem it solves, or what question it answers.
**Open questions:** anything that needs to be resolved before starting.
**Links:** related ADRs, REPORTs, tickets, glossary terms.
```

Order entries by priority (top = next). Resolved entries are deleted, not struck through.
