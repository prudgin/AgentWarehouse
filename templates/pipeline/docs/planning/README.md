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
| Lifetime | Long; items may sit, get refined, or age out. | Short; a ticket is open or closed. |

If an entry has acceptance criteria and you'd say *yes, do this* if asked — it belongs in `.tickets/`. If it's still "we should think about it", it belongs here.

## Transition rule

When a future-work entry graduates to actionable work — meaning a ticket is opened for it — **delete the future-work entry**. Same fact in two places is the failure mode this rule prevents.

Two paths to graduate:

1. **Build chain**: `/grill` against the entry → `/to-prd` (publishes the PRD ticket) → `/to-issues`. The future-work entry is deleted as part of `/to-prd`.
2. **By hand**: open a ticket directly (small change, no PRD needed) and delete the future-work entry in the same commit.

A one-line back-pointer (`see <ticket-link>`) is fine if there's broader rationale that didn't fit in the ticket; the body is *not* duplicated.

## What stays here even when active

- **Open questions** — undecided trade-offs, design tensions waiting for evidence. Become ADRs or domain docs once decided, not tickets.
- **Watching-points** — "watch how X plays out in real use; revisit if Y." No deliverable.
- **Refinement candidates** — "this might want sharpening once we use it more." Resolved by *use*, not by a worked ticket.

These belong here permanently (or until they age out as no-longer-relevant).

## Update cadence

- Top of file = next up.
- Resolved entries are **deleted**, not struck through. Git history is the audit trail.
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
