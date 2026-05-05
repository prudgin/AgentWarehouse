# Template self-test — does the warehouse work for projects scaffolded from it?

**Date:** 2026-05-04 (started) → 2026-05-04 (last update)
**Status:** complete

## Question

Does each of the four templates (`library`, `pipeline`, `tool-integration`, `analysis`) produce a project that an unfamiliar agent can navigate, work in, and maintain without confusion? Where does the structure mislead, leak, or drift-prone? Are the doc / skill / ticket boundaries clear in practice or only on paper?

## Method

For each template:

1. Hand-scaffolded a synthetic dummy project at `/tmp/warehouse-experiment/<template>-test/`. Substituted inline `<PLACEHOLDER: ...>` markers, installed warehouse skill symlinks, `git init`.
2. Pre-loaded each project with a synthetic but realistic dummy task that forced use of the documentation map and the build/analyse chain.
3. Spawned an opus subagent with `run_in_background: true`. Each got a self-contained brief: explore the structure for 5–10 min, do the dummy task, run `/finish` (and `/finish-analysis` for the analysis project), then write structured feedback to `_feedback.md` against a fixed rubric.
4. Waited for all four to complete. Read transcripts. Synthesised common findings.

The four subagents did not see this conversation; their prompts were self-contained.

Raw feedback files are not preserved in the warehouse (they lived under `/tmp/warehouse-experiment/`, deleted on cleanup). Findings are summarised here.

### Per-project work completed by subagents

- **library-test (fakelib)** — KVStore class with TTL, 4 glossary entries, ADR-0001 (lazy eviction vs. background sweeper), reference doc, domain doc, 2 future-work entries. Caught a real CLAUDE.md drift during `/finish` step 1.
- **pipeline-test (fakepipe)** — 2-stage pipeline (ingest → normalise) with orchestrator, 4 glossary entries, ADR-0001 (skip malformed rows), domain doc, per-stage reference docs, 2 future-work entries. Updated CLAUDE.md pipeline-areas table.
- **tool-integration-test (fakeflow)** — 2 mock bash scripts in `_tools/`, 2 project-local skills, per-artifact dir, 5 glossary entries, ADR-0001 (per-artifact dirs keyed by display name), domain doc on TaskTool ID mechanics, future-work entry. Indexed in 4 README files.
- **analysis-test (fakeresearch)** — synthetic dataset (30 rows), one dated investigation with INVESTIGATION writeup, scripts, gitignored outputs, 3 glossary entries, domain doc on linear-Gaussian baseline, landscape entry, future-work entry. Honest no-ADR call (3-of-3 not met) and honest no-`docs/reference/` call.

## Findings

### What works (all four subagents confirmed)

- **Canonical-home rule held**. Across four task types, every fact found a clean home on first attempt. No "this could go in two places" moments for content. The doc map at the top of each CLAUDE.md was the single most useful navigation aid.
- **3-of-3 ADR admission test is well-calibrated**. Two subagents wrote real ADRs (library, pipeline, tool-integration) and one honestly declined to (analysis). The library subagent: *"I went into ADR-0001 ready to bounce on 'is this surprising?' — actually yes, because the original CLAUDE.md description assumed a sweeper. That moment of 'the existing docs would be wrong if I picked the obvious option' is exactly the surprise-detector the test is trying to catch."*
- **Glossary "Avoid" discipline catches real near-misses**. Library subagent reported almost writing `lifetime` in a docstring; the Avoid list pre-empted it.
- **`/finish` step 6 (future-work graduation) classified correctly across all four projects**. Six future-work entries total, all classified correctly (graduate vs. stay) by the heuristics. No false positives.
- **`/finish-analysis` + `/finish` are not redundant** (analysis subagent). The former is investigation-scoped, the latter caught a new top-level `data/` dir missing from CLAUDE.md.
- **The "no working-notes" rule (ADR-0007) was the right call for the analysis template**. The analysis subagent confirmed: *"The four canonical homes covered every fragment I produced. If I had wanted [a working-notes file], it would have been for transient mid-investigation scratch, and the right answer there is `outputs/` (gitignored) plus prose in the investigation Method section."*
- **The planning/tickets boundary table** (`docs/planning/README.md`) was called *"the best single piece of doc in the template"* by the pipeline subagent.

### Universal issues (≥2 subagents flagged independently)

**U1. TEMPLATE META block survives scaffolding** — *all four flagged*. The `<!-- TEMPLATE META — delete this block when putting the template to use. -->` block at the top of each template's CLAUDE.md is supposed to be deleted at scaffold time. None were stripped automatically; subagents had to recognise and remove them by hand. Risk: a sloppy migration leaves warehouse-meta cruft inside the project.

**U2. `/finish` orphan-sweep targets are too narrow** — *3 flagged (pipeline implicitly via "no enforcement", tool-integration explicitly, analysis explicitly)*. Step 2 names *"top-level documented directory (`docs/reference/`, `docs/adr/`, `docs/domain/`, `analysis/`, `.tickets/`)"*. It misses `_tools/` and `.claude/skills/` (load-bearing in tool-integration), per-artifact dirs (tool-integration), and any newly-created top-level dir like `data/` (analysis). The list is hardcoded rather than derived from CLAUDE.md's documentation map.

**U3. Manual sweeps that should be scripted** — *3 flagged (library, pipeline, tool-integration)*. The orphan-sweep, broken-link-sweep, and "every reference doc has its file in the index" checks are described prose-style in `/finish` SKILL.md and executed by hand. All three subagents independently proposed shipping a small `scripts/check_docs.sh` (orphan check via `find` + `grep`, broken-link check via markdown link extraction). The judgment-call steps (CLAUDE.md drift, future-work graduation) remain agent work.

**U4. Warehouse vs. project CLAUDE.md confusion is real** — *2 flagged (library, analysis)*. Both share the same skeleton (FIXED/PLACEHOLDER markers, doc map, no-orphan rule, identical sentence shapes); a sloppy agent could conflate them. Library subagent: *"both files use phrases like 'this project is a warehouse of...' (warehouse) vs. 'this project is a Python library...' (downstream). The sentence shape is identical; only the noun changes."*

**U5. Glossary↔domain duplication temptation** — *2 flagged (tool-integration, analysis)*. The "one-sentence in glossary, multi-paragraph in domain" rule is correct but invites duplication when the glossary entry wants to mention enough form to be useful. Tool-integration: *"the glossary entry for GUID wants to mention the form (`tt-<prefix>-<seq>`) which then partially duplicates the domain doc"*. The split worked but is "high-temptation" for drift.

**U6. CLAUDE.md description encodes design choices** — *1 flagged but with strong concrete example (library)*. The original `<WHAT/WHY/HOW>` content described the library as *"a single-process Python library exposing a `KVStore` class with put/get/delete and a background TTL sweeper"*. ADR-0001 then chose against a sweeper. CLAUDE.md and the ADR contradicted within minutes. The placeholder hint should explicitly say "describe shape and stack; do not encode design decisions — those go in ADRs."

### Template-specific issues

**library**:
- No code scaffold — `fakelib/`, `pyproject.toml`, `tests/` don't exist. CLAUDE.md says `pip install -e .` but there's no `pyproject.toml`. Either ship stubs or add explicit "created on first ticket" notes.

**pipeline**:
- **Pipeline-areas table is drift-prone**. Restates info that lives in code AND in `docs/reference/<stage>.md`. Update rules name it explicitly — *"a doc that needs to be named in update rules is a doc that wants to drift"* (pipeline subagent). No canonical-home declared between the table and `docs/reference/`.
- **`docs/reference/README.md` says one doc per stage *plus* `conventions.md`**, but CLAUDE.md doesn't insist on conventions.md. Disagreement on whether it's mandatory.
- **Glossary anchor convention is missing**. Glossary entries are bold-paragraph labels (`**Fixture**:`); deep-links from `docs/reference/` like `glossary.md#fixture` won't resolve. Cross-cutting issue — affects all templates.

**tool-integration**:
- **`.claude/skills/` index undifferentiated** between warehouse skills (symlinks) and project-local skills (real files). 16-entry hand-maintained index will drift; needs sectioning or auto-generation.
- **Per-artifact dirs (`<surface>/<Name>/`) lack a README index**. `/finish` has no hook for them; missing `*-meta.json` would not be flagged.
- **`.secrets/` is asserted in CLAUDE.md but not pre-created** at scaffold. Mode 700 + gitignore pattern should ship pre-built.
- **Symlink-vs-copy choice for skills not documented** in CLAUDE.md. A real project should pin one and explain.

**analysis**:
- **The original `REPORT` filename collided with the harness rule against `*.md` "report" files**. Analysis subagent had to fall back to Bash heredoc. Either rename (e.g. to `INVESTIGATION.md` — landed via ADR-0020) or document the workaround prominently.
- **Warehouse ADR references dangle inside scaffolded projects**. `docs/domain/README.md` references "ADR-0007" with no local ADR by that number. Fix: rephrase as "by warehouse convention" or inline the rationale as a local ADR with provenance.
- **Investigation stub placeholders aren't grep-able**. `finish-analysis` step 2 checks for "still placeholder text" but the prose-shaped placeholders are easy to leave in by accident. Use literal `TODO` tokens.
- **`outputs/.gitkeep` collides with `analysis/*/outputs/` gitignore**. Empty `outputs/` won't appear on a fresh clone.
- **No worked example of a research-style ADR** in `docs/adr/README.md` (current example is `event-sourced-orders.md`, build-chain).
- **No worked example of provenance chaining** (glossary → domain → investigation) in `glossary.md` format rules. The chain is correct but takes two reads to verify.

### Lower-priority observations

- **Future-work entry tagging** (pipeline). Step 6 of `/finish` requires per-entry classification by hand. Tags like `[watching]` / `[open-question]` / `[proposal]` would make it mechanical.
- **HTML-comment placeholders are invisible** in raw view (pipeline). Italicised stub bullets would be more discoverable.
- **`/finish` step 6 heuristic 4 is unusable** (library). "Entry has been in the file across more than one work session" requires session-count metadata that nothing produces. Drop or replace.
- **Future-work format-rule conflict** (library). `docs/planning/README.md` has the boundary table; `future-work.md` has its own (slightly different) "Format" section. Collapse to one source.
- **Empty-by-convention dirs are subtle** (analysis). When `docs/reference/` is intentionally empty, leave a back-pointer in its README to where the decision was deferred.

## Implications — proposed warehouse fixes

Ordered by priority (high impact + multiple subagents = top).

### High priority

1. **Strip TEMPLATE META block at scaffold** — `/create-project` (and `/migrate-project` for the CLAUDE.md transfer step) should detect and remove the leading `<!-- TEMPLATE META ... -->` block. Affects all four templates. (Cross-cuts U1.)

2. **Broaden `/finish` orphan-sweep targets** — change Step 2's target list from a hardcoded enumeration to "every directory mentioned in CLAUDE.md's documentation map" (or, less ambitious, add `_tools/`, `.claude/skills/`, and per-artifact-dir patterns to the explicit list). Make `/finish` derive the target list rather than hard-code it. (Cross-cuts U2.)

3. **Ship `scripts/check_docs.sh`** — a small executable in each template that does the mechanical orphan + broken-link sweep, and has `/finish` SKILL.md call it instead of describing the procedure prose-style. The judgment-call steps (CLAUDE.md drift detection, future-work graduation) remain in the SKILL.md as agent work. (Cross-cuts U3.)

4. **Add warehouse-vs-project disclaimer** at the top of each project template's CLAUDE.md: *"This project was scaffolded from the AgenticEngineering warehouse. The warehouse's CLAUDE.md describes the warehouse, not this project — do not load it as authoritative; this file is."* One line, all four templates. (Cross-cuts U4.)

5. **Sharpen the WHAT placeholder hint** in each template's CLAUDE.md: replace generic *"WHAT: technology, stack, shape"* guidance with *"Describe shape, stack, entry points. Do NOT bake in design decisions (eviction policy, error handling, retry semantics, etc.) — those belong in ADRs."* (Cross-cuts U6.)

6. **Convert glossary entries to `### Term` headings** so deep-links (`glossary.md#term`) resolve. Update the format-rules section in each template's `glossary.md` to specify heading-style. Cross-cutting fix; affects all templates' deep-link integrity. (Cross-cuts the pipeline-specific U5-flavoured anchor issue.)

### Medium priority

7. **Pipeline-areas table — declare a canonical home**. Either CLAUDE.md is authoritative and `docs/reference/` simply describes per-stage internals, or vice versa. Update CLAUDE.md and `docs/reference/README.md` in `templates/pipeline/` to point at the chosen primary.

8. **Section the `.claude/skills/` index README** in `templates/tool-integration/` (and mention the convention in the other three templates) into "Project-local skills" vs. "Warehouse skills" subsections. Optionally add a generator script.

9. **Pre-create `.secrets/` (mode 700) + gitignore pattern** in `templates/tool-integration/`.

10. **Document the symlink-vs-copy choice** for warehouse skills in each template's `.claude/skills/README.md` template, and recommend symlinks-by-default.

11. **Add a per-artifact-dir convention** to `templates/tool-integration/`: `<surface>/README.md` indexes the artifact dirs; `/finish` checks each artifact dir has its `*-meta.json`.

12. **Rephrase warehouse-ADR references** in scaffolded projects' templates (specifically `templates/analysis/docs/domain/README.md` references "ADR-0007"). Replace with "by warehouse convention" or have the scaffolder write a local back-pointer ADR.

13. **Add future-work entry tags** (`[watching]`, `[open-question]`, `[proposal]`) to the format rules in `docs/planning/future-work.md` template + `/finish` step 6 reads them mechanically. Optional but reduces step 6 to a `grep`.

14. **Rename or document the report-filename collision**. The harness rule against creating `*.md` "report" files via Write trips when the analysis template's primary deliverable was originally named `REPORT` (`.md`). Cheap fix: document the workaround (use Bash heredoc) in `templates/analysis/analysis/README.md`. Heavier fix: rename to `INVESTIGATION.md` (touches several files including the warehouse's `analysis/` template AND the warehouse's own analysis-tree convention — disruptive). [Resolved: rename via ADR-0020.]

### Low priority

15. **Drop `/finish` step 6 heuristic 4** ("entry has been in the file across more than one work session") — unusable without session metadata.

16. **Collapse the format-rule duplication** between `docs/planning/README.md` and `docs/planning/future-work.md` template. README has the boundary table; `future-work.md` has its own (minorly different) Format section. Pick one.

17. **Add a worked research-style ADR example** in `templates/analysis/docs/adr/README.md` (likelihood choice, validation procedure). Current example is build-chain.

18. **Add a worked provenance-chain example** (glossary → domain → investigation) in `templates/analysis/glossary.md` format rules.

19. **Make investigation stub placeholders grep-able** with literal `TODO` tokens.

20. **Fix the `analysis/*/outputs/.gitkeep` gitignore conflict**. Either gitignore-exception the `.gitkeep`, or have `start-analysis` not create it.

21. **Library template stub code scaffold** — either ship stub `pyproject.toml` + `tests/` or add explicit "created on first ticket" note in CLAUDE.md.

## Open ends

- The 13 no-trade-off fixes have been opened as a feature dir at [`.tickets/template-self-test-fixes/`](../../.tickets/template-self-test-fixes/PRD.md) (PRD + 13 issues, all `ready-for-agent`). The 8 trade-off-shaped findings are queued for a `/grill` session and will land as their own tickets / ADRs afterwards.
- The synthetic dummy projects exercised template *cold-starts*. They did not exercise migration (the `/migrate-project` flow with real legacy content). A complementary test using GutEvac as a real migration target (currently being worked by another agent) will surface migration-specific issues that this self-test couldn't.
- Subagents did not test the `/grill` skill (they had no live user to grill). The build-chain skills `/grill` → `/to-prd` → `/to-issues` → `/triage` → `/work-issue` remain unexercised by this experiment.
- Subagents read SKILL.md files manually rather than invoking the skills as slash commands (subagents can't invoke slash commands). Whether the skill bodies *as procedures* fire correctly when invoked by a real agent in interactive mode is not validated here.
- Heuristic 4 in `/finish` step 6 was implemented assuming session metadata exists; a future iteration might either build that metadata or drop the heuristic.
