# AgenticEngineering

A project factory for working with Claude Code (and other coding agents). It contains:

- **Templates** for cold-starting new projects with a clean agentic setup.
- **Skills** that wrap procedural workflows — alignment, planning, ticketing, coding, investigation, cleanup.
- **References** to external work that informed the design.

The warehouse follows its own conventions. If you want the design rationale, read [`docs/domain/philosophy.md`](docs/domain/philosophy.md) and the [ADRs](docs/adr/). This README is for *using* the warehouse and the projects it produces.

---

## Quick start

```bash
# 1. (One time) Install the global sudo-script skill so it works everywhere.
mkdir -p ~/.claude/skills
ln -s ~/AgenticEngineering/skills/sudo-script ~/.claude/skills/sudo-script

# 2. To set up a new project (cold-start or migrate an existing repo):
#    jump into the warehouse and start Claude Code.
cd ~/AgenticEngineering && claude
# Then in interactive mode:
#   /intake-target-project <name>   — interview about the project; stages in target-projects/<name>/
#   /create-project <name>          — cold-start scaffold (consumes staging if present)
#   /migrate-project <name>         — migrate an existing repo (requires staging)

# 3. To do feature work in a project that uses these conventions:
cd ~/PycharmProjects/<project> && claude
# Then: /grill, or just describe what you want and let the agent pick.
```

That's it for the headline use cases. The rest of this README is detail.

---

## What's in here

```
AgenticEngineering/
├── CLAUDE.md                       # agent's entry point — thin index
├── README.md                       # this file
├── glossary.md                     # warehouse-specific vocabulary
├── docs/
│   ├── reference/                  # what the warehouse contains (templates, skills inventory)
│   ├── adr/                        # 23 architecture decision records
│   ├── domain/                     # philosophy, external references, existing-projects survey
│   └── planning/future-work.md     # backlog
├── analysis/                       # investigations (first: 2026-05-04 template self-test)
├── .tickets/                       # warehouse's own ticket store
├── templates/
│   ├── library/                    # for libraries, packages, standalone projects
│   ├── pipeline/                   # for multi-stage data pipelines
│   ├── tool-integration/           # for wrappers around external tools / platforms
│   └── analysis/                   # for research projects (INVESTIGATIONs are the deliverable)
├── target-projects/                # per-target staging dirs (intake → migrate/create handoff)
├── skills/                         # canonical skill sources
└── references/
    └── mattpocock-skills/          # cloned reference; informed the design
```

---

## Using the warehouse

You come to the warehouse for four things: **set up a project** (cold-start or migrate), **edit a skill**, **edit a template**. Day-to-day feature work runs from inside the project, not from here.

### Setting up a project — the two-step flow

Project setup runs as two skills: an **intake** that interviews you and stages decisions, then an **executor** that scaffolds or migrates against the staging.

```
/intake-target-project <name>
                    interview about the project (cold-start or migration).
                    → asks one question at a time, recommends an answer
                    → stages glossary entries, ADR drafts, domain docs,
                      draft CLAUDE.md, migration plan
                    → output lives in target-projects/<name>/
   ↓
/create-project <name>     for a cold-start
  or
/migrate-project <name>    for an existing repo
                    consume the staging.
                    → transfer everything outside _warehouse/ into the target repo
                    → leave _warehouse/ as durable record (intake notes,
                      migration plan, status, post-handoff feedback)
```

Why two skills instead of one? Because at intake time the target either doesn't exist yet (cold-start) or doesn't have the warehouse shape (migration), so there's no `glossary.md` or `docs/adr/` to write to. Staging in `target-projects/<name>/` solves the chicken-and-egg. See [ADR-0014](docs/adr/0014-warehouse-grill-vs-project-grill.md) and [ADR-0015](docs/adr/0015-target-projects-staging.md).

#### Cold-start

```bash
cd ~/AgenticEngineering
claude
# In interactive mode:
/intake-target-project my-new-project
# ... answer questions ...
/create-project my-new-project
```

`/create-project` will ask you (one question at a time, skipping anything already in the staging):

1. **Project name.**
2. **Template type.** `library`, `pipeline`, `tool-integration`, or `analysis`.
3. **Target directory.** Where the project should be created.
4. **One-line description.**
5. **Git remote.** Optional.
6. **Ticket backend.** `local-markdown` (default) or `github`.

It copies the chosen template, substitutes placeholders, transfers staged content, runs `git init`, and prints next steps.

#### Migration

```bash
cd ~/AgenticEngineering
claude
# In interactive mode:
/intake-target-project my-existing-project
# (the skill will ask for the source repo path and audit it)
# ... answer questions ...
/migrate-project my-existing-project
```

`/migrate-project` walks four phases:

1. **Audit** — diffs the source repo against the staged drafts.
2. **Plan** — proposes a list of moves, renames, additions, conversions, deletions.
3. **Execute** — applies approved changes; transfers everything outside `_warehouse/` into the source repo.
4. **Verify** — orphan sweep, reports remaining manual fixes.

> **Note:** All three skills are interactive. They refuse to run in auto mode.

### Editing skills

Skills are plain folders with a `SKILL.md`. To edit one:

```bash
$EDITOR ~/AgenticEngineering/skills/<skill-name>/SKILL.md
```

Every project that has the skill installed via symlink picks up the edit immediately. To check what's installed where:

```bash
ls -la ~/AgenticEngineering/.claude/skills/
ls -la ~/<some-project>/.claude/skills/
```

To install a skill into a project:

```bash
cd ~/<project>
ln -s ~/AgenticEngineering/skills/<skill-name> .claude/skills/<skill-name>
```

To write a new skill, see [`skills/README.md`](skills/README.md) for the format. Use existing skills (`grill`, `to-prd`, `start-analysis`) as references.

### Editing templates

Templates are project skeletons under `templates/<type>/`. To edit:

```bash
$EDITOR ~/AgenticEngineering/templates/<type>/<file>
```

Edits propagate to **future** projects created from the template; existing projects are not retroactively updated. Use `/migrate-project` to align an old project with new template conventions.

---

## Working in a project (created from a template)

Once you've cold-started a project, your interaction with it works like this:

1. `cd` into the project.
2. Start Claude Code (interactive or auto mode, depending on what you're doing).
3. The agent reads the project's `CLAUDE.md`, finds the docs and skills available, and is ready to work.

You don't have to invoke skills explicitly — describe what you want and the agent picks the matching skill. Or invoke a skill by name (`/grill`, `/diagnose`) when you want to be deliberate.

### Folder cheat-sheet (every project)

```
<project>/
├── CLAUDE.md              # agent's entry — thin index, FIXED + PLACEHOLDER markers
├── README.md              # human-facing entry
├── glossary.md            # ubiquitous-language: one canonical term per concept
├── docs/
│   ├── reference/         # how the code works (one file per module or stage)
│   ├── adr/               # numbered architecture decisions; 3-of-3 admission test
│   ├── domain/            # how the domain behaves (mechanics, anomalies, data model)
│   └── planning/
│       └── future-work.md # open backlog; top of file = next up
├── analysis/              # investigations: YYYY-MM-DD-<kebab-topic>/INVESTIGATION.md
│   └── analysis-landscape.md   # cross-cutting narrative across all INVESTIGATIONs
├── .tickets/
│   ├── <feature>/PRD.md   # written by /to-prd
│   ├── <feature>/issues/  # written by /to-issues
│   └── inbox/             # incoming cross-repo tickets
└── .claude/skills/        # symlinks to ~/AgenticEngineering/skills/<name>
```

The **no-orphan rule** is the spine: every doc must be reachable from `CLAUDE.md` via a chain of links. Each top-level directory has a `README.md` that indexes its contents. The `/finish` skill sweeps for orphans.

### The build chain — for shipping a feature

A sequence of skills you'd run when adding a feature or making a change. Each step is **opt-in** — if you want to skip the chain and just code, that's fine.

```
/grill              align with the agent on what you're building.
                    → asks one question at a time, recommends an answer
                    → updates glossary.md inline as new terms resolve
                    → offers ADRs for hard-to-reverse decisions
   ↓
/to-prd             write the PRD ticket from the conversation context.
                    → no new questions, just synthesises
                    → publishes one ticket with Status: needs-triage
   ↓
/to-issues          break the PRD into vertical-slice tickets.
                    → each ticket cuts end-to-end through every layer
                    → marked AFK (agent can pick up) or HITL (needs human)
                    → quizzes you on the breakdown before publishing
   ↓
/triage             walk tickets through the state machine.
                    → produces durable agent briefs for ready tickets
                    → handles needs-info, wontfix, etc.
   ↓
/work-issue <n>     implement a ready-for-agent ticket.
                    → branches, codes, runs feedback loop
                    → updates affected docs, commits
                    → pauses for confirmation on push/merge/close
   ↓
/finish             cleanup ritual.
                    → sweeps orphan docs, fixes CLAUDE.md drift
                    → verifies no broken links, runs final tests
                    → pauses for push/merge confirmation
```

In practice you'll often skip steps — for a small fix, jump straight to `/work-issue` or just code. For exploratory work that turns into a feature, start with `/grill` and let the chain unfold.

### The analyse chain — for investigations

Used when you're reverse-engineering data, debugging a hairy issue, or running an exploratory study. Independent of the build chain but feeds findings into the same shared docs.

```
/start-analysis <kebab-topic>
                    scaffold a dated investigation directory.
                    → creates analysis/YYYY-MM-DD-<topic>/INVESTIGATION.md (stub)
                    → registers the entry in analysis-landscape.md
                    → forces structure at start so it can't drift
   ↓
(do the work — scripts in the dated dir, outputs/ gitignored, fill in INVESTIGATION)
   ↓
/finish-analysis    finalise.
                    → verifies INVESTIGATION.md has real content
                    → asks whether to promote findings to glossary.md,
                      docs/domain/, docs/adr/, or future-work.md
                    → locks the landscape entry to "complete"
                    → optionally spawns build-chain tickets if findings
                      imply code changes
```

### Cross-cutting skills (use anytime)

- **`/diagnose`** — for hard bugs and performance regressions. The discipline: build a fast deterministic feedback loop *first*, then reproduce, hypothesise, fix, regression-test. Phase 1 (the loop) is most of the value.
- **`/improve-codebase-architecture`** — periodic deepening sweep. Surfaces shallow modules and proposes refactors that hide complexity behind smaller interfaces. Use the deletion test: would deleting this module concentrate complexity?
- **`/zoom-out`** — give me a higher-level explanation of this code in terms of the project's vocabulary.
- **`/check-inbox`** — list incoming cross-repo tickets in `.tickets/inbox/`. Run at session start if your repos talk to each other.

---

## Conventions you should know

These are the rules every skill assumes. If you understand these, the skills make sense; if you don't, they'll feel arbitrary.

### One canonical home per fact

Vocabulary lives in `glossary.md`. Code shape lives in `docs/reference/`. Decisions live in `docs/adr/`. Domain mechanics live in `docs/domain/`. Investigations live in `analysis/<dated>/`. Tickets live in `.tickets/`. **Don't restate facts across docs** — link to the canonical home.

### No orphans

Every doc must be reachable from `CLAUDE.md`. Each top-level directory has a `README.md` that indexes its files. When you add a doc, add it to the index. The `/finish` skill enforces this.

### ADR admission test (3-of-3)

Write an ADR only when **all three** are true:

1. **Hard to reverse** — cost of changing your mind later is meaningful.
2. **Surprising without context** — a future reader will wonder "why this way?"
3. **Result of a real trade-off** — there were genuine alternatives.

Most decisions don't qualify. That's correct.

### Glossary contract

One canonical term per concept. List "Avoid" synonyms explicitly. Use bold term names and show relationships. Keep definitions to one sentence; depth goes in `docs/domain/`. The point: every variable, function, file name, ticket title, and doc paragraph uses the canonical term and not the avoided ones.

### Vertical slices, not horizontal layers

When breaking work, each ticket should cut **end-to-end** (schema + API + UI + tests for that one feature). Don't slice horizontally ("first build all schemas, then all APIs"). Vertical slices give you feedback after each ticket; horizontal slices give no feedback until phase three.

### Tickets are markdown files

By default, tickets live as files in `.tickets/<feature>/`. Status is a `Status:` line at the top. Triage state is one of: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`, `done`. GitHub Issues is opt-in per project.

### The dated-analysis pattern is sacred

Investigations go in `analysis/YYYY-MM-DD-<kebab-topic>/` with a canonical `INVESTIGATION.md`. Every investigation is registered in `analysis-landscape.md` (cross-cutting narrative). Don't dump exploratory work into `scratch/` or unnamed dirs — the structure is what makes the discovery thread durable.

---

## Auto mode

Claude Code's continuous, autonomous mode (`--auto-mode` or equivalent). Skills behave differently in auto vs interactive:

- **Interactive skills** (`grill`, `to-issues`, `triage`, `improve-codebase-architecture`, `intake-target-project`, `create-project`, `migrate-project`) **refuse to run** in auto mode. They print a switch-mode message and exit. They can't do their job without you.
- **Auto-safe skills** (`to-prd`, `start-analysis`, `finish-analysis`, `diagnose`, `zoom-out`, `file-cross-repo-ticket`, `check-inbox`) work in either mode.
- **Mixed-mode skills** (`work-issue`, `finish`) run autonomously for reversible local actions (branch, commit, format, doc updates) but **pause for confirmation** before shared-state actions (push, merge, ticket-close, cross-repo writes). In auto mode without a user, they leave the work in a "ready for confirmation" state.

Use auto mode for long-running or batched work where you can come back later. Use interactive mode when alignment matters.

---

## Cross-repo work

When you're working in repo A and discover that repo B needs a change:

```
/file-cross-repo-ticket ~/path/to/repo-B "Title of the change"
```

It drops a templated ticket into `~/path/to/repo-B/.tickets/inbox/<timestamp>-<slug>.md`. Next time you start a session in repo B, run `/check-inbox` (or just describe what you're doing — the agent should pick it up) and triage it like any other ticket.

No GitHub, no Slack, no auth — just filesystem.

---

## Common gotchas

- **`/grill` looks like it does nothing in auto mode.** It refuses on purpose. Switch to interactive.
- **Skill changes don't take effect.** Check that the skill is symlinked into the project's `.claude/skills/`, not copied. If copied, you have to re-copy after each edit. Symlinks propagate automatically.
- **`/finish` complains about orphans.** A doc exists in `docs/<area>/` but isn't listed in the area's `README.md`. Add it to the index, or delete the doc.
- **CLAUDE.md mentions a module that no longer exists.** `/finish` flags this and asks. The fix is usually to remove the line from CLAUDE.md, but check first whether the module was renamed (in which case update the line).
- **An ADR you wrote doesn't pass 3-of-3 in retrospect.** Delete it. ADRs are sparse on purpose; better to have 5 load-bearing ADRs than 30 forgettable ones.
- **Tickets pile up in `.tickets/inbox/`.** That's the point — they wait for triage. Run `/check-inbox` at session start in repos that talk to each other.

---

## Where to look next

- **Why this exists / mental model** → [`docs/domain/philosophy.md`](docs/domain/philosophy.md).
- **Specific design decisions** → [`docs/adr/`](docs/adr/).
- **Skill inventory with auto-mode behaviour** → [`skills/README.md`](skills/README.md).
- **Template inventory** → [`docs/reference/templates.md`](docs/reference/templates.md).
- **State of the user's existing projects** → [`docs/domain/existing-projects.md`](docs/domain/existing-projects.md).
- **What's still planned** → [`docs/planning/future-work.md`](docs/planning/future-work.md).
- **What we read from outside** → [`docs/domain/external-references.md`](docs/domain/external-references.md).

For agents: read [`CLAUDE.md`](CLAUDE.md).
