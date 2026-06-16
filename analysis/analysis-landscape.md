# Analysis Landscape

Cross-cutting narrative across all investigations in `analysis/`. Empty for now; the warehouse design emerged from conversation-based research rather than script-driven investigation. Findings from that research are recorded in [`docs/domain/philosophy.md`](../docs/domain/philosophy.md), [`docs/domain/external-references.md`](../docs/domain/external-references.md), and the ADRs in [`docs/adr/`](../docs/adr/).

This file will be populated as the warehouse runs investigations into:
- Comparative reviews of additional reference repos.
- Performance and friction characterisation of the migration playbook on real codebases.
- Empirical data on which skills get used, which sit unused, and which need redesign.

## Themes

### Self-validation

- **2026-05-04 — template self-test.** Question: does each of the four templates produce a project an unfamiliar agent can navigate and maintain? Method: scaffolded 4 synthetic dummy projects, spawned 4 opus subagents in parallel, each did a realistic dummy task and wrote structured feedback. Finding: canonical-home rule and 3-of-3 ADR test held up well; six high-priority warehouse fixes identified (META-block stripping at scaffold, broaden `/finish` orphan-sweep targets, ship `scripts/check_docs.sh`, warehouse-vs-project CLAUDE.md disclaimer, sharpen WHAT-placeholder hint to forbid encoding design choices, convert glossary entries to `### Term` headings for deep-link integrity). Status: complete. → [INVESTIGATION](2026-05-04-template-self-test/INVESTIGATION.md)

### Canonical-setup synthesis

- **2026-06-12 — survey of this PC.** Question: how are agentic setups, philosophy files, and Claude settings actually structured across this machine, and what must a single unified canonical setup reconcile? Method: four parallel subagents (PersonalProjects survey, PycharmProjects survey, global+per-project settings audit, warehouse scope inventory) + direct reads of the philosophy files. Finding: **three coexisting conventions** on one PC — warehouse canon, the PersonalProjects `PHILOSOPHY.md` three-tenses model, and a Mercatus-derived PycharmProjects convention — plus outliers (YoutubeAI, two un-agentified projects); ten concrete reconciliation decisions catalogued as "synthesis seeds" (decision-log model, three-tenses vs warehouse layout, maintenance trio vs chains, memory stance, knobs-in-one-place, subagents, settings baseline, the philosophy file itself, glossary format, the stragglers). Status: **in-progress** — internet best-practices pass and work-PC survey still pending before synthesis. → [INVESTIGATION](2026-06-12-canonical-setup-synthesis/INVESTIGATION.md)

## Open ends

- **Internet best-practices survey** — ✅ done (appended to the 2026-06-12 investigation). Net: validated the warehouse's context-engineering bet and repo-as-memory stance; surfaced `.claude/rules/` + hooks + defined-subagents as adoptions, and bringing the global `~/.claude` layer under version control as the key multi-machine enabler.
- **Work-PC survey** — a future investigation, then a cross-machine merge.
- **Synthesis & promotion** — once the work-PC survey lands, `/finish-analysis` promotes the synthesis seeds into ADRs / `docs/domain/` / templates, potentially superseding ADR-0005 (append-only) and ADR-0007 (subagents).
