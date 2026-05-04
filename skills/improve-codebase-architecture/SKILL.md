---
name: improve-codebase-architecture
description: Find deepening opportunities in a codebase, informed by `glossary.md` and the decisions in `docs/adr/`. Surfaces shallow modules and proposes refactors toward deep modules (small interface, lots of behaviour). Use when the user wants to "improve architecture", "find refactoring opportunities", "consolidate tightly-coupled modules", or "make this codebase more testable". Interactive — refuses auto mode.
---

# Improve Codebase Architecture

Surface architectural friction and propose **deepening opportunities** — refactors that turn shallow modules into deep ones. Aim: testability and AI-navigability.

## Refuse auto mode

If auto mode is active, respond:

> This skill presents candidates and grills you on which to explore. Please switch to interactive mode and re-invoke `/improve-codebase-architecture`.

Then exit.

## Vocabulary

Use these terms exactly. Consistent language is the point — don't drift into "component," "service," "API," or "boundary." See [`LANGUAGE.md`](LANGUAGE.md) for full definitions.

- **Module** — anything with an interface and an implementation (function, class, package, slice).
- **Interface** — everything a caller must know to use the module: types, invariants, error modes, ordering, config. Not just the type signature.
- **Implementation** — the code inside.
- **Depth** — leverage at the interface: lots of behaviour behind a small interface. **Deep** = high leverage. **Shallow** = interface nearly as complex as the implementation.
- **Seam** — where an interface lives; a place behaviour can be altered without editing in place.
- **Adapter** — a concrete thing satisfying an interface at a seam.
- **Leverage** — what callers get from depth.
- **Locality** — what maintainers get from depth: change, bugs, knowledge concentrated.

Key principles:

- **Deletion test**: imagine deleting the module. If complexity vanishes, it was a pass-through. If complexity reappears across N callers, it was earning its keep.
- **The interface is the test surface.**
- **One adapter = hypothetical seam. Two adapters = real seam.**

This skill is **informed by** the project's domain. `glossary.md` gives names to good seams; ADRs record decisions the skill should not re-litigate.

## Process

### 1. Explore

Read `glossary.md` and any ADRs in the touched area first.

Then walk the codebase. Don't follow rigid heuristics — explore organically and note where you experience friction:

- Where does understanding one concept require bouncing between many small modules?
- Where are modules **shallow** — interface nearly as complex as the implementation?
- Where have pure functions been extracted just for testability, but the real bugs hide in how they're called (no **locality**)?
- Where do tightly-coupled modules leak across their seams?
- Which parts of the codebase are untested, or hard to test through their current interface?

Apply the **deletion test** to anything you suspect is shallow.

### 2. Present candidates

A numbered list of deepening opportunities. For each:

- **Files** — which files/modules are involved.
- **Problem** — why the current architecture is causing friction.
- **Solution** — plain English: what would change.
- **Benefits** — explained in terms of locality and leverage, and in how tests would improve.

Use `glossary.md` vocabulary for the domain, and [LANGUAGE.md](LANGUAGE.md) vocabulary for the architecture.

**ADR conflicts**: if a candidate contradicts an existing ADR, only surface it when the friction is real enough to warrant revisiting. Mark clearly: _"contradicts ADR-NNNN — but worth reopening because…"_. Don't list every theoretical refactor an ADR forbids.

Do NOT propose interfaces yet. Ask: "Which would you like to explore?"

### 3. Grilling loop

Once the user picks a candidate, drop into a grilling conversation. Walk the design tree — constraints, dependencies, the shape of the deepened module, what sits behind the seam, what tests survive.

Side effects happen inline:

- **Naming a deepened module after a concept not in `glossary.md`?** Add the term to `glossary.md` — same discipline as `/grill`.
- **Sharpening a fuzzy term during the conversation?** Update `glossary.md` right there.
- **User rejects the candidate with a load-bearing reason?** Offer an ADR, framed as: _"Want me to record this as an ADR so future architecture reviews don't re-suggest it?"_ Only offer when the reason would actually be needed by a future explorer to avoid re-suggesting. Skip ephemeral reasons ("not worth it right now") and self-evident ones.

### 4. (Optional) Design It Twice

When the user wants to explore alternative interfaces for a chosen candidate, run a parallel sub-agent pattern. See [INTERFACE-DESIGN.md](INTERFACE-DESIGN.md) for the workflow.

## What this skill does NOT do

- Does not implement the refactor — only proposes and discusses.
- Does not modify code.
- Does not grill on the project as a whole — it focuses on architectural friction specifically.
- Does not re-litigate decisions recorded in ADRs unless the friction is genuine.

(Adapted from Matt Pocock's `/improve-codebase-architecture` skill — see `references/mattpocock-skills/skills/engineering/improve-codebase-architecture/`.)
