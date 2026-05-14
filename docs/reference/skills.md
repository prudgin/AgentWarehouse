# Skills

Procedural workflows. Canonical sources live in `skills/<name>/`; per-project installs live under `.claude/skills/<name>/` (typically as symlinks).

Each skill has a `SKILL.md` with frontmatter:

```md
---
name: skill-name
description: One sentence about what it does plus "Use when X / Y / Z" trigger conditions.
disable-model-invocation: false   # optional; true makes it slash-only
---
```

For the full inventory with auto-mode behaviour and one-line descriptions, see [`skills/README.md`](../../skills/README.md).

## Available

### Build chain

- **`grill`** — alignment interview; opens the build chain. Interactive (refuses auto mode).
- **`to-prd`** — synthesise a PRD from conversation context; publish as one ticket. Auto-safe.
- **`to-issues`** — break a PRD into vertical-slice tickets. Interactive.
- **`triage`** — state machine over tickets; produces durable agent briefs. Interactive.
- **`work-issue`** — branch, code, run feedback loop, update docs, commit. Auto-safe (defers shared-state actions).
- **`finish`** — cleanup ritual; orphan sweep; CLAUDE.md drift fix. Auto-safe (defers shared-state actions).

### Analyse chain

- **`start-analysis`** — scaffold dated analysis dir + INVESTIGATION stub + landscape entry. Auto-safe.
- **`finish-analysis`** — finalise INVESTIGATION; promote findings; lock landscape. Auto-safe (defers cross-doc promotions).

### Cross-cutting

- **`diagnose`** — disciplined diagnosis loop for bugs and perf regressions. Auto-safe.
- **`improve-codebase-architecture`** — find deepening opportunities; uses module/seam/adapter vocabulary. Interactive.
- **`zoom-out`** — higher-level explanation of code, using project vocabulary. Auto-safe.
- **`file-cross-repo-ticket`** — drop a ticket into another repo's `.tickets/inbox/`. Auto-safe.
- **`check-inbox`** — list and summarise incoming cross-repo tickets. Auto-safe.

### Research-specific (only in projects scaffolded from `templates/research/`)

- **`sharepoint-sync`** — bidirectionally mirror a research project with its SharePoint folder via `rclone copy --update`. Pulls newer files at session start; pushes newer files at `/finish`. Never deletes; deletes are explicit on both sides. Auto-safe. See [ADR-0024](../adr/0024-research-template-bidirectional-sharepoint-mirror.md).

### Project lifecycle

- **`intake-target-project`** — warehouse-only intake interview for a target project. Stages glossary entries, ADR drafts, domain docs, draft CLAUDE.md, and a migration plan in `target-projects/<name>/`. Distinct from `/grill` which runs inside an already-set-up project ([ADR-0014](../adr/0014-warehouse-grill-vs-project-grill.md)). Interactive.
- **`create-project`** — scaffold a new project from a warehouse template; consumes `target-projects/<name>/` if present. Auto-safe when staging is complete and target dir is fresh; pauses for conflicts and missing inputs ([ADR-0016](../adr/0016-mixed-mode-for-migrate-and-create.md)).
- **`migrate-project`** — convert an existing repo onto warehouse conventions; consumes `target-projects/<name>/` produced by `/intake-target-project`. Auto-safe for additive transfer/move/rename; pauses for conversions, deletions, conflicts, and git mutations beyond `add`/`commit` ([ADR-0016](../adr/0016-mixed-mode-for-migrate-and-create.md)).

### Global (`~/.claude/skills/`)

- **`sudo-script`** — when sudo is needed: write a script, give user one invocation, verify, delete. Interactive.

## Conventions

- Skills are kebab-cased and verb-first (`create-project`, `start-analysis`).
- Interactive skills detect auto mode and exit with a switch-mode message ([ADR-0011](../adr/0011-interactive-skills-refuse-auto-mode.md)).
- Skills can read library docs (`glossary.md`, `docs/`); library docs do not call skills ([ADR-0001](../adr/0001-library-and-skills-coexist.md)).
- Per-project installs are symlinks into `~/AgenticEngineering/skills/`, so canonical-source edits propagate.
