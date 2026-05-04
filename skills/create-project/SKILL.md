---
name: create-project
description: Scaffold a new project from a warehouse template. Optionally consumes staged decisions from target-projects/<name>/ (produced by /intake-target-project) to seed glossary, ADRs, domain docs, and CLAUDE.md. Use when starting a new repository, when the user asks to create or set up a new project, or when bootstrapping a fresh codebase from the AgenticEngineering warehouse. Interactive — refuses auto mode.
---

# Create Project

Scaffold a new project from one of the templates in the AgenticEngineering warehouse. If `/intake-target-project` was run first, transfer the staged drafts into the new project on top of the template skeleton.

## Refuse auto mode

If the current session is in auto mode, stop immediately and tell the user:

> This skill is interactive — it asks several questions about the project to create. Please switch to interactive mode and re-invoke `/create-project`.

Then exit. Do not proceed.

## Process

### 1. Locate the warehouse

Verify by checking that `templates/library/CLAUDE.md` exists relative to the cwd. If not, ask the user where the warehouse lives.

### 2. Resolve staging (optional)

Resolve the project name from the invocation argument (e.g. `/create-project gutevac-prototype`) or ask the user.

Check `target-projects/<name>/`:

- **Exists with `_warehouse/status.md` marked `ready-for-transfer`**: read the staged content and `_warehouse/migration-plan.md`. Most "Gather inputs" answers (template type, description, intended skills) should already be in the staging — read them, confirm with the user, fill gaps.
- **Exists but `partial`**: tell the user the intake is incomplete. Offer to resume `/intake-target-project` first, or proceed with what's staged plus questions for the gaps.
- **Does not exist**: proceed with the original question-driven scaffold (Step 3 below). Mention to the user that running `/intake-target-project <name>` first would seed the new project with glossary entries, ADRs, and a draft CLAUDE.md — but it's optional.

### 3. Gather inputs

Ask the following one at a time, waiting for each answer. Provide a recommended default. Skip any question whose answer is already in the staging.

1. **Project name.** Used for the directory name and as the project title in CLAUDE.md/README.md/glossary.md. Suggest a kebab-cased default if the user gives a sentence.
2. **Template type.** `library`, `pipeline`, `tool-integration`, or `analysis`. If the staging has a recommended template, default to it. Quick guide: `library` for a package with a public API; `pipeline` for a multi-stage data pipeline; `tool-integration` for wrappers around an external platform; `analysis` for a research project whose deliverable is investigations rather than code.
3. **Target directory.** Where the project should be created. Default: `~/PycharmProjects/<project-name>` for Python projects, `~/<project-name>` otherwise. Verify the target does not already exist.
4. **One-line project description.** Used in `README.md` and the first paragraph of `CLAUDE.md`.
5. **Git remote.** Optional.
6. **Ticket backend.** `local-markdown` (default) or `github`. If `github`, verify `gh` CLI is available and a remote is configured.

### 4. Confirm

Show a summary including:

- Project name
- Template
- Target path
- Description
- Git remote (or "none for now")
- Ticket backend
- Staging consumed: yes/no, and counts (glossary entries, ADRs, domain docs, etc.) if yes

Ask: "Proceed?" Wait for explicit yes.

### 5. Scaffold

```bash
cp -r <warehouse>/templates/<template>/ <target-path>/
cd <target-path>
```

### 6. Substitute placeholders

In every file under the target tree, replace:

- `<PLACEHOLDER: project name>` → actual project name
- `<PLACEHOLDER: ...>` (with project description) → the description from step 3

Specifically check and edit:

- `CLAUDE.md` — title line, "What this project is" section, "Git conventions" remote line.
- `README.md` — title line, description paragraph.
- `glossary.md` — title line.

Leave structural placeholder sections (`<!-- PLACEHOLDER: ... -->` blocks) intact.

**Strip the TEMPLATE META block from `CLAUDE.md`.** Every warehouse template's `CLAUDE.md` opens with a leading `<!-- TEMPLATE META — ... -->` HTML comment containing notes about the template itself; that block is meant for warehouse maintainers and must not survive into a scaffolded project.

Detection rule:

- The block is the first HTML comment in the file (`<!--` on line 1).
- Its body contains the literal phrase `TEMPLATE META`.
- It ends at the matching `-->`, which may be many lines below.

Action:

1. If `CLAUDE.md` line 1 starts with `<!--` and the comment body contains `TEMPLATE META`, delete the entire comment (from the opening `<!--` through the closing `-->` inclusive).
2. Trim any blank lines that now lead the file so the first non-blank line (typically `# CLAUDE.md — <project name>`) becomes line 1.
3. If line 1 does not start with `<!--`, or the first comment does not contain `TEMPLATE META`, do nothing — the file is already clean (e.g. transferred from staging in step 7).

After this step, `grep -c 'TEMPLATE META' CLAUDE.md` in the new project must return `0`.

### 7. Transfer staged content (if staging exists)

For every file under `target-projects/<name>/` **except** `_warehouse/`, copy to the matching path in the new project. The staged `CLAUDE.md` (if present) takes precedence over the template's placeholder version — but show the diff and confirm before overwriting.

`_warehouse/` stays in the warehouse — it's the durable record of the intake.

### 8. Initialise git

Unless the user opted out:

```bash
git init -b main
git add -A
git commit -m "Scaffold from AgenticEngineering library template"
```

If a remote was provided:

```bash
git remote add origin <remote-url>
```

Do not push.

### 9. Set up `.claude/skills/`

If the staging's CLAUDE.md lists specific skills, install those. Otherwise, leave `.claude/skills/` empty for the user to populate when needed. Mention they can install warehouse skills later by symlinking from `<warehouse>/skills/<name>` into `.claude/skills/<name>`.

### 10. Set up AGENTS.md symlink

Inside the new project:

```bash
ln -s CLAUDE.md AGENTS.md
```

### 11. Mark staging complete (if used)

Update `target-projects/<name>/_warehouse/status.md`:

- Status: `created`
- Completion date: today's date
- Target path: new project's path
- Skill version: this create-project version

### 12. Report

Tell the user what was created and what to do next:

> Created `<project-name>` at `<target-path>`.
>
> From staging: <count> glossary entries, <count> ADRs, <count> domain docs, draft CLAUDE.md. (Or: "No staging — used template only.")
>
> Next steps:
> 1. `cd <target-path>` and start a fresh Claude Code session there.
> 2. The agent will read `CLAUDE.md` first; placeholder sections marked `<!-- PLACEHOLDER -->` need filling.
> 3. Run `/grill` (when installed) to flesh out areas the intake didn't cover, or to align on the first feature.
> 4. Add real content to `docs/reference/` as code lands.

## What this skill does NOT do

- Does not run intake itself. If the user wants pre-scaffold alignment, point them to `/intake-target-project`.
- Does not delete the staging dir post-handoff (see [ADR-0015](../../docs/adr/0015-target-projects-staging.md)).
- Does not push or merge on the user's behalf.
