# Analysis Landscape

Cross-cutting narrative across all investigations in `analysis/`. Empty for now; the warehouse design emerged from conversation-based research rather than script-driven investigation. Findings from that research are recorded in [`docs/domain/philosophy.md`](../docs/domain/philosophy.md), [`docs/domain/external-references.md`](../docs/domain/external-references.md), and the ADRs in [`docs/adr/`](../docs/adr/).

This file will be populated as the warehouse runs investigations into:
- Comparative reviews of additional reference repos.
- Performance and friction characterisation of the migration playbook on real codebases.
- Empirical data on which skills get used, which sit unused, and which need redesign.

## Themes

### Self-validation

- **2026-05-04 — template self-test.** Question: does each of the four templates produce a project an unfamiliar agent can navigate and maintain? Method: scaffolded 4 synthetic dummy projects, spawned 4 opus subagents in parallel, each did a realistic dummy task and wrote structured feedback. Finding: canonical-home rule and 3-of-3 ADR test held up well; six high-priority warehouse fixes identified (META-block stripping at scaffold, broaden `/finish` orphan-sweep targets, ship `scripts/check_docs.sh`, warehouse-vs-project CLAUDE.md disclaimer, sharpen WHAT-placeholder hint to forbid encoding design choices, convert glossary entries to `### Term` headings for deep-link integrity). Status: complete. → [REPORT](2026-05-04-template-self-test/REPORT.md)

## Open ends

(none yet)
