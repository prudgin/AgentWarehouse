# Future Work

Open backlog. Top of file = next up. As work ships, the entry moves out: shipped behaviour goes into the relevant skill or `_tools/` script; rationale and decision history go into `docs/adr/` or `analysis/analysis-landscape.md`.

This file holds **proposals, watching-points, open questions, and refinement candidates only**. Nothing about what's already done — that lives in the codebase, the skills, and the analysis tree.

See [`README.md`](README.md) for the boundary rule (vs. `.tickets/`), the entry format, and the four `**Type:**` values.

## Backlog

<!-- PLACEHOLDER — replace with real entries.

## Add a `<surface>-discover` verb

**What:** write a `_tools/<surface>-discover.sh` script and matching skill that lists every artifact in the surface without exporting.
**Type:** proposal
**Why:** currently the only way to see what's there is to export everything; a cheap discover step would speed up triage.
**Open questions:** does the discover output cache, or always hit the API?
**Links:** existing `_tools/<surface>-export.sh`.

## Watch for placeholder-substitution mismatches at push time

**What:** watch whether the `__<NAME>_PLACEHOLDER__` substitution at push time produces silent failures when a placeholder is missing from `.secrets/`.
**Type:** watching
**Why:** the pattern works, but the failure mode (silent un-substituted placeholder lands in production) is severe enough to merit ongoing attention.
**Open questions:** none until evidence accumulates.
**Links:** [ADR-0005](../adr/0005-secrets-placeholder-pattern.md).

## Should `_tools/` scripts share a common library?

**What:** decide whether shared logic across `_tools/<surface>-*.sh` scripts (auth, JSON parsing, error handling) belongs in a sourced common library or stays duplicated.
**Type:** open-question
**Why:** duplication is loud; a common library is one more layer to learn. No decision yet.
**Open questions:** is the duplication actually hurting us, or is it cosmetic?
**Links:** `_tools/README.md`.

## Skills front-matter `description` consistency

**What:** the per-surface skills have slightly different framings in their front-matter `description`. Worth a sweep once the surface list stabilises.
**Type:** refinement-candidate
**Why:** consistency helps the agent's matcher fire reliably; mismatch produces unpredictable skill auto-invocation.
**Open questions:** what's the canonical phrasing template?
**Links:** `.claude/skills/`.

-->
