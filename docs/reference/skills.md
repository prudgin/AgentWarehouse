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

- **`grill`** — alignment interview; opens the build chain. Interactive but auto-mode safe — asks turn-by-turn via `AskUserQuestion`.
- **`to-prd`** — synthesise a PRD from conversation context; publish as one ticket. Auto-safe.
- **`to-issues`** — break a PRD into vertical-slice tickets. Interactive but auto-mode safe — asks turn-by-turn via `AskUserQuestion`.
- **`triage`** — state machine over tickets; produces durable agent briefs. Interactive but auto-mode safe — asks turn-by-turn via `AskUserQuestion`.
- **`work-issue`** — branch, code, run feedback loop, update docs, commit. Auto-safe (defers shared-state actions).
- **`finish`** — cleanup ritual; orphan sweep; CLAUDE.md drift fix; commit + git push + merge + branch delete + ticket close. Treats the `/finish` invocation as ship authorization — runs without per-action confirmation; stops only on hard-stop conditions (force-push needed, merge conflicts, diverged remote, unexpected state).

### Analyse chain

- **`start-analysis`** — scaffold dated analysis dir + INVESTIGATION stub + landscape entry. Auto-safe.
- **`finish-analysis`** — finalise INVESTIGATION; promote findings; lock landscape. Auto-safe (defers cross-doc promotions).

### Cross-cutting

- **`diagnose`** — disciplined diagnosis loop for bugs and perf regressions. Auto-safe.
- **`improve-codebase-architecture`** — find deepening opportunities; uses module/seam/adapter vocabulary. Interactive but auto-mode safe — asks turn-by-turn via `AskUserQuestion`.
- **`zoom-out`** — higher-level explanation of code, using project vocabulary. Auto-safe.
- **`file-cross-repo-ticket`** — drop a ticket into another repo's `.tickets/inbox/`. Auto-safe.
- **`check-inbox`** — list and summarise incoming cross-repo tickets. Auto-safe.

### Power Platform integration (tool-integration projects targeting Microsoft Power Platform)

- **`power-platform-auth`** — shared library skill: how to authenticate against the Power Platform REST APIs from Linux. Two REST audiences (Flow vs PowerApps/BAP), Dataverse per-env, and the SharePoint/Graph consent gap. Loaded by the others. Auto-safe (knowledge).
- **`pac-cli-linux`** — install + run the Power Platform CLI on Linux. `pac canvas`, `pac solution`, `pac env`. Auto-safe.
- **`flows-discover`** — find which env a Power Automate cloud flow lives in. Auto-safe (read-only).
- **`flows-export`** — export a flow to `flows/<Name>/`. Auto-safe.
- **`flows-update`** — PATCH a flow back to Power Automate, with secret placeholder substitution and post-push fingerprint check. Auto-commits locally; never pushes to remote. Auto-safe.
- **`apps-discover`** — find which env a canvas app lives in. Auto-safe (read-only).
- **`apps-export`** — export a canvas app to `apps/<Name>/` with `.msapp` + unpacked `src/`. Auto-safe.
- **`apps-update`** — push edits to canvas-app `src/` via the unmanaged-solution wrapper. One-time portal step per app to wrap it in an unmanaged Dataverse solution. Auto-commits locally. Auto-safe.
- **`proxy-flow-scaffolding`** — scaffold an HTTP-triggered Power Automate proxy flow as a 4-piece set (flow + `.secrets/<name>-proxy-url` + `_tools/<name>.sh` + CLAUDE.md section). The standard workaround for connectors Linux can't reach directly. Auto-safe.
- **`anthropic-api-integration`** — how to call the Anthropic API from a Power Automate flow: HTTP action wiring, `__ANTHROPIC_API_KEY_PLACEHOLDER__` round-trip, audience safety check, model-version handling, prompt caching. Auto-safe (knowledge).

### Research-specific (only in projects scaffolded from `templates/research/`)

- **`sharepoint-sync`** — bidirectionally mirror a research project with its SharePoint folder via `rclone copy --update`. Pulls newer files at session start; pushes newer files at `/finish`. Never deletes; deletes are explicit on both sides. Auto-safe. See [ADR-0024](../adr/0024-research-template-bidirectional-sharepoint-mirror.md).
- **`update-register-entry`** — maintain `.register/entry.yaml` (the per-project record consumed by the research-overseer's `/reconcile-register`). Auto-invoked from `/finish`; respects `_meta.intentionally_blank` so re-runs don't re-ask. Auto-safe (skips human prompts in auto mode; leaves unknowns null for next interactive run).

### Research-overseer (only in `~/ResearchProjects/research-overseer/`)

- **`reconcile-register`** — sweep all per-project `.register/entry.yaml` files, diff against the master register XLSX, apply clean diffs, queue conflicts, upload. Single-batch. Tiered auth gate (overseer ADR-0004): low-tier auto-applies, medium-tier (Slug column / new rows / OptionsLists violations) batch-confirms in one prompt.
- **`detect-drift`** — read-only variant of `reconcile-register`. Produces the same diff report without writing anything. Auto-safe.
- **`sweep-sharepoint-cleanup`** — discover empty SharePoint folders; writes a proposal ticket to `.tickets/sharepoint-cleanup-<date>.md`. Auto-safe (read-only — never deletes).
- **`apply-sharepoint-cleanup`** — execute an approved cleanup ticket. Refuses unless `status: approved`. Logs every action to `analysis/YYYY-MM-DD-sharepoint-restructure/audit.md`.

### Project lifecycle

All three are research-template aware: they recognise `research` as a template choice, ask about the SharePoint folder identity, plan SharePoint-side renames, drop the `.rclone-filter`, install `sharepoint-sync`, and run the first sync. SharePoint-side mutations (folder rename, first push) are in the destructive-op set — pause-and-surface, never silent.

- **`intake-target-project`** — warehouse-only intake interview for a target project. Stages glossary entries, ADR drafts, domain docs, draft CLAUDE.md, and a migration plan in `target-projects/<name>/`. For `research` template, also stages SharePoint folder identity, planned SharePoint renames, and any project-specific `.rclone-filter` overrides. Distinct from `/grill` which runs inside an already-set-up project ([ADR-0014](../adr/0014-warehouse-grill-vs-project-grill.md)). Interactive but auto-mode safe — asks turn-by-turn via `AskUserQuestion`.
- **`create-project`** — scaffold a new project from a warehouse template; consumes `target-projects/<name>/` if present. For `research` template, also creates `~/ResearchProjects/` (if missing), uses Title Case `~/ResearchProjects/<Project Name>` as the target dir, installs `sharepoint-sync`, and runs the first pull/push. Auto-safe when staging is complete and target dir is fresh; pauses for conflicts, missing inputs, and SharePoint folder creation/rename ([ADR-0016](../adr/0016-mixed-mode-for-migrate-and-create.md), [ADR-0024](../adr/0024-research-template-bidirectional-sharepoint-mirror.md)).
- **`migrate-project`** — convert an existing repo onto warehouse conventions; consumes `target-projects/<name>/` produced by `/intake-target-project`. For `research` template, the destructive-op set additionally includes the local-repo move to `~/ResearchProjects/`, SharePoint folder/subfolder renames, and the first push. Auto-safe for additive transfer/move/rename; pauses for conversions, deletions, conflicts, and git mutations beyond `add`/`commit` ([ADR-0016](../adr/0016-mixed-mode-for-migrate-and-create.md), [ADR-0024](../adr/0024-research-template-bidirectional-sharepoint-mirror.md)).

### Global (`~/.claude/skills/`)

- **`sudo-script`** — when sudo is needed: write a script, give user one invocation, verify, delete. Interactive.

## Conventions

- Skills are kebab-cased and verb-first (`create-project`, `start-analysis`).
- Interactive skills ask via `AskUserQuestion` and run under either mode ([ADR-0011](../adr/0011-interactive-skills-refuse-auto-mode.md), reversed 2026-05-22).
- Skills can read library docs (`glossary.md`, `docs/`); library docs do not call skills ([ADR-0001](../adr/0001-library-and-skills-coexist.md)).
- Per-project installs are symlinks into `~/AgenticEngineering/skills/`, so canonical-source edits propagate.
