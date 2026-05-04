**Status:** done
**Category:** enhancement

## What to build

Update the `<!-- PLACEHOLDER ... -->` HTML comment that wraps the "What this project is" section in each template's CLAUDE.md.

Current (library example):
```
<!-- PLACEHOLDER — 8–12 lines. Cover three things:
     WHAT: technology, stack, shape of the project, major directories, entry points.
     WHY:  purpose of the project and purpose of each major part.
     HOW:  how to install, run, test, and verify changes.
     Prefer pointers over inline content. -->
```

Add an explicit prohibition on encoding design decisions:
```
<!-- PLACEHOLDER — 8–12 lines. Cover three things:
     WHAT: technology, stack, shape of the project, major directories, entry points.
     WHY:  purpose of the project and purpose of each major part.
     HOW:  how to install, run, test, and verify changes.
     Prefer pointers over inline content.
     Do NOT bake in design decisions (eviction policies, error-handling strategies,
     retry semantics, etc.) — those go in docs/adr/. CLAUDE.md describes shape;
     ADRs describe choices. -->
```

Apply to all four templates.

## Why

The library subagent ran into a real CLAUDE.md vs. ADR contradiction within minutes: the seeded `<WHAT>` description said "background TTL sweeper" — a design choice — and the very first ADR chose against it. Forcing CLAUDE.md to describe shape (not choice) prevents this drift class.

## Acceptance criteria

- [x] The placeholder hint in each of the four templates' CLAUDE.md includes the design-decision prohibition.
- [x] Wording is consistent across templates.

## Blocked by

None.

## Comments

(empty)
