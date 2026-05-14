# Glossary — AgenticEngineering

Warehouse-specific vocabulary. One canonical term per concept; synonyms are listed as "Avoid" and should not appear in code, docs, or skill bodies.

## Format rules

- **Be opinionated.** When multiple words exist for the same concept, pick one and list the others as "Avoid".
- **Flag conflicts explicitly.** If a term is used ambiguously, call it out in "Flagged ambiguities" with a clear resolution.
- **One sentence per definition.** Define what it IS, not what it does.
- **Show relationships.** Use bold term names and express cardinality where obvious.
- **Domain only.** General programming concepts do not belong even if used. Ask: "is this concept unique to this warehouse, or general?" Only the former qualifies.
- **Entry shape.** Each entry is a `### Term` heading followed by a blank line, the definition paragraph, a blank line, and italic-field lines (`_Avoid_:`, `_Provenance_:`, ...). Heading style is required so deep-links into the glossary resolve via standard markdown anchors.

## Language

### Warehouse

This repository — the project factory hosting templates, skills, and reference material.

_Avoid_: Workshop, hub, library (overloaded — see below).

### Template

A drop-in project skeleton under `templates/<type>/`. Variants: `library`, `pipeline`, `tool-integration`, `analysis`, `research`.

_Avoid_: Boilerplate (broader, less specific), scaffold (verb only — "to scaffold from a template").

### Research project

A project scaffolded from `templates/research/` and bidirectionally mirrored to a SharePoint folder under `sharepoint_planning:PROJECTS/`. Distinct from an **analysis project** (local-only, ad-hoc investigations on top of other repos): a research project is "official" MCA work with stakeholder-accountable deliverables (proposals, reports, expenses). Lives under `~/ResearchProjects/<Project Name>/`; the directory name matches the SharePoint folder verbatim.

_Avoid_: Study, experiment (too narrow — a research project may contain many studies/experiments).

### SharePoint mirror

The bidirectional file mirror between a research project's local directory and its SharePoint folder, implemented via `rclone copy --update` and a per-project `.rclone-filter`. Pulls at session start, pushes at `/finish`. Deletes never propagate — they are explicit on both sides. See [ADR-0024](docs/adr/0024-research-template-bidirectional-sharepoint-mirror.md).

_Avoid_: SharePoint sync (too generic — could mean rclone sync, bisync, or this design), bidirectional sync (ambiguous about delete behaviour).

### `.rclone-filter`

The per-project file at the root of a research project, listing the paths excluded from the **SharePoint mirror**. Format: rclone filter rules (`-` excludes, `+` includes, default is include). Defines code, build artefacts, secrets, and agent install as local-only; everything else mirrors to SharePoint.

_Avoid_: Sync filter, exclude file (too generic).

### MCA

Murray Cod Australia — the user's organisation. The SharePoint tenant is `murraycod.sharepoint.com`; the canonical rclone remote for the "Planning & Development" library is `sharepoint_planning:`.

_Avoid_: Spelling out "Murray Cod Australia" in code or paths — "MCA" is the canonical short form.

### Skill

A procedural workflow with `SKILL.md` frontmatter that an agent can invoke by description match or by explicit slash command. Lives in `skills/<name>/` (canonical source) and `.claude/skills/<name>/` (per-project install, usually a symlink).

_Avoid_: Command, slash command (those are the invocation surface, not the skill itself), recipe, macro.

### Library (in this warehouse's mental model)

Declarative knowledge — `glossary.md`, `docs/`, `analysis/`. Loaded by pointer, not by trigger. Distinct from a Python library.

_Avoid_: Knowledge base, docs (too narrow — `docs/` is a part of the library, not all of it), reference (too narrow — `docs/reference/` is one section).

### Build chain

The sequence of skills used to ship a feature: `/grill` → `/to-prd` → `/to-issues` → `/triage` → `/work-issue` → `/finish`. Each step is opt-in; free-float is fine.

_Avoid_: Pipeline (overloaded with data pipelines).

### Analyse chain

The parallel sequence used for investigations: `/start-analysis` → (do the investigation) → `/finish-analysis`. Findings can spawn build-chain tickets.

_Avoid_: Research workflow.

### ADR (Architecture Decision Record)

A short markdown file in `docs/adr/` recording a design decision that passes the **3-of-3 admission test**: hard to reverse, surprising without context, result of a real trade-off.

_Avoid_: Decision log entry (we use ADRs, not a single log file), design note.

### Glossary

The single root-level `glossary.md` carrying the project's ubiquitous language. Distinct from `docs/domain/` (which holds non-vocabulary domain knowledge).

_Avoid_: Dictionary, lexicon, vocabulary list (use "glossary").

### No-orphan rule

Every document must be reachable from CLAUDE.md via a chain of links. CLAUDE.md → top-level dir → per-dir README.md → leaf doc.

_Avoid_: Reachability rule, link rule.

### Stigmergy

The principle that agents coordinate through marks left in a shared environment, not by direct messaging. Each agent reads the structured context, does its work, and leaves the structure intact for the next agent. The warehouse is a stigmergic substrate.

_Avoid_: Indirect coordination, environment-mediated coordination.

### Auto mode

Claude Code's continuous, autonomous execution mode. Interactive skills (e.g. `/grill`) refuse to run in auto mode and prompt the user to switch.

_Avoid_: Headless mode, batch mode.

### Inbox

The `.tickets/inbox/` directory in any project, holding incoming cross-repo tickets dropped by agents working in dependent repos.

_Avoid_: Cross-repo queue, message queue.

### Target project

A project the warehouse is in the process of setting up — either via cold-start (`/create-project`) or migration (`/migrate-project`). Its staged drafts live in `target-projects/<name>/` until they get transferred to the actual project repo.

_Avoid_: Client project, child project.

### Intake

The grilling phase against a target project. Run via `/intake-target-project` from the warehouse (not `/grill`, which runs inside an already-set-up project — see [ADR-0014](docs/adr/0014-warehouse-grill-vs-project-grill.md)). Output is a populated `target-projects/<name>/` ready for `/create-project` or `/migrate-project` to consume.

_Avoid_: Onboarding, kickoff.

### `_warehouse/`

The cordoned-off staging-meta subdirectory inside `target-projects/<name>/`. Holds intake notes, migration plan, status, post-handoff feedback. Everything outside `_warehouse/` transfers to the target repo on `/create-project` or `/migrate-project`; `_warehouse/` stays as durable record. The leading underscore is the marker.

_Avoid_: Meta, scratch, ops.

## Relationships

- The **Warehouse** hosts many **Templates** and many **Skills**.
- A **Template** is the shape; a project instantiated from a template is a separate repo.
- A **Skill** is invoked from a project; it can read the project's **Library** (glossary, docs, analysis).
- The **Build chain** and the **Analyse chain** are independent skill sequences sharing the same **Library**.
- An **ADR** lives in a project's `docs/adr/`. The warehouse has its own ADRs (this repo's design decisions).
- An **Inbox** is local to each project; agents working in repo A can write into repo B's inbox.
- A **Target project** is staged in `target-projects/<name>/` inside the **Warehouse** during **Intake**; on transfer, everything outside `_warehouse/` lands in the actual project repo.
- **Intake** writes into staging; **`/grill`** writes into a project's own `glossary.md` and `docs/adr/`. They do not overlap.

## Example dialogue

> **User**: "I want to start a new data-pipeline project."
> **Agent**: "Use `/create-project` and pick the `pipeline` template. Once scaffolded, run `/grill` inside the new project to flesh out the design — that's the start of the build chain."
> **User**: "What's a build chain?"
> **Agent**: "The skill sequence for shipping a feature: `/grill` for alignment, `/to-prd` for the destination doc, `/to-issues` for vertical-slice tickets, `/triage` for state, `/work-issue` for the actual work, `/finish` for cleanup."

## Flagged ambiguities

- "library" was used to mean both a Python library and the declarative-knowledge half of the warehouse — resolved: in this warehouse's docs, "library" means the declarative-knowledge layer (glossary, docs, analysis). For a Python library, say "Python library" or use the project's name.
- "skill" vs "slash command" — resolved: a **skill** is the unit (folder with SKILL.md); a slash command is one way to invoke it. The skill is the noun.
