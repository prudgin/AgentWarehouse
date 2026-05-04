---
name: intake-target-project
description: Warehouse-only intake interview for a target project being cold-started or migrated. Walks the design tree one question at a time, recommending an answer for each. Stages decisions in target-projects/<name>/ — glossary entries, ADR drafts, domain docs — so /create-project or /migrate-project can transfer them into the target repo. Use from inside the AgenticEngineering warehouse when the user wants to "set up project X", "intake project X", "start the migration of X", or "let's design project X before scaffolding". Distinct from /grill, which runs inside an already-set-up project. Interactive — refuses auto mode.
---

# Intake Target Project

The warehouse's grilling skill for a project it is setting up. Interviews the user about the target project, stages decisions in `target-projects/<name>/`, and hands off to `/create-project` or `/migrate-project` for execution.

This is **not** `/grill`. `/grill` runs inside an already-set-up project and writes to that project's `glossary.md` and `docs/adr/`. `/intake-target-project` runs inside the warehouse and writes to staging — the project's eventual files don't exist yet (or, in migration cases, the project lacks the warehouse shape). See [ADR-0014](../../docs/adr/0014-warehouse-grill-vs-project-grill.md) for why these are separate.

## Refuse auto mode

If auto mode is active (look for "Auto mode is active" or equivalent in system reminders), stop immediately and respond:

> This skill is interactive — it asks one question at a time and waits for your answer. Please switch to interactive mode and re-invoke `/intake-target-project`.

Do nothing else. Do not proceed.

## Refuse outside the warehouse

This skill writes into `target-projects/<name>/` relative to the AgenticEngineering warehouse root. Verify by checking that `templates/library/CLAUDE.md` exists relative to the cwd. If not, respond:

> `/intake-target-project` runs from inside the AgenticEngineering warehouse. Please `cd` to the warehouse and re-invoke.

## Process

### 1. Anchor the session

Ask: **"What project are we setting up, and is it a cold-start or a migration?"**

Get a one-sentence anchor from the user. Echo it back: "I read this as ___ — is that right?"

If the skill was invoked with an argument (e.g. `/intake-target-project gutevac` or `/intake-target-project migrate ~/PycharmProjects/GutEvac`), use that as the anchor and confirm.

### 2. Resolve the target name and resume vs. start

The target name is a kebab-cased identifier — used as the staging dir name `target-projects/<name>/`. Recommend a name based on the user's anchor; confirm.

Check whether `target-projects/<name>/` already exists:

- **Exists**: read `_warehouse/status.md` and `_warehouse/intake-notes.md`. Tell the user where the previous session left off and ask whether to resume or start fresh.
- **Does not exist**: create the staging skeleton (see Step 3).

### 3. Initialise staging skeleton

Create:

```
target-projects/<name>/
├── _warehouse/
│   ├── status.md          # status: open, started: <date>, mode: cold-start | migration
│   ├── intake-notes.md    # empty header
│   └── migration-plan.md  # empty header
├── README.md              # placeholder one-liner
├── glossary.md            # empty stub with the warehouse glossary contract reminder
└── docs/
    ├── adr/               # empty
    ├── domain/            # empty
    └── planning/          # empty
```

For a **migration** target, also record the source repo path in `_warehouse/status.md` so subsequent migration steps know where to look.

Don't create `CLAUDE.md` yet — it gets composed near the end once the design tree is walked.

### 4. Audit existing material (migration only)

For a migration, the source repo likely already has a CLAUDE.md, docs, scripts, decision logs, working notes, etc. Read them:

- `CLAUDE.md`, `README.md`, `glossary.md` (if present)
- `docs/` tree
- Existing decision logs (`decisions.md`, `docs/adr/`)
- Working notes (`.claude/state/working-notes.md`, ad-hoc `.txt` files)
- Major code modules — enough to ground questions, not exhaustive

This audit is the seed for grilling: known facts don't need re-asking, fuzzy areas do. Note in `_warehouse/intake-notes.md` what was found.

For a **cold-start**, skip this — there's nothing to read.

### 5. Walk the design tree

Ask **one question at a time**. For each question:

- Be specific. Not "what's this for?" but "is this a research project where the analysis script is the product, or a tool/library that ships?"
- Provide a **recommended answer** with a one-line reason.
- Wait for the user's response before continuing.

Branches typical for an intake (not a checklist — branch as the conversation requires):

- **Project shape**: research project (analyse-chain dominant) vs. shippable artefact (build-chain dominant) vs. tool/integration?
- **Template variant**: `library` (package with public API), `pipeline` (multi-stage data pipeline), `tool-integration` (wrapper around an external platform), `analysis` (research project where REPORTs are the deliverable), or custom mix? If the project's primary loop is "collect data → analyse → write up findings", default to `analysis`.
- **Code locus**: where does code live — root scripts, `src/<package>/`, `notebooks/`, etc.?
- **Data conventions** (for research/pipeline projects): where does raw data live, how does it accumulate, what's gitignored?
- **Knowledge that should become glossary entries**: domain vocabulary unique to this project.
- **Decisions that should become ADRs**: design choices that pass the 3-of-3 admission test.
- **Future-work seeds**: known follow-ups, deferred items.
- **Migration-specific**: what existing files survive, what gets archived, what gets deleted?

Resolve dependencies before moving on (template variant before code locus, etc.).

Stop walking when the user signals alignment.

### 6. Inline staging writes

During the conversation:

- **Glossary entries** → write to `target-projects/<name>/glossary.md` as terms resolve. Follow the warehouse glossary contract (canonical term, "Avoid" synonyms, one-sentence definition, relationships, example dialogue, flagged ambiguities).
- **ADRs** → when a decision passes the 3-of-3 admission test (hard to reverse, surprising without context, real trade-off), draft `target-projects/<name>/docs/adr/NNNN-slug.md`. Use sequential numbering starting at 0001 for cold-starts; for migrations starting from an existing `docs/adr/`, continue from the highest existing number (record the renumbering plan in `_warehouse/migration-plan.md`).
- **Domain docs** → for non-vocabulary domain knowledge that's too long for the glossary (model mechanics, data shape, anomalies), draft `target-projects/<name>/docs/domain/<topic>.md`.
- **Future-work seeds** → append to `target-projects/<name>/docs/planning/future-work.md`.
- **Raw notes** → keep `_warehouse/intake-notes.md` in sync with the conversation. Include the exact user phrasing for fuzzy or unresolved branches.

Don't batch — write as decisions resolve. Mid-conversation writes ensure the work survives a session crash.

### 7. Compose CLAUDE.md draft

Near the end of the session, compose `target-projects/<name>/CLAUDE.md` from the resolved decisions:

- Title and one-paragraph "what / why" summary.
- Documentation map referencing the staged docs.
- Skills section listing which skills to install in the target.
- Update rules (carry the warehouse default).
- Portability note (AGENTS.md symlink).

Show it to the user for review before saving.

### 8. Compose migration plan

Write `_warehouse/migration-plan.md` as a concrete step list for `/create-project` or `/migrate-project`:

- For **cold-start**: which template, target directory, ticket backend, git remote, post-scaffold edits.
- For **migration**: per-item moves/renames/conversions/deletes against the source repo, in the format the migrate-project skill expects in its Phase 2.

The plan is the executable handoff. The next skill should be able to run it without re-asking the user.

### 9. Wrap up

When the user signals alignment, summarise:

- **Target**: name, mode (cold-start/migration), source path if applicable.
- **Staged content**: counts of glossary entries, ADRs, domain docs, future-work items.
- **Migration plan**: ready / partial / blocked.
- **Open ends**: anything explicitly left unresolved (with one-line reason).

Mark `_warehouse/status.md` as `ready-for-transfer` (or `partial` if open ends remain).

Suggest the next step:

> Next: `/migrate-project <name>` — or `/create-project <name>` for a cold-start. Both will read `target-projects/<name>/` and execute the migration plan.

## What this skill does NOT do

- Does not write files into the target repo. Only into `target-projects/<name>/` inside the warehouse.
- Does not invoke `/migrate-project` or `/create-project` — leaves that for the user to invoke deliberately.
- Does not modify the warehouse's own `glossary.md`, `docs/adr/`, etc. (Use `/grill` from inside the warehouse if you're designing the warehouse itself.)
- Does not bundle multiple questions into one turn — one question, then wait.
- Does not run in auto mode. See [ADR-0011](../../docs/adr/0011-interactive-skills-refuse-auto-mode.md).

## Notes for the agent

- This is an **alignment** session, not a planning session. The output is shared understanding plus a staged set of files; the executable plan is a side product, not the goal.
- The 3-of-3 admission test is strict. Most decisions don't qualify as ADRs — they belong in the migration plan or in domain docs. Keep `docs/adr/` sparse.
- For migrations, prefer adopting decisions already encoded in the source repo's spec / notes rather than re-deriving them. Surface them, sanity-check with the user, file them.
- If a question can be answered by reading the source repo (for migrations) or the warehouse template (for cold-starts), read instead of asking.
- Don't ask "is there anything else?" at the end — the user will tell you.
