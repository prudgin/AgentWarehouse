# Future Work

Open backlog. Top of file = next up. As work ships, the entry moves out: shipped behaviour goes into `docs/reference/`; rationale and decision history go into `docs/adr/` or `analysis/analysis-landscape.md`.

This file holds **proposals, watching-points, open questions, and refinement candidates only**. Nothing about what's already done — that lives in the codebase, the reference docs, and the analysis tree.

See [`README.md`](README.md) for the boundary rule (vs. `.tickets/`), the entry format, and the four `**Type:**` values.

## Backlog

<!-- PLACEHOLDER — replace with real entries.

## Refactor the config loader to support env overlays

**What:** add a layered config-loader that overlays env-var values on top of the file-based defaults.
**Type:** proposal
**Why:** ops keep monkey-patching the YAML for staging; an explicit overlay surface is cleaner than the current ad-hoc patches.
**Open questions:** does the overlay merge dicts deeply, or replace at the top level?
**Links:** `docs/reference/config.md`.

## Watch for friction in the new lazy-import pattern

**What:** watch whether the lazy-import pattern introduced for the optional `pandas` dep produces confusing `ImportError`s when the user forgets the extras install.
**Type:** watching
**Why:** the trade-off was clean import-time vs friendly errors; if friction is high, may want to reverse.
**Open questions:** none until evidence accumulates.
**Links:** [ADR-0003](../adr/0003-lazy-imports-for-optional-deps.md).

## Where should retry config live?

**What:** decide whether retry/backoff config lives in the client constructor, a global module-level default, or per-call kwargs.
**Type:** open-question
**Why:** all three have plausible defenders; no clean answer until we see how callers use the library.
**Open questions:** which form generates the least call-site noise?
**Links:** none yet.

## CLI help-text consistency

**What:** the CLI verbs use slightly different help-text styles (some imperative, some descriptive). Worth a sweep once we use them more.
**Type:** refinement-candidate
**Why:** inconsistency is low-grade friction; a single pass over all verbs would resolve it.
**Open questions:** imperative or descriptive as the canonical style?
**Links:** `docs/reference/cli.md`.

-->
