# Future Work

Open backlog for the warehouse itself. Top of file = next up. As work ships, the entry moves out: structure goes into `templates/` / `skills/` / `docs/`; rationale (if it passes 3-of-3) becomes an ADR.

See [`README.md`](README.md) for the boundary rule (vs. `.tickets/`), the entry format, and the four `**Type:**` values.

## Migrations queued

The most important next steps once the warehouse is in use. Each one starts with `/intake-target-project <name>` (stages decisions in `target-projects/<name>/`) followed by `/migrate-project <name>` for execution.

### Migrate `FishGrowthFittingSGRpackage`

**What:** intake and migrate the FishGrowthFittingSGRpackage onto the library-template conventions.
**Type:** proposal
**Why:** second migration target. Lowest distance from the library template; clean validation of `/migrate-project` end-to-end.
**Open questions:** none material.
**Links:** `docs/domain/existing-projects.md`.

### Migrate `MercatusDataFeed`

**What:** intake and migrate MercatusDataFeed onto the pipeline-template conventions, converting append-only `decisions.md` into ADRs.
**Type:** proposal
**Why:** third migration target. Biggest payoff; validates the `pipeline/` template variant and the `decisions.md` → ADRs conversion.
**Open questions:** does the `decisions.md` → ADRs split need interactive confirmation per entry, or can it be batched?
**Links:** `docs/domain/existing-projects.md`.

### Cold-start `GrowthModels` and `PowerBI`

**What:** when the user activates these projects, cold-start with `/intake-target-project` then `/create-project`.
**Type:** watching
**Why:** not yet ready to start; waiting on user activation. Held here so the migration queue stays complete.
**Open questions:** which template variant fits each — likely `research/` for `GrowthModels` (if it gets a SharePoint folder) or `analysis/` (if local-only), and `tool-integration/` for `PowerBI`. TBD at intake time.
**Links:** `docs/domain/existing-projects.md`.

## Skills to refine

All the skills listed in `skills/README.md` are written but unproven. Each should be exercised on real work and tightened based on what shakes out.

### `grill` — verify inline glossary update mechanic

**What:** watch whether the inline `glossary.md` update mechanic actually fires mid-conversation, or whether the agent batches updates to the end.
**Type:** refinement-candidate
**Why:** the skill is built on the assumption of inline glossary writes during the interview; if that assumption fails, the skill body needs sharpening.
**Open questions:** what's the right corrective if batching is observed — stronger imperative phrasing, or a hard stop-and-write checkpoint?
**Links:** `skills/grill/SKILL.md`.

### `work-issue` — validate the auto-vs-interactive split

**What:** validate that the auto-for-reversible / confirm-for-shared-state / stop-for-inconsistency categories are the right ones.
**Type:** refinement-candidate
**Why:** the split is a hypothesis — real use will reveal whether the categories carve at the right joints.
**Open questions:** what does the resumption flow look like when `work-issue` stops in auto mode — re-enter `/work-issue`, or `/finish`?
**Links:** `skills/work-issue/SKILL.md`.

### `finish` — orphan-sweep mechanics under load

**What:** watch whether the orphan-sweep script (extracted in trade-off 02) holds up across more projects, or needs further tightening.
**Type:** refinement-candidate
**Why:** the script is now in place, but its derivation logic (parse CLAUDE.md doc-map, list `*.md`, substring-match in README) hasn't been exercised across many CLAUDE.md shapes.
**Open questions:** does the substring match produce false positives on common filenames? Does the doc-map parser handle every shape we care about?
**Links:** `skills/finish/SKILL.md`, `skills/finish/scripts/check-docs.sh`.

### `intake-target-project` — first real exercise on GutEvac

**What:** watch how the intake flow behaves on GutEvac: does inline staging-write actually fire mid-conversation? Does the migration plan in `_warehouse/migration-plan.md` end up actionable for `/migrate-project`, or does it need re-grilling at execution time?
**Type:** refinement-candidate
**Why:** the skill is built around a hypothesis (intake stages everything `/migrate-project` needs); first real run will validate or invalidate.
**Open questions:** is `_warehouse/migration-plan.md` the right artifact, or should it be split per topic?
**Links:** `skills/intake-target-project/SKILL.md`.

### `migrate-project` — `decisions.md` → ADRs conversion

**What:** validate that the `decisions.md` → ADRs conversion logic is the right shape. Likely needs interactive confirmation per entry. Also: does the staging-transfer step compose cleanly with the existing audit logic?
**Type:** refinement-candidate
**Why:** trickiest part of the migration flow; first real exercise will be MercatusDataFeed.
**Open questions:** batch confirmation vs per-entry; how to handle decisions that don't pass the 3-of-3 admission test.
**Links:** `skills/migrate-project/SKILL.md`.

### `finish-analysis` — cross-doc promotion logic

**What:** watch the cross-doc promotion logic (REPORT findings → glossary / domain / ADR / future-work). May need separate sub-skills per destination if heuristics get complex.
**Type:** refinement-candidate
**Why:** the promotion step is per-finding judgment; if it's heavy enough to merit a sub-skill split, that wants discovering early.
**Open questions:** does the heuristic-per-destination approach scale, or does it want a single decision tree?
**Links:** `skills/finish-analysis/SKILL.md`.

## Templates to refine

Templates exist for `library`, `pipeline`, `tool-integration`, `analysis` — all unproven on real cold-start work.

### `pipeline/` — over-rigidity risk

**What:** watch whether the "Pipeline areas" table in CLAUDE.md and the "one file per stage" reference convention hold up beyond MercatusDataFeed, or are over-rigid for simpler pipelines.
**Type:** refinement-candidate
**Why:** the conventions are tuned to one project; they may not generalise.
**Open questions:** at what pipeline size does the table become noise rather than signal?
**Links:** `templates/pipeline/CLAUDE.md`.

### `tool-integration/` — optional `docs/reference/`

**What:** watch whether dropping `docs/reference/` to optional is the right call, or whether tool-integration projects accumulate enough first-party code (e.g. CLI on top of the wrapped tools) to need it reinstated by default.
**Type:** refinement-candidate
**Why:** trade-off 07 may sharpen this; first real exercise on MicrosoftFlowsApps will tell.
**Open questions:** is "optional" the right framing, or should the template install an empty `docs/reference/README.md` and the project decides whether to fill it?
**Links:** `templates/tool-integration/CLAUDE.md`.

### `analysis/` — findings-provenance and content split

**What:** watch whether the "findings provenance" rule (every glossary/domain/ADR claim links a REPORT) holds up in practice, or becomes ceremony. Verify the ADR-0007 split (caveats → `known-issues.md`, priorities → `future-work.md`, methodology → ADRs) absorbs legacy `working_notes_for_future_runs.txt` content cleanly. Check whether optional `docs/reference/` is the right call for research projects.
**Type:** refinement-candidate
**Why:** all three conventions are unproven; first real test on GutEvac.
**Open questions:** which content category, if any, falls through the ADR-0007 split?
**Links:** `templates/analysis/CLAUDE.md`.

### `research/` — first exercise on GutEvac, plus the synced-surface convention

**What:** validate the `research/` template end-to-end on the GutEvac migration. Specifically: do the five synced surface dirs (`Articles/`, `Proposal/`, `Data/`, `Reports/`, `Expenses/`) hold up when populated from a real project; does mirroring agent infrastructure (CLAUDE.md, glossary.md, docs/, .tickets/, analysis/) to SharePoint actually pay off (someone plugging the SharePoint folder into another agent gets full context); does the `.rclone-filter` shipped with the template need additions after first push (e.g. `analysis/*/outputs/`, large `Data/` files).
**Type:** refinement-candidate
**Why:** first concrete exercise of [ADR-0024](../adr/0024-research-template-bidirectional-sharepoint-mirror.md). Some choices were made on principle (symmetric mirror, no two-surface design) and need a real project to confirm.
**Open questions:** does `Expenses/` syncing turn out to be a leak risk (financial information on SharePoint vs. local-only)? Does anyone actually open the SharePoint copy of `analysis/` or is that overkill?
**Links:** `templates/research/`, [ADR-0024](../adr/0024-research-template-bidirectional-sharepoint-mirror.md).

### `sharepoint-sync` — exercise the never-deletes-never-renames model

**What:** watch whether the "deletes are explicit on both sides, renames produce duplicates" model is workable in practice, or whether it produces enough drift that we need a periodic cleanup pass. Specifically: how often does the user actually need to delete or rename a file, and how badly does the friction bite. Possible refinements: a `/sharepoint-sync diff-deletions` reporter, or a sanctioned "delete on both sides" subcommand with explicit confirmation.
**Type:** refinement-candidate
**Why:** the never-deletes design is conservative on purpose, but the friction cost is unmeasured. First real exercise on GutEvac will start producing evidence.
**Open questions:** does the user accumulate stale files faster than they tolerate? Are there file types that need exclusion-on-rename (e.g. Word's `~$file.docx` lock files — confirm filter handles them)?
**Links:** `skills/sharepoint-sync/SKILL.md`, [ADR-0024](../adr/0024-research-template-bidirectional-sharepoint-mirror.md).

## Open questions

### Skill location for global skills

**What:** decide whether globally-applicable skills (e.g. `sudo-script`) live in `~/.claude/skills/` (per-user) or as per-project copies.
**Type:** open-question
**Why:** per-user is cleaner; per-project guarantees portability if the user moves machines. Currently `sudo-script` is documented as `~/.claude/skills/sudo-script/`; the user must symlink manually.
**Open questions:** what triggers a flip — second machine, sharing with another user, or never?
**Links:** `skills/sudo-script/`.

### Plugin packaging revisited

**What:** reconsider plain-folders-no-plugin trade-off when the user-base grows beyond solo use.
**Type:** open-question
**Why:** at sufficient scale (other users, shareable distribution) the trade-off in [ADR-0012](../adr/0012-plain-folders-no-plugin.md) flips. Currently solo use; plain folders are correct.
**Open questions:** what's the threshold — second user, third user, public release?
**Links:** [ADR-0012](../adr/0012-plain-folders-no-plugin.md).

### `work-issue` resumption in auto mode

**What:** specify the resumption flow when `/work-issue` stops in auto mode at a shared-state boundary ("stop and surface, leave the branch").
**Type:** open-question
**Why:** on the user's return, what's the resumption skill — `/work-issue` again, or `/finish`? Currently underspecified.
**Open questions:** does the choice depend on what the stop reason was, or is one resumption skill always right?
**Links:** `skills/work-issue/SKILL.md`.

## Captured ideas (from `agent ideas.odt`)

Brain-dump seeds, sharpened into entries on 2026-06-12 and tagged per [ADR-0021](../adr/0021-future-work-entries-carry-type-tag.md). Unsorted relative to the curated queues above — graduate, split, or distribute into the sections above as each firms up.

### Worktree isolation and scope for agent work

**What:** start agent work on a fresh git worktree, never touching other trees; keep the worktree path inside the repo; scope each worktree's file access so an agent only sees and edits its slice.
**Type:** proposal
**Why:** parallel and AFK agents that share one working tree clobber each other; isolated worktrees plus scoped file access make concurrent work safe and reviewable.
**Open questions:** which skill owns this — `work-issue` at branch time, or a new `/worktree` primitive? how is "scope file access" enforced — settings deny-list, prompt convention, or harness flag?
**Links:** `skills/work-issue/SKILL.md`.

### Per-directory / per-package `CLAUDE.md`

**What:** support nested `CLAUDE.md` files scoped to a directory or package, not just the repo root.
**Type:** open-question
**Why:** large repos carry subsystem-local conventions that don't belong in the root file; nesting keeps guidance next to the code it governs.
**Open questions:** does this collide with the "no orphans / one canonical home" rule? how do nested files compose with the root — override, append, or scope-limited?
**Links:** `CLAUDE.md`.

### Restrict what agents read — `permissions.deny` and `.ignore`

**What:** use `permissions.deny` in `.claude/settings.local.json` to skip reading designated files, and `.ignore` files to exclude generated output, build artifacts, and third-party code from agent attention.
**Type:** proposal
**Why:** smaller, cleaner context — agents waste budget and get misled reading vendored or generated code.
**Open questions:** ship a default `.ignore` and deny-list in the templates? which paths are safe defaults across project types?
**Links:** `templates/`.

### `.claude/rules/` topic files and path-specific rules

**What:** adopt per-topic rule files under `.claude/rules/` (one topic per file, e.g. `testing.md`, `api-design.md`) plus path-specific rules that apply only under matching paths.
**Type:** open-question
**Why:** finer-grained, composable guidance than a single CLAUDE.md; rules attach to the area they govern.
**Open questions:** how does `.claude/rules/` relate to the warehouse's existing CLAUDE.md + docs conventions — replace, supplement, or redundant? does path-specific scoping overlap with per-directory `CLAUDE.md` above?
**Links:** `CLAUDE.md`.

### Memory off by default (`autoMemoryEnabled: false`)

**What:** decide whether warehouse and template settings should set `{"autoMemoryEnabled": false}`.
**Type:** open-question
**Why:** auto-memory may capture noise or conflict with the warehouse's explicit "one canonical home per fact" doc discipline.
**Open questions:** is durable knowledge better served by the docs/ADR system than by auto-memory? off globally, or per-template?
**Links:** `templates/`.

### Code-intelligence plugins

**What:** watch the code-intelligence plugin space (LSP-style symbol and reference tooling for agents).
**Type:** watching
**Why:** could sharpen navigation and refactor skills, but not actionable until a concrete tool is chosen.
**Open questions:** which plugin, and does it earn its keep over plain search?
**Links:** none yet.

### `/explain` skill — or plugin?

**What:** an `/explain` capability that gives a high-level explanation of code; decide skill vs plugin packaging.
**Type:** open-question
**Why:** overlaps the existing `/zoom-out` skill ("higher-level explanation in the project's vocabulary") — may be a rename, a superset, or genuinely distinct.
**Open questions:** how does `/explain` differ from `/zoom-out`? if it's the same, fold in; if distinct, what's the boundary? skill or plugin?
**Links:** `skills/zoom-out/SKILL.md`.

### Deep vs shallow modules — keep reinforcing

**What:** keep the deep-module / shallow-module distinction front-and-centre in architecture work.
**Type:** refinement-candidate
**Why:** already embodied in `/improve-codebase-architecture`; this is a reminder to keep the deletion-test framing sharp as the skill gets real use.
**Open questions:** is the principle surfaced strongly enough in the skill, or does it want its own reference doc?
**Links:** `skills/improve-codebase-architecture/SKILL.md`.

### Auto push + merge on `/finish` — confirm behaviour

**What:** confirm the auto push+merge path fires correctly when `/finish` is called.
**Type:** refinement-candidate
**Why:** `/finish` already ships, pushes, and merges; this is a watch-in-practice item, not a new build.
**Open questions:** does the push/merge step behave under the mixed-mode auto/confirm split, or surprise the user?
**Links:** `skills/finish/SKILL.md`.

### Multi-agent orchestration and context handoff

**What:** an orchestration model with (a) tickets executed as sequential Opus runs, (b) a master/orchestrator agent role holding a protected context window, and (c) a `handoff-compact-rehydrate` flow to carry state across context boundaries.
**Type:** proposal
**Why:** lets long or large work span many agent runs without losing the thread — the master agent keeps the through-line while workers churn.
**Open questions:** what does the master's "protected window" actually pin? is handoff-compact-rehydrate a skill, a harness feature, or both? how do sequential-opus tickets relate to the existing `.tickets/` + `work-issue` flow?
**Links:** `skills/work-issue/SKILL.md`.

### Skill: report on doc/skill health for the next agent

**What:** a skill that emits feedback on the current state of docs and skills — what can be improved, what's broken, and what gotchas must be documented to make the next agent's life easier.
**Type:** proposal
**Why:** closes the warehouse's self-improvement loop; each session leaves the system a little more legible for the next.
**Open questions:** where does the output land — `future-work.md`, a dedicated doc, or a ticket? how does it avoid overlapping `/finish`'s orphan-sweep and CLAUDE.md-drift checks?
**Links:** `skills/finish/SKILL.md`.

## From the canonical-setup synthesis (2026-06-12)

Ideas surfaced while surveying this PC's agentic setups. See [`analysis/2026-06-12-canonical-setup-synthesis/INVESTIGATION.md`](../../analysis/2026-06-12-canonical-setup-synthesis/INVESTIGATION.md).

### Global skill: "add idea to warehouse" (the behaviour-change channel)

**What:** a machine-wide skill (installed in `~/.claude/skills/`, pinned to target this warehouse) that, from inside ANY project or session, files a ticket into the warehouse's `.tickets/inbox/` proposing a new warehouse feature or a change to an existing one. When the user — or the agent — thinks "the warehouse should do X" mid-work, one skill call lands the request without leaving the current project. Two modes: (a) user-invoked ("add idea to warehouse: …"); (b) an agent-side hook/skill that proactively *suggests* filing a warehouse ticket when it notices a recurring friction or a convention gap. Builds directly on the existing `/file-cross-repo-ticket` (drop into another repo's `.tickets/inbox/`) and `/check-inbox` primitives — this is a global, warehouse-pinned specialisation of them.
**Type:** proposal
**Why:** the user wants to switch OFF Claude's machine-wide and project-wide auto-memory, but still let agents influence future behaviour. This skill is the durable, versioned substitute: instead of an invisible per-machine memory file, a behaviour-change request becomes a reviewable warehouse ticket that propagates to every machine via git. Extends the warehouse's existing "project facts go in the repo, not auto-memory" stance ([`philosophy.md`](../domain/philosophy.md), "What we deliberately reject") to cross-project and agent-suggested change.
**Open questions:** target `.tickets/inbox/` (triage-gated) or straight into `future-work.md`? how does a global skill resolve the warehouse path on each machine — config file, env var, or a well-known location? what's the proactive-suggestion trigger, and does it need a hook (PostToolUse / Stop) rather than a skill? with auto-memory off globally, is there anything genuinely user-personal this channel doesn't recover, and where does that go instead?
**Links:** `skills/file-cross-repo-ticket/SKILL.md`, `skills/check-inbox/SKILL.md`, [`analysis/2026-06-12-canonical-setup-synthesis/INVESTIGATION.md`](../../analysis/2026-06-12-canonical-setup-synthesis/INVESTIGATION.md).
