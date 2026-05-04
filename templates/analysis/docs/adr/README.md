# Architecture Decision Records (ADRs)

One file per decision. Sequential numbering: `0001-slug.md`, `0002-slug.md`, ... Created lazily — only when a decision passes the admission test.

## Admission test (3-of-3)

Write an ADR only when **all three** are true:

1. **Hard to reverse.** Changing your mind later carries meaningful cost (database choice, event model, integration boundary, language). If you can flip it in an afternoon, it does not need an ADR.
2. **Surprising without context.** A future reader looking at the code will wonder "why on earth did they do it this way?" If the decision is the obvious default, no one will wonder, and you don't need to record it.
3. **Result of a real trade-off.** There were genuine alternatives and you picked one for specific reasons. Decisions with no alternative ("we used the only library that exists") aren't decisions.

If any of the three is missing, skip the ADR. The bar is intentionally high — sparse, signal-dense ADRs beat a dense decision log.

## What qualifies

- Architectural shape ("event-sourced write model, projected read model").
- Integration patterns between subsystems ("communicate via domain events, not synchronous HTTP").
- Technology choices that carry lock-in (database, message bus, auth provider).
- Boundary and scope decisions ("Customer data lives in the Customer subsystem; others reference it by ID only").
- Deliberate deviations from the obvious path ("manual SQL instead of an ORM, because X").
- Constraints not visible in the code (compliance requirements, partner contracts).
- Rejected alternatives when the rejection is non-obvious.

## Format

```md
# {Short title of the decision}

{1–3 sentences: what's the context, what did we decide, and why.}
```

That's the minimum viable ADR. Most decisions need nothing more.

### Optional sections

Add only when they add value:

- **Status** frontmatter (`proposed | accepted | deprecated | superseded by ADR-NNNN`) — useful when decisions are revisited.
- **Considered options** — only when the rejected alternatives are worth remembering.
- **Consequences** — only when non-obvious downstream effects need to be called out.

## Numbering

Scan `docs/adr/` for the highest existing number, increment by one. Slug is short and kebab-cased.

## Index

<!-- PLACEHOLDER — list each ADR with a one-line summary. The /finish skill
     checks that every file in this directory is listed here.

- [0001-event-sourced-orders.md](0001-event-sourced-orders.md) — write model is event-sourced; read model is projected.

-->
