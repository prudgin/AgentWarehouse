# Architecture Decision Records (ADRs)

One file per decision. Sequential numbering.

## Admission test (3-of-3)

Write an ADR only when **all three** are true:

1. **Hard to reverse.** Changing your mind later carries meaningful cost.
2. **Surprising without context.** A future reader will wonder "why on earth did they do it this way?"
3. **Result of a real trade-off.** There were genuine alternatives, picked one for specific reasons.

If any of the three is missing, skip the ADR. Most decisions you make in a session don't qualify.

## Format

```md
# {Short title of the decision}

{1–3 sentences: what's the context, what did we decide, and why.}
```

Optional sections (use only when they add value): Status, Considered options, Consequences.

## Index

- [0001-library-and-skills-coexist.md](0001-library-and-skills-coexist.md) — declarative knowledge in `glossary.md`/`docs/`/`analysis/`; procedural workflows in `.claude/skills/`. Two complementary forms of progressive disclosure.
- [0002-glossary-keeps-name-adopts-content-contract.md](0002-glossary-keeps-name-adopts-content-contract.md) — keep the filename `glossary.md`; adopt the "ubiquitous language" content contract (one canonical term, "Avoid" synonyms, relationships, example dialogue, flagged ambiguities).
- [0003-glossary-at-root.md](0003-glossary-at-root.md) — `glossary.md` lives at the repo root, not under `docs/`.
- [0004-keep-docs-domain-separate-from-glossary.md](0004-keep-docs-domain-separate-from-glossary.md) — `glossary.md` for vocabulary; `docs/domain/` for non-vocabulary domain knowledge (mechanics, anomalies, data shape).
- [0005-adrs-with-3-of-3-admission-test.md](0005-adrs-with-3-of-3-admission-test.md) — one file per decision, numbered, with strict admission filter. Replaces append-only `decisions.md`.
- [0006-no-specs-no-roadmap.md](0006-no-specs-no-roadmap.md) — drop `docs/planning/specs/` and `docs/planning/roadmap.md`. PRDs are short tickets, not specs. "Done" lives in code; "coming" lives in `future-work.md`.
- [0007-no-subagents-no-ephemeral-notes.md](0007-no-subagents-no-ephemeral-notes.md) — drop persistent subagent definitions and the `.claude/state/working-notes.md` ephemeral scratchpad.
- [0008-preserve-dated-analysis-pattern.md](0008-preserve-dated-analysis-pattern.md) — `analysis/YYYY-MM-DD-<topic>/REPORT.md` is first-class, with a cross-cutting `analysis-landscape.md` enforcing reachability.
- [0009-tickets-as-markdown-files.md](0009-tickets-as-markdown-files.md) — local-markdown ticket store as default; cross-repo ticket drop via `.tickets/inbox/`. GitHub Issues configurable per-project.
- [0010-no-tdd-skill.md](0010-no-tdd-skill.md) — feedback-loop discipline is in `/diagnose`. No standalone `/tdd` skill. Project-specific test conventions live in the project.
- [0011-interactive-skills-refuse-auto-mode.md](0011-interactive-skills-refuse-auto-mode.md) — skills that ask the user questions detect auto mode and exit cleanly with a switch-mode message.
- [0012-plain-folders-no-plugin.md](0012-plain-folders-no-plugin.md) — distribute as plain folder trees, not as a Claude Code plugin (`.claude-plugin/plugin.json`).
- [0013-no-orphan-rule-via-readme-indexes.md](0013-no-orphan-rule-via-readme-indexes.md) — every doc is reachable from CLAUDE.md via a chain of links. Each top-level dir has a `README.md` that indexes its contents.
- [0014-warehouse-grill-vs-project-grill.md](0014-warehouse-grill-vs-project-grill.md) — `intake-target-project` is a separate skill from `grill`; the warehouse uses the former to grill about target projects, the latter ships unchanged to projects for in-project alignment.
- [0015-target-projects-staging.md](0015-target-projects-staging.md) — `target-projects/<name>/` mirrors the eventual project layout; warehouse-side scratch lives in `_warehouse/`; per-target dirs are permanent.
- [0016-mixed-mode-for-migrate-and-create.md](0016-mixed-mode-for-migrate-and-create.md) — `/migrate-project` and `/create-project` are mixed-mode (auto for reversible local actions, pause-and-surface for destructive ones), narrowing ADR-0011's scope to purely interview-shaped skills.
- [0017-scripts-colocate-with-skills.md](0017-scripts-colocate-with-skills.md) — executable scripts the warehouse ships live inside the owning skill at `skills/<name>/scripts/`, not in a top-level `scripts/` category, so the library/skills split from ADR-0001 stays clean.
- [0018-glossary-entries-as-headings.md](0018-glossary-entries-as-headings.md) — glossary entries use `### Term` headings (not `**Term**:` bold-paragraph labels) so deep-links resolve via standard markdown anchors. Refines the content contract from ADR-0002.
- [0019-pipeline-areas-table-canonical-in-claude-md.md](0019-pipeline-areas-table-canonical-in-claude-md.md) — the pipeline template's "Pipeline areas" table in CLAUDE.md is canonical; per-stage `docs/reference/<stage>.md` is detail and links back. Includes Orchestration, which has no per-stage doc.
- [0020-investigation-md-not-report-md.md](0020-investigation-md-not-report-md.md) — the analysis deliverable file is named `INVESTIGATION.md`, not `REPORT.md`, to avoid the Claude Code harness's `Write`-tool block on report-pattern files and to align with the warehouse's existing "investigation" vocabulary.
- [0021-future-work-entries-carry-type-tag.md](0021-future-work-entries-carry-type-tag.md) — `docs/planning/future-work.md` entries carry an explicit `**Type:** watching | open-question | proposal | refinement-candidate` field; `/finish` step 6 graduation sweep becomes a grep instead of per-entry judgment.
- [0022-surface-readme-and-finish-enumeration-for-tool-integration.md](0022-surface-readme-and-finish-enumeration-for-tool-integration.md) — tool-integration surface dirs (`tasks/`, `flows/`, ...) have a `README.md` documenting surface conventions (not artifact lists); `/finish` enumerates per-artifact dirs and verifies each `*-meta.json`. Per-artifact READMEs are not required.
- [0023-templates-ship-curated-broad-allow-list.md](0023-templates-ship-curated-broad-allow-list.md) — each template's `.claude/settings.json` ships a curated broad allow-list (read-only bash, safe file ops, safe git, Python tooling) above a uniform tight deny floor (`rm -rf*`, `sudo*`, force-push, hard reset, etc.); per-template additions where required (tool-integration adds `Bash(_tools/*)`).
