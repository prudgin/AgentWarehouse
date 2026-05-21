---
name: create-project
description: Scaffold a new project from a warehouse template. Optionally consumes staged decisions from target-projects/<name>/ (produced by /intake-target-project) to seed glossary, ADRs, domain docs, and CLAUDE.md. Use when starting a new repository, when the user asks to create or set up a new project, or when bootstrapping a fresh codebase from the AgenticEngineering warehouse. Auto-mode safe when staging is present and the target directory is fresh; pauses with explicit confirmation requests for conflicts and missing inputs.
---

# Create Project

Scaffold a new project from one of the templates in the AgenticEngineering warehouse. If `/intake-target-project` was run first, transfer the staged drafts into the new project on top of the template skeleton.

This skill is auto-mode safe for the mechanical scaffold work — most of `/create-project` is template copy, placeholder substitution, and `git init`. It pauses and surfaces for the small set of decisions that aren't safely defaulted. See [ADR-0016](../../docs/adr/0016-mixed-mode-for-migrate-and-create.md).

## Mixed mode

This skill follows the same pattern as `/work-issue` and `/finish`: auto for reversible local actions; pause-and-surface for destructive or shared-state ones.

### Auto-runnable (no confirmation)

When staging exists at `target-projects/<name>/_warehouse/status.md` marked `ready-for-transfer` and the target directory does not yet exist:

- Copy the warehouse template into the target path.
- `chmod 700 .secrets/` for the `tool-integration` template.
- Substitute `<PLACEHOLDER: ...>` markers using values from staging.
- Strip the `<!-- TEMPLATE META — ... -->` block from the scaffolded `CLAUDE.md`.
- Transfer files from `target-projects/<name>/` (excluding `_warehouse/`) into the new project, when no target-side conflict exists.
- `git init -b main`, `git add -A`, initial scaffold commit, `git remote add origin` (no push).
- Symlink `AGENTS.md → CLAUDE.md`.
- Install the `.claude/skills/` symlinks listed in the staged CLAUDE.md.
- For `research` template: `mkdir -p ~/ResearchProjects` if missing, symlink `sharepoint-sync` skill, run first `/sharepoint-sync pull` then `/sharepoint-sync push` against the existing SharePoint folder (when one is staged).
- Mark staging complete (`status.md` → `created`).

### Destructive-op set (pause and surface)

Stop and request explicit confirmation before any of these:

- **Target directory already exists.** Overwriting or merging into a non-empty directory is destructive. Surface the existing contents and ask whether to abort, pick a new name, or merge (and how).
- **Staging conflict on `CLAUDE.md`** — the staged `CLAUDE.md` and the template's `CLAUDE.md` after placeholder substitution disagree on more than the placeholder slots. Show the diff and ask how to reconcile before overwriting.
- **Staging conflict on any other transferred file** — a file in `target-projects/<name>/` would land on a path the template also wrote, with non-trivially divergent content.
- **`git push` or any cross-repo write** — never auto. Push is the user's call.
- **For `research` template: SharePoint folder creation** — if the staged SharePoint folder name doesn't yet exist on `sharepoint_planning:PROJECTS/`, surface and ask before creating. Creation isn't reversible without manual delete on SharePoint.
- **For `research` template: SharePoint folder rename** (typo fix or subfolder rename like `Articles and background/` → `Articles/`) — surface the rename and ask. Use `rclone move` for server-side renames; never `rclone delete` or `rclone purge`.

### Inputs missing in auto mode

The questions in step 3 only run interactively. If staging is absent and the session is in auto mode, surface that the skill needs project name / template type / target dir / description / git remote / ticket backend, and stop. Do not silently default these.

If staging is `partial`, list which inputs are missing and stop — do not silently fill from defaults for staged inputs.

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

Skip any question whose answer is already in the staging. For the rest, in interactive mode, ask one at a time, waiting for each answer, and provide a recommended default. In auto mode without a user, **surface the unanswered set and stop** rather than defaulting silently — see "Inputs missing in auto mode" above.

1. **Project name.** Used for the directory name and as the project title in CLAUDE.md/README.md/glossary.md. For most templates, suggest kebab-case. **For `research` template, name is Title Case with spaces** (e.g. `2026 Gut Clearance`) — must match the SharePoint folder name verbatim. Year-prefix strongly recommended for sortability.
2. **Template type.** `library`, `pipeline`, `tool-integration`, `analysis`, or `research`. If the staging has a recommended template, default to it. Quick guide: `library` for a package with a public API; `pipeline` for a multi-stage data pipeline; `tool-integration` for wrappers around an external platform; `analysis` for an ad-hoc investigation with no SharePoint mirror; `research` for an official MCA research project with bidirectional SharePoint mirror (see [ADR-0024](../../docs/adr/0024-research-template-bidirectional-sharepoint-mirror.md)).
3. **Target directory.** Where the project should be created. Defaults: `~/PycharmProjects/<project-name>` for Python projects, `~/<project-name>` otherwise, **`~/ResearchProjects/<Project Name>` for the `research` template** (the `~/ResearchProjects/` location is convention-enforced by `/sharepoint-sync`). Verify the target does not already exist.
4. **One-line project description.** Used in `README.md` and the first paragraph of `CLAUDE.md`.
5. **Git remote.** Optional.
6. **Ticket backend.** `local-markdown` (default) or `github`. If `github`, verify `gh` CLI is available and a remote is configured.
7. **For `research` template only — SharePoint folder.** Confirm the canonical remote (`sharepoint_planning:`) is configured (`rclone listremotes` includes it). Verify whether `sharepoint_planning:PROJECTS/<Project Name>/` exists (`rclone lsd`). If absent, ask the user whether to create it now (`rclone mkdir`) or expect they will create it via the SharePoint web UI before the first sync.

### 4. Confirm

Show a summary including:

- Project name
- Template
- Target path
- Description
- Git remote (or "none for now")
- Ticket backend
- Staging consumed: yes/no, and counts (glossary entries, ADRs, domain docs, etc.) if yes

In interactive mode, ask "Proceed?" and wait for explicit yes. In auto mode with complete staging and a fresh target directory, the summary is informational and the skill proceeds; the destructive-op set above still pauses for any conflict that arises during scaffold/transfer.

### 5. Scaffold

```bash
cp -r <warehouse>/templates/<template>/ <target-path>/
cd <target-path>
```

If the template is `tool-integration`, lock down the secrets directory so the assertion in `CLAUDE.md` ("Real API keys live in `.secrets/` (gitignored, mode 700)") is true the moment the project is scaffolded:

```bash
chmod 700 .secrets/
```

(Skip this for other templates — they don't ship a `.secrets/` directory.)

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

For every file under `target-projects/<name>/` **except** `_warehouse/`, copy to the matching path in the new project. The staged `CLAUDE.md` (if present) takes precedence over the template's placeholder version — but if the staged `CLAUDE.md` disagrees with the placeholder-substituted template `CLAUDE.md` on more than the placeholder slots, surface the diff and pause for confirmation (see destructive-op set). For other files, if a path collides with template-written content, surface that too.

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

**For `research` template:** install `sharepoint-sync` and `update-register-entry` unconditionally — the template assumes both. `update-register-entry` is auto-invoked from `/finish` (per ADR-0006 in `research-overseer`).

```bash
ln -s <warehouse>/skills/sharepoint-sync .claude/skills/sharepoint-sync
ln -s <warehouse>/skills/update-register-entry .claude/skills/update-register-entry
```

### 10. Set up AGENTS.md symlink

Inside the new project:

```bash
ln -s CLAUDE.md AGENTS.md
```

### 10a. Set up `~/ResearchProjects/` (research template only)

If `~/ResearchProjects/` doesn't exist, `mkdir -p ~/ResearchProjects` (auto, harmless). The `/sharepoint-sync` skill refuses to operate on projects outside this directory.

### 10b. First SharePoint sync (research template only)

If a SharePoint folder for the project exists (verified in step 3.7) and the user did not opt out, run the first sync:

```bash
cd <target-path>
rclone copy "sharepoint_planning:PROJECTS/<Project Name>" "$PWD" \
  --update --filter-from .rclone-filter --ignore-size --ignore-checksum --progress
rclone copy "$PWD" "sharepoint_planning:PROJECTS/<Project Name>" \
  --update --filter-from .rclone-filter --ignore-size --ignore-checksum --progress
```

Pull first, then push. Report file counts and bytes for each direction. The `--ignore-size --ignore-checksum` flags suppress SharePoint's xlsx-rewrite false-positive errors (see `skills/sharepoint-sync/SKILL.md`).

If no SharePoint folder exists, skip this and tell the user to create the folder, then run `/sharepoint-sync push` to upload the scaffolded local project as the initial state.

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
> For `research` template, also include: SharePoint folder (existing/created), first sync result (N files pulled, M files pushed, total bytes).
>
> Next steps:
> 1. `cd <target-path>` and start a fresh Claude Code session there.
> 2. The agent will read `CLAUDE.md` first; placeholder sections marked `<!-- PLACEHOLDER -->` need filling.
> 3. Run `/grill` (when installed) to flesh out areas the intake didn't cover, or to align on the first feature.
> 4. Add real content to `docs/reference/` as code lands.
> 5. (research template) Run `/sharepoint-sync status` at start of any new session to see drift; `/finish` will push at end.

## What this skill does NOT do

- Does not run intake itself. If the user wants pre-scaffold alignment, point them to `/intake-target-project`.
- Does not delete the staging dir post-handoff (see [ADR-0015](../../docs/adr/0015-target-projects-staging.md)).
- Does not push or merge on the user's behalf.
