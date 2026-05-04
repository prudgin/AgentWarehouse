# Skills (canonical sources)

Procedural workflow definitions. Each skill is a directory with at minimum a `SKILL.md` (frontmatter + body) and optionally supporting files (`REFERENCE.md`, `LANGUAGE.md`, `scripts/`, etc.).

These are the **canonical sources**. To install a skill into a project, symlink (or copy) the skill's directory into the project's `.claude/skills/`:

```bash
ln -s /home/rndmanager/AgenticEngineering/skills/<name> .claude/skills/<name>
```

## Skill format

```md
---
name: skill-name
description: One sentence about what it does plus "Use when X / Y / Z" trigger conditions. Max 1024 chars.
disable-model-invocation: false   # optional; true makes it slash-only
---

# Skill body
```

Many skills refuse auto mode at invocation time (interactive skills only — see [ADR-0011](../docs/adr/0011-interactive-skills-refuse-auto-mode.md)). Each SKILL.md states its auto-mode behaviour up front.

## Build chain — for shipping a feature

| Skill | Auto mode | What it does |
|---|---|---|
| [`grill`](grill/SKILL.md) | refuses | Alignment interview; one question at a time; updates `glossary.md` inline; offers ADRs. |
| [`to-prd`](to-prd/SKILL.md) | safe | Synthesise a PRD from current context; publish as one ticket. No new questions. |
| [`to-issues`](to-issues/SKILL.md) | refuses | Break a PRD into vertical-slice tickets, dependency-ordered, AFK / HITL marked. |
| [`triage`](triage/SKILL.md) | refuses | State-machine over tickets; produce durable agent briefs for AFK ones. |
| [`work-issue`](work-issue/SKILL.md) | safe (defers shared-state actions) | Branch, code, run feedback loop, update docs, commit, prepare merge. |
| [`finish`](finish/SKILL.md) | safe (defers shared-state actions) | Cleanup ritual; orphan sweep; CLAUDE.md drift fix; verification. |

## Analyse chain — for investigations

| Skill | Auto mode | What it does |
|---|---|---|
| [`start-analysis`](start-analysis/SKILL.md) | safe | Scaffold dated analysis dir + REPORT.md stub + landscape registration. |
| [`finish-analysis`](finish-analysis/SKILL.md) | safe (defers cross-doc promotions) | Verify REPORT, promote findings to glossary/domain/adr/future-work, lock landscape. |

## Cross-cutting

| Skill | Auto mode | What it does |
|---|---|---|
| [`diagnose`](diagnose/SKILL.md) | safe | Disciplined bug/perf diagnosis: feedback loop → reproduce → hypothesise → fix → cleanup. |
| [`improve-codebase-architecture`](improve-codebase-architecture/SKILL.md) | refuses | Surface deepening opportunities; deletion test; depth-as-leverage vocabulary. |
| [`zoom-out`](zoom-out/SKILL.md) | safe | Higher-level explanation of unfamiliar code, using project vocabulary. |
| [`file-cross-repo-ticket`](file-cross-repo-ticket/SKILL.md) | safe | Drop a ticket into another repo's `.tickets/inbox/`. |
| [`check-inbox`](check-inbox/SKILL.md) | safe | List and summarise incoming cross-repo tickets. |

## Project lifecycle

These skills run **from inside the warehouse**, not from inside the target project. `/intake-target-project` stages decisions in `target-projects/<name>/`; `/create-project` and `/migrate-project` consume that staging. See [ADR-0014](../docs/adr/0014-warehouse-grill-vs-project-grill.md) and [ADR-0015](../docs/adr/0015-target-projects-staging.md).

| Skill | Auto mode | What it does |
|---|---|---|
| [`intake-target-project`](intake-target-project/SKILL.md) | refuses | Warehouse-only intake interview; stages glossary, ADR drafts, domain docs, draft CLAUDE.md, migration plan in `target-projects/<name>/`. |
| [`create-project`](create-project/SKILL.md) | refuses | Scaffold a new project from a warehouse template; consumes staging if present. |
| [`migrate-project`](migrate-project/SKILL.md) | refuses | Convert an existing repo onto warehouse conventions; consumes staging produced by `/intake-target-project`. |

## Global (live in `~/.claude/skills/`)

These belong per-user, not per-project. Install once in `~/.claude/skills/`.

| Skill | Auto mode | What it does |
|---|---|---|
| [`sudo-script`](sudo-script/SKILL.md) | refuses (needs human to run script) | When sudo is needed: write commands to /tmp script, give user one invocation, verify, delete. |

## Naming

Skill names are kebab-cased and verb-first where it reads naturally (`create-project`, `start-analysis`, `file-cross-repo-ticket`). Stable: rename only via supersession (an ADR if the rename is hard to reverse).
