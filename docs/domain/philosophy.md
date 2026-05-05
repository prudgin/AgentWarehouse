# Philosophy

The why behind the warehouse. Mental model, workflow chains, governing principles. The what and the rules are in `CLAUDE.md` and the ADRs; this file holds the narrative.

## The two LLM constraints we work around

1. **The smart zone.** Agents have a usable attention window narrower than their advertised context window — performance degrades past roughly 100k tokens. The fix: load only what the current task needs (progressive disclosure), and clear context between phases when the change of mode is cleaner than continuing.
2. **No persistent memory between sessions.** Agents don't remember the previous conversation. The fix: encode persistent state in the **repo itself**. The next agent reads what the previous agent left.

These two constraints drive every other design choice. The warehouse exists because solving them requires conventions, and conventions only work if they're enforced by the substrate.

## Stigmergy: agents as maintainers

The repo is a **stigmergic substrate** — a shared environment marked up by successive agents. Each agent:

1. Reads the structured context built by previous agents.
2. Does its work.
3. Leaves the structure intact or improved for the next agent.

Discipline is not enforced inside any single agent. It is enforced by *conventions and skills that nudge every agent into maintaining the shape*. The cleanup rituals (`/finish`, `/finish-analysis`) matter more than the start rituals — finishing is what prevents drift.

This is why the warehouse exists. Without standardised conventions, every agent re-invents structure, every project drifts in its own direction, and the body of knowledge rots. With them, each agent inherits clean context and is gently forced to leave it clean.

## Library and skills: two forms of progressive disclosure

| | Library (declarative) | Skills (procedural) |
|---|---|---|
| **Answers** | "How does this work?" / "Why this design?" / "What does this term mean?" | "How do I do X?" / "Run this workflow" |
| **Loaded** | By pointer from CLAUDE.md or by the skill that reads it | By model invocation (description match) or explicit slash |
| **Lives in** | `glossary.md`, `docs/`, `analysis/` | `.claude/skills/<name>/` per-project; `skills/<name>/` canonical |
| **Cross-references** | Library does not call skills | Skills can read library docs |
| **Update cadence** | Slow — when the system changes | Slow — when the workflow changes |

**Skills wrap procedure. Library carries knowledge.**

The library uses **reference-style** progressive disclosure: CLAUDE.md indexes everything, agents follow pointers as the task demands. Skills use **trigger-style** progressive disclosure: agents see only frontmatter descriptions and load bodies on demand.

## The two workflow chains

Two parallel skill sequences sharing the library.

### Build chain — for shipping a feature

```
/grill                — alignment interview, output is messy understanding
   ↓
/to-prd               — synthesise destination doc (problem, user stories,
                        modules, out-of-scope). Publish as ONE issue.
   ↓
/to-issues            — break PRD into vertical-slice tickets, each
                        end-to-end and AFK-grabbable, with `Blocked by` graph.
   ↓
/triage               — state machine on tickets; output is a durable agent
                        brief on each ready ticket.
   ↓
/work-issue <n>       — branch, code, run feedback loop, update docs,
                        commit, merge back.
   ↓
/finish               — sweep stale docs, ensure CLAUDE.md still accurate,
                        verify no orphans, push.
```

### Analyse chain — for investigations

```
/start-analysis <topic>
                      — creates analysis/YYYY-MM-DD-<topic>/ with INVESTIGATION.md
                        stub and a stub entry in analysis-landscape.md.
   ↓
(do the investigation, scripts in dir, outputs/ gitignored)
   ↓
/finish-analysis      — finalise INVESTIGATION, promote findings to glossary.md /
                        docs/domain/, write ADRs for any decisions, lock the
                        landscape entry. Optionally spawn build-tickets.
```

Both chains share `glossary.md`, `docs/`, `docs/adr/`, and `.tickets/`. Both chains are opt-in at every step — free-float is fine.

## The warehouse's own meta-loop

The build and analyse chains run **inside a project**. The warehouse has a third loop that runs **inside the warehouse itself**, used when setting up a new project:

```
/intake-target-project <name>
                      — alignment interview about the target project.
                        Stages decisions in target-projects/<name>/:
                        glossary entries, ADR drafts, domain docs,
                        draft CLAUDE.md, migration plan in _warehouse/.
   ↓
/create-project <name>           # for cold-starts
  or
/migrate-project <name>          # for migrations of existing repos
                      — reads target-projects/<name>/, transfers
                        everything outside _warehouse/ to the target
                        repo, marks staging complete.
```

Why a separate loop instead of running `/grill` against the target? Because at intake time the target either doesn't exist yet (cold-start) or doesn't have the warehouse shape (migration), so there's no `glossary.md` or `docs/adr/` to write to. Staging in `target-projects/<name>/` solves the chicken-and-egg: the warehouse provides the staging slots, the intake fills them, the executor transfers them. See [ADR-0014](../adr/0014-warehouse-grill-vs-project-grill.md) for why intake is a separate skill from `/grill`, and [ADR-0015](../adr/0015-target-projects-staging.md) for the staging layout (mirror eventual project + `_warehouse/` for warehouse-side scratch).

`/grill` is what the user runs **inside the new project** afterwards, for forward-looking feature alignment. The two skills are non-overlapping by design.

## Why these specific design choices

The ADRs in `docs/adr/` record the material decisions one by one. The most load-bearing:

- **[0001](../adr/0001-library-and-skills-coexist.md) — library and skills coexist.** The whole architecture rests on this split.
- **[0005](../adr/0005-adrs-with-3-of-3-admission-test.md) — ADRs with admission test.** Forces decisions to be either ephemeral (in tickets, future-work, or analysis INVESTIGATIONs) or durable (here). No middle ground.
- **[0008](../adr/0008-preserve-dated-analysis-pattern.md) — analysis pattern.** First-class home for the user's investigation work, with structural enforcement.
- **[0011](../adr/0011-interactive-skills-refuse-auto-mode.md) — auto-mode refusal.** Prevents silent misalignment when no human is in the loop.
- **[0013](../adr/0013-no-orphan-rule-via-readme-indexes.md) — no-orphan rule.** The mechanical check that keeps the structure honest.

## What we deliberately reject

- **"Spec then code"** (GSD/BMAD/Spec-Kit). PRDs are short tickets; specs are stale by the time anyone reads them. ADR-0006.
- **Append-only decision logs**. Numbered ADRs scale better and the admission test keeps signal density up. ADR-0005.
- **Persistent subagent definitions** and **ephemeral working-notes**. Both add maintenance for little gain in auto mode. ADR-0007.
- **A standalone `/tdd` skill**. Feedback-loop discipline is in `/diagnose`. ADR-0010.
- **A Claude Code plugin package**. Plain folders are more hackable. ADR-0012.

## Where this came from

The warehouse synthesises three sources:

1. The user's existing `template_agent.md` philosophy — thin CLAUDE.md, single-canonical-home rule, progressive disclosure.
2. Matt Pocock's `mattpocock/skills` repo — skill-based workflow chains, ADR admission test, ubiquitous-language contract, vertical-slice issues, agent-as-AFK-pickup model. See [external-references.md](external-references.md).
3. The user's existing repos (FishGrowthFitting, MercatusDataFeed, MicrosoftFlowsApps) — patterns that have proven themselves in real use, especially the dated-analysis tree. See [existing-projects.md](existing-projects.md).

The result is opinionated by default but every choice is recorded and reversible. If a convention starts costing more than it pays, supersede the ADR and update the substrate.
