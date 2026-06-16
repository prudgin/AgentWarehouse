# Canonical agentic-setup synthesis — survey of this PC

**Date:** 2026-06-12 (started) → 2026-06-12 (last update)
**Status:** in-progress — this-PC survey **and** the internet best-practices survey are complete (see the two `## Findings` sections). Still pending before synthesis: the work-PC survey and the cross-machine merge.

## Question

The long-term goal is to evolve this warehouse into the **single canonical agentic setup** for every project across both the user's machines (this personal PC and a work PC). Before merging anything, we need an honest map of what exists today.

This investigation answers, for **this PC only**:

1. How are agentic / Claude Code setups actually structured across the machine's projects — directory shape, documentation model, decision-log model, ticketing, skills?
2. What does the **philosophy file** present in some projects say, and how many lineages of it exist?
3. How is Claude configured — the **settings stack**, both global (`~/.claude/`) and per-project (`.claude/`)?
4. What is the **scope of this warehouse** (the thing being evolved)?
5. Given all of the above, **what reconciliation decisions** must a unified canonical setup make?

Out of scope here (deliberately deferred): internet best-practice research, the work PC, and the actual synthesis/decision-making. Those are later steps.

## Scope & method

- Enumerated every Claude-touched directory under `/home/prudgin` via `CLAUDE.md` / `AGENTS.md` / `PHILOSOPHY.md` / `.claude/` markers. Found **8 real projects outside the warehouse**, the **warehouse itself**, plus 4 philosophy files. Copies in `Downloads/`, `Trash/`, and a stray `Videos/Screencasts/.claude` were excluded as noise.
- Ran **four parallel `general-purpose` subagents**: (A) PersonalProjects survey, (B) PycharmProjects survey, (C) settings audit — global + per-project, secrets redacted, (D) warehouse scope inventory.
- Read the four philosophy files directly (not via subagent) for fidelity.
- Read-only investigation: no surveyed project was modified. The only writes from this session are this document, its landscape registration, and one `future-work.md` entry.

## Findings

### 0. The cast — what's on this PC

| Project | Path | Type | Agentic tier | Philosophy | Decision log | Tickets | Settings posture |
|---|---|---|---|---|---|---|---|
| **AgentWarehouse** | `PersonalProjects/AgentWarehouse` | project factory | warehouse canon | `docs/domain/philosophy.md` | numbered ADRs (24) | `.tickets/` markdown | allow + curated deny (no bypass) |
| **FamilyBudget** | `PersonalProjects/FamilyBudget` | finance agent (SDK app) | PersonalProjects canon (reference impl) | `PHILOSOPHY.md` (8-principle) | `analysis/decisions.md` (append-only) | `future/tickets/` (+`done/`) | narrow allow + `autoMode` prose grant/hard-deny |
| **IBKRportfolio** | `PersonalProjects/IBKRportfolio` | read-only IBKR companion | PersonalProjects canon (faithful) | `PHILOSOPHY.md` (8-principle, byte-identical) | `analysis/decisions.md` (append-only) | `future/tickets/` (in-place DONE) | `{autoMemoryEnabled:false}` only; MCP in `.claude.json` |
| **YoutubeAI** | `PersonalProjects/YoutubeAI` | 5-phase recommender CLI | outlier (pre-template) | none | none | none | scoped allowlists; **not a git repo** |
| **MercatusDataFeed** | `PycharmProjects/MercatusDataFeed` | aquaculture data pipeline | PycharmProjects canon (source template) | none | `docs/planning/decisions.md` (append-only) | `open-questions.md` OQ-### | `bypassPermissions` + `deny rm -r(f)` |
| **JDP** | `PycharmProjects/JDP` | truck GPS-vs-diary pipeline | PycharmProjects canon (cleanest) | none | `docs/planning/decisions.md` (append-only) | `open-questions.md` + `specs/` | `bypassPermissions` + `deny rm -r(f)` |
| **FishGrowthFittingSGRpackage** | `PycharmProjects/FishGrowthFittingSGRpackage` | installable growth-model lib | PycharmProjects canon | none | `docs/planning/decisions.md` (append-only) | `future-work.md` | `bypassPermissions`; **`.local` contaminated** |
| **FishGrowthDataFitting** | `PycharmProjects/FishGrowthDataFitting` | growth-fitting pipeline | un-agentified | none | none | none | `settings.local.json` allowlist only |
| **WeightSamplesExcelParsing** | `PycharmProjects/WeightSamplesExcelParsing` | one-off Excel→CSV ETL | un-agentified | none | none (inline in README) | none | tiny `settings.local.json` |

**Three observable conventions in the wild, plus outliers.** The single most important finding is that this PC does **not** have one agentic convention — it has three, at different stages of evolution, none of which is universally applied:

1. **Warehouse canon** — the most evolved; only the warehouse and its staged `target-projects/` use it fully.
2. **PersonalProjects canon** — the `PHILOSOPHY.md` three-tenses model (FamilyBudget = reference implementation, IBKRportfolio = faithful instance).
3. **PycharmProjects canon** — a lighter, Mercatus-derived pipeline convention (no philosophy file, no skills).

Outliers: **YoutubeAI** (a fat always-loaded CLAUDE.md, runtime-phase "skills", `archive/`-as-memory, not even version-controlled) and two **un-agentified** projects that have only an accreted `.claude/settings.local.json` permission allowlist.

### 1. Three philosophy lineages (the central finding)

**Lineage A — "Project Philosophy" (`PHILOSOPHY.md`, the `template_agent.md` heritage).** A consultation document (explicitly *not* loaded every session) that defines what a properly-set-up project looks like and how to audit one. Byte-identical 8-principle version in **FamilyBudget** and **IBKRportfolio**; a 7-principle variant (missing only §8) sits at `PersonalProjects/PHILOSOPHY.md` as a shared root copy. The eight principles:

1. **Knowledge and skills are different things** — declarative (`docs/`) physically separated from procedural (`.claude/skills/`).
2. **Single source of truth** — each fact in exactly one document; references are pointers, never copies.
3. **Progressive disclosure, tree-shaped** — `CLAUDE.md` is the root router; documents are *listed*, not imported; no orphans.
4. **The body has a shape; agents preserve it** — same structure/naming/separation every session; philosophy changes are surfaced decisions, not drift.
5. **No drafts, no drawers, no scratch** — no `notes/`/`scratch/`/`findings.md`; working memory lives in the context window; everything written has a home.
6. **Three tenses** — `future/` (work.md, issues.md, tickets/), present (`docs/` + `.claude/skills/`), past (`analysis/` with rolling `landscape.md` + append-only `decisions.md`, mutually linked).
7. **The maintenance skills** — a mandatory **start / work / finish** trio framing enter→do→leave (verification-first, course-correct-early at two corrections, root-cause-not-symptom, subagents for big reads).
8. **Knobs live in one place** — every tunable (timeouts, budgets, model selection, batch sizes…) in one documented home with a `docs/knobs.md` surface; `grep -rn` finds exactly one definition site.

Closing rule (all copies): *where a user request conflicts with a rule, surface it and ask — drift starts the moment a rule is quietly traded.*

**Lineage B — the warehouse philosophy (`docs/domain/philosophy.md`).** The evolution. Frames everything around two LLM constraints — the **smart zone** (~100k usable attention; fix = progressive disclosure + clear between phases) and **no persistent memory** (fix = encode state in the repo). Core ideas: **stigmergy** (the repo as a substrate successive agents mark up; cleanup rituals matter more than start rituals); **library vs skills** as two forms of progressive disclosure; the **two workflow chains** (build: grill→to-prd→to-issues→triage→work-issue→finish; analyse: start-analysis→…→finish-analysis); a third **meta-loop** for setting up projects (intake-target-project → create/migrate-project). It explicitly **rejects** spec-then-code, append-only decision logs (in favour of numbered ADRs with the 3-of-3 test), persistent subagents + ephemeral working-notes (ADR-0007), a standalone `/tdd` skill, plugin packaging, and project knowledge in Claude's auto-memory.

**Lineage C — the PycharmProjects convention (no philosophy file; Mercatus-derived).** Observed, not written down as a philosophy. A `CLAUDE.md` router → `docs/{reference,domain,planning}` triad → **append-only `decisions.md`** (dated `### YYYY-MM-DD — title`, Decision/Rationale/Impact, supersession via in-place strikethrough tombstone) → `open-questions.md` (Mercatus numbers them `OQ-###`) + `specs/` → an ephemeral `.claude/state/working-notes.md` scratchpad. **No `PHILOSOPHY.md`, no three-tenses dirs, no `.claude/skills/`.** MercatusDataFeed is the de-facto source template; JDP and FishGrowthFittingSGRpackage are visibly trimmed clones. Mercatus alone defines `.claude/agents/` subagents (a write-reference-only `codebase-documenter` on Sonnet, and a read-only `architecture-reviewer`).

**Shared DNA across all three:** thin `CLAUDE.md` router + documentation map, single-canonical-home rule, progressive disclosure, no-orphans, `docs/` knowledge separated from status/decisions. They **diverge** on: decision-log model (numbered ADRs + admission test vs log-everything append-only), top-level structure (three-tenses dirs vs glossary+docs+analysis+.tickets), the maintenance model (mandatory start/work/finish trio vs the big build/analyse chains), whether a `PHILOSOPHY.md` exists at all, whether skills exist, the subagent stance, and the memory stance.

### 2. Cohort A — PersonalProjects (detail)

- **FamilyBudget** (most mature anywhere). Full canon: `CLAUDE.md` thin router, `PHILOSOPHY.md`, `docs/` (25+ files incl. `glossary.md` + `knobs.md` with a `scripts/check_knobs.py` lint), `future/` (work/issues/tickets + ~60-ticket `done/` archive), `analysis/` (rolling `landscape.md` + append-only `decisions.md` + dated subdirs). Adds a **third skill axis** — *dev-time* skills (`start`/`work`/`finish` + `eval-review`/`dev-attention`/`deploy`/`trace-review`) vs *runtime* product skills — flagged "must not be blurred." Multi-worktree workflow (start-skill step 0 warns `main` often lives in a sibling worktree). Heaviest settings: an `autoMode` block granting prod-VPS read/write while hard-denying the secrets file.
- **IBKRportfolio** (faithful, younger). Same template; maintenance trio named **`session-start`/`session-work`/`session-finish`** (the naming divergence). Knowledge and skill trees kept **structurally symmetric** (a `reporting` skill fanning to leaf skills mirrors `docs/reporting/` leaf docs). Knobs in a typed `config.py` + `.env`. Uses an `alphavantage` MCP via the deferred-tool/`ToolSearch` pattern (no `.mcp.json`). Has an open ticket wanting to skill-ify a "master-agent + sequential-subagent" workflow.
- **YoutubeAI** (outlier). No philosophy, docs, future, analysis, glossary, tickets — and not a git repo. `CLAUDE.md` is a 122-line **fat always-loaded runtime brief** (mission, phase table, JSON state contract). "Skills" are runtime pipeline phases. Memory = `archive/` snapshots. Carries a **dangling `SPEC.md` pointer** (cited as the source of truth; file does not exist).

### 3. Cohort B — PycharmProjects (detail)

- **Two sharp tiers.** Agentified: **MercatusDataFeed** (flagship, 265-line CLAUDE.md, subagents, systemd deploy, vendor-PDF manuals), **JDP** (cleanest thin router, rich `docs/domain/` + glossary, only project with CI), **FishGrowthFittingSGRpackage** (best doc-discipline; a library so no domain dir). Un-agentified: **FishGrowthDataFitting** and **WeightSamplesExcelParsing** — `settings.local.json` allowlist only, good *human* READMEs but zero canonical scaffolding.
- **Shared canon:** the CLAUDE.md router skeleton, `docs/{reference,domain,planning}` triad with the "knowledge lives in one place" framing repeated verbatim, append-only `decisions.md`, `open-questions.md`, the `working-notes.md` scratchpad, a shared `settings.json`, and a **"Bash command style rules"** section (originated in Mercatus, trimmed copies elsewhere) teaching the agent to dodge hardcoded safety prompts in unattended runs (avoid backslash-before-operators; never `python3 -c` multi-line — write `/tmp/_x.py`, run, `rm`).
- The warehouse's **dated-analysis pattern is absent** in this cohort — Mercatus's `analysis/` is production code; past-investigation knowledge folds into `decisions.md` / `known-anomalies.md` / `open-questions.md`.

### 4. The warehouse (target of evolution)

The warehouse is itself the most-evolved instance of lineage B plus a meta-loop. Scope (from the inventory): **three deliverables** (`templates/`, `skills/`, `references/`); **33 skills** across build chain / analyse chain / cross-cutting / project-lifecycle / power-platform / research / research-overseer / global; **5 templates** (`library`, `pipeline`, `tool-integration`, `analysis`, `research`); **24 ADRs**; a `target-projects/` staging area (**31 dirs**, 26 of them MCA research projects already migrated to a SharePoint-mirrored research template); a `.tickets/` markdown store (6 feature groups, mostly `done`); and one vendored reference (`mattpocock-skills`, the structural inspiration for the skills layer). Only one prior investigation exists (`2026-05-04-template-self-test`), which produced ADRs 0016–0023. Full inventory: [`docs/reference/skills.md`](../../docs/reference/skills.md), [`docs/reference/templates.md`](../../docs/reference/templates.md), [`docs/adr/README.md`](../../docs/adr/README.md), [`target-projects/README.md`](../../target-projects/README.md). The warehouse's own "where this came from" already names the synthesis sources: the user's `template_agent.md` (= lineage A), Matt Pocock's skills, and existing repos (= lineage C). See [`docs/domain/philosophy.md`](../../docs/domain/philosophy.md) and [`docs/domain/existing-projects.md`](../../docs/domain/existing-projects.md).

### 5. The settings stack

- **Global (`~/.claude/`).** `settings.json`: `defaultMode: auto`, `effortLevel: xhigh`, `skipDangerousModePermissionPrompt`/`skipAutoPermissionPrompt`/`skipWorkflowUsageWarning` all true, a `statusLine` showing context %, four official plugins (`pyright-lsp`, `agent-sdk-dev`, `pr-review-toolkit`, `claude-md-management`), and a **`Stop` hook** (`check-paste-lines.py`) that blocks assistant messages containing shell lines ≥60 chars or trailing `\` and reroutes to the global **`user-runs-command`** skill (the only global skill). `settings.local.json` is a 35-entry junk drawer of host-admin one-offs (adb, printer, USB, apt). `~/.claude.json` holds a 20-entry `projects` map (mostly telemetry; `allowedTools` empty everywhere), **no global MCP servers**, and the single per-project MCP (IBKR `alphavantage`, HTTP). The global `CLAUDE.md` carries one rule (AskUserQuestion UI is broken → ask in plain prose).
- **Per-project posture spectrum:** AgentWarehouse (explicit allow + curated deny: force-push, `reset --hard`, sudo, `curl|sh`, recursive rm — no bypass; the "intended" model) → FamilyBudget (narrow allow + `autoMode` prose grant/hard-deny) → accretion allowlists (YoutubeAI, the two un-agentified, Mercatus `.local`) → a **`bypassPermissions` cluster** (JDP, Mercatus, SGRpackage: byte-identical `settings.json`, fenced only by a two-line `deny rm -r(f)`).

### 6. Drift & hygiene observed (catalogued, not fixed)

- **`settings.local.json` contamination:** MercatusDataFeed's pipeline allowlist was pasted wholesale into FishGrowthFittingSGRpackage (which has no such pipeline) — local settings are clone-copied, not curated.
- **Stray nested settings:** `MercatusDataFeed/docs/planning/specs/.claude/settings.local.json` (Claude was run from a subdir and dropped a file).
- **`autoMemoryEnabled: false` set in only 2 of 9** projects (FamilyBudget `.local`, IBKR) despite lineage B's explicit anti-auto-memory stance — almost certainly unintentional inconsistency.
- **YoutubeAI:** dangling `SPEC.md` pointer; not under version control.
- **Maintenance-skill naming:** `start`/`work`/`finish` (FamilyBudget) vs `session-start`/`session-work`/`session-finish` (IBKR).
- **Warehouse stale README lines:** both `analysis/README.md` and `.tickets/README.md` claim "currently empty" while content exists. (`analysis/README.md` line touched by this investigation; `.tickets/` left for `/finish`.)
- **No project-scoped hooks anywhere** — paste-safety is the only hook, and it is global.

## Synthesis seeds — what a unified canonical setup must reconcile

This is the payload for the eventual synthesis (after the internet pass and the work-PC survey). Each is a live decision, not yet made:

1. **Decision-log model.** Numbered ADRs + 3-of-3 admission test (warehouse) vs append-only `decisions.md` (every other agentified project, both lineages A and C). The warehouse already rejected append-only in ADR-0005 — but five real projects use it daily. Reconcile or accept divergence by project type?
2. **Top-level structure.** Lineage A's three-tenses dirs (`future/`, `docs/`+`skills/`, `analysis/`) vs the warehouse's `glossary.md` + `docs/` + `analysis/` + `.tickets/`. Same intent, different folders.
3. **Maintenance model.** Lineage A mandates a `start`/`work`/`finish` trio in *every* project; the warehouse ships big build/analyse chains instead. Decide which is canonical, and normalise the start/work/finish vs session-* naming.
4. **Memory stance.** Standardise `autoMemoryEnabled: false` everywhere and make "repo-as-memory" the rule (already lineage B doctrine; only 2 projects comply). The proposed **"add idea to warehouse" global skill** (see future-work) is the behaviour-change channel that replaces auto-memory.
5. **Knobs-in-one-place (lineage A §8).** A strong convention (`docs/knobs.md` + single grep site) that the warehouse has **not** absorbed into an ADR or template. Candidate to adopt.
6. **Subagents.** Mercatus uses `.claude/agents/` productively; warehouse ADR-0007 rejected persistent subagents. The user's master-agent/sequential-opus orchestration idea (future-work) reopens this. Revisit ADR-0007.
7. **Settings baseline.** Promote the warehouse's curated deny-list to a shared/global base so the bypass-mode cluster inherits real guardrails; decide a deliberate `bypassPermissions` policy; clean contaminated `.local` files; pick one home for MCP (`.mcp.json` vs `.claude.json`); consider standard project-scoped hooks (test/lint gates) — currently unused.
8. **`PHILOSOPHY.md` itself.** Keep a per-project consultation philosophy file (lineage A) or rely on the warehouse philosophy + template `CLAUDE.md` (lineage B)? The two philosophy documents are not yet reconciled into one.
9. **Glossary format.** Table (FamilyBudget) vs bullets (IBKR) vs `### Term` headings (warehouse, ADR-0018). Pick one.
10. **The stragglers.** YoutubeAI (git-init + migrate or accept as an outlier app), the two un-agentified PycharmProjects, and the `existing-projects.md` migration queue all need a place in the unified plan.

## Findings — external best practices (internet survey, 2026-06-12)

Method: surveyed authoritative **primary** sources — Anthropic's official Claude Code docs and engineering blogs, the AGENTS.md spec, the ADR canon (Nygard / adr.github.io / Fowler), and Böckeler/Fowler on spec-driven development — and treated practitioner listicles only as weak corroboration. The aim was to pressure-test the warehouse's conventions and the ten synthesis seeds against the wider field, with an adversarial eye for hype. Each subsection ends with the implication for our seeds.

### A. The warehouse's core bet is current Anthropic doctrine

Anthropic's [context-engineering guidance](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) is almost a restatement of `philosophy.md`: find *"the smallest possible set of high-signal tokens that maximize the likelihood of some desired outcome"*; **context rot** and a finite **attention budget** (the warehouse's "smart zone"); system prompts at the *"right altitude"* (specific enough to guide, flexible enough to give heuristics); **just-in-time retrieval** — *"maintain lightweight identifiers (file paths, stored queries, web links) and use these references to dynamically load data at runtime"* (= the warehouse's CLAUDE.md-indexed library, descend on demand); plus **compaction**, **structured note-taking** (agentic memory outside the window), and **sub-agents returning condensed summaries**. → Validates lineage B broadly; keep it as the canonical base with confidence.

### B. Official CLAUDE.md / memory model is richer than anything used on this PC

The [memory docs](https://code.claude.com/docs/en/memory) confirm and extend our conventions: CLAUDE.md is *"context, not enforced configuration"*; **target under 200 lines** (FamilyBudget at ~74 lines is good; Mercatus 265 and YoutubeAI 122 exceed best practice); be specific/concrete/consistent; four scopes load root→cwd (managed policy → user → project → local). Three mechanisms we don't yet use map directly onto the ODT idea-batch and seed #2:
- **`.claude/rules/`** — one topic per file, optional `paths:` frontmatter for **path-scoped** rules that load only when matching files are touched, user-level rules in `~/.claude/rules/`, and **symlink sharing across projects**. This is the official answer to the future-work "`.claude/rules/` topic files" and "per-directory CLAUDE.md" entries.
- **Nested CLAUDE.md** load on demand when Claude reads files in a subdir (the "per dir/package claude.md" idea — already supported).
- `@path` **imports** (load at launch, don't save context), `claudeMdExcludes` for monorepos, and **HTML comments stripped before injection** — which is exactly the mechanism behind the warehouse's `<!-- TEMPLATE META -->` blocks (ADR-0016-era practice), now confirmed official.

→ Seeds #2 and the rules/nested ideas: adopt `.claude/rules/` for path-scoped conventions; enforce the <200-line router budget in templates; the thin-router CLAUDE.md is already best-practice.

### C. Auto-memory vs repo-as-memory — the field backs the warehouse, with a decisive multi-machine reason

The official docs state plainly that auto-memory is **machine-local, per-repo, and "not shared across machines or cloud environments."** That is the clinching argument for the user's end goal: **auto-memory structurally cannot be the substrate for a cross-machine canonical setup** — only versioned repo content propagates. This validates both setting `autoMemoryEnabled:false` everywhere (seed #4) and the proposed **"add idea to warehouse" skill** as the durable behaviour-change channel. Honest caveat: Anthropic still recommends auto-memory for build commands / debugging insights Claude discovers on its own, so "off everywhere" trades away a real convenience — make it a deliberate choice, with the warehouse-ticket skill + CLAUDE.md as the agreed replacement. → Strong external support for seed #4.

### D. AGENTS.md is now the cross-tool standard (portability angle for the work PC)

[AGENTS.md](https://agents.md/) is stewarded by the Agentic AI Foundation under the Linux Foundation (Anthropic a platinum member), in 60,000+ repos, read natively by Codex/Copilot/Cursor/Windsurf/Devin. Claude Code **does not read AGENTS.md** — the official pattern is a `CLAUDE.md` that does `@AGENTS.md` *or a symlink*. The warehouse already symlinks `AGENTS.md → CLAUDE.md` (ahead of the curve), but the standard's intent is the reverse: **AGENTS.md canonical, tool files importing it**. → New seed: if the work PC or any collaborator uses non-Claude agents, flip the direction (AGENTS.md as the canonical source, CLAUDE.md importing) for true cross-tool portability.

### E. Hooks are the missing enforcement layer

Both the memory and [hooks docs](https://code.claude.com/docs/en/hooks-guide) make the point our prose conventions can't: CLAUDE.md/memory are context, and *"to block an action regardless of what Claude decides, use a PreToolUse hook."* PreToolUse = safety gate (block/allow/confirm); PostToolUse = quality gate (run lint/format/test, feed failures back to the agent). This PC uses **zero project hooks** (only the global paste-line Stop hook), and the `bypassPermissions` cluster has no real guardrail. → Seed #7: adopt standard project hooks — a PostToolUse lint/test gate and a PreToolUse deny for destructive ops — especially for bypass-mode projects. It also lets several lineage-A *prose* rules ("verification first") become *enforced* hooks.

### F. Subagents — the field has moved past ADR-0007's blanket framing

Anthropic's [multi-agent research](https://www.anthropic.com/engineering/built-multi-agent-research-system) reports an Opus-lead + Sonnet-subagent system beating single-Opus by **90.2%** on complex research; subagent best practice is single clear responsibility, scoped tools, structured outputs, used for **parallel investigation** and **context isolation** — with explicit warnings against over-delegating simple/sequential work, and Agent Teams still flagged experimental/expensive. ADR-0007 rejected persistent subagent *definitions* (maintenance cost in auto mode), not subagent *use* — but Mercatus already runs `.claude/agents/` productively, and the user wants master-agent orchestration. This very investigation used four subagents. → Seed #6: revisit/partly supersede ADR-0007, distinguishing "defined subagents for recurring read-heavy roles" (now justified) from "subagents for everything" (still not).

### G. Decision logs — ADRs are the canon; "log everything" is the documented anti-pattern

The ADR canon ([adr.github.io](https://adr.github.io/), [Fowler](https://martinfowler.com/bliki/ArchitectureDecisionRecord.html)): one decision per record, **only architecturally-significant** ones (*"daily operational calls don't need documentation"*), Context/Decision/Consequences, in-repo, lightweight markdown. This supports the warehouse's numbered-ADR + 3-of-3 test over the append-only `decisions.md` the five other agentified projects use — those logs capture operational calls too (what the canon warns against), though they mitigate with strikethrough-tombstone supersession. Honest counter: append-only is lower-friction and the projects sustain it daily. → Seed #1: keep numbered ADRs canonical, but consider *absorbing the good part* — allow a separate lightweight append-only **operational log / changelog** for non-architectural calls, kept distinct from ADRs so it doesn't dilute the admission test.

### H. Spec-driven development — the warehouse's rejection holds up

2026's SDD tools dominate by stars (spec-kit ~93k, BMAD ~46k, AWS Kiro), but [Böckeler/Fowler](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html) land the critique: uniform workflows unsuited to varying problem sizes (a small bug fix → *"4 user stories with 16 acceptance criteria"*), *"I'd rather review code than all these markdown files,"* and a parallel to failed Model-Driven Development — *"inflexibility and non-determinism,"* the worst of both worlds. ADR-0006 (no specs/roadmap; PRDs are short tickets) is well-aligned. Note the warehouse's `/grill → /to-prd → /to-issues` is itself the lightweight middle ground the critics gesture toward. → No change; keep rejecting heavyweight SDD.

### I. Cross-machine config sync — the concrete enabling mechanism for the end goal

Practitioner consensus (e.g. [claude-code-dotfiles](https://github.com/elizabethfuentes12/claude-code-dotfiles), chezmoi guides): version-control `~/.claude` as **dotfiles**; sync via git or chezmoi; **encrypt secrets** (age/chezmoi); keep machine-specific values (paths, tokens, MCP) in `settings.local.json`/env and shared scope in `settings.json`. The warehouse standardises the per-**project** canon, but the **global** layer (`~/.claude/`: global CLAUDE.md, global skills like `user-runs-command`, the paste-line hook, `settings.json`, plugins) is currently **unversioned and machine-bound** on this PC. → **New, arguably top-priority seed:** bring the global `~/.claude` layer under version control (a dotfiles repo, or have the warehouse own/install it) so the canonical setup spans *global + per-project* across both machines. This is the enabling step for the eventual merge.

### J. Knobs and ubiquitous language — low-controversy, adopt

Knobs-in-one-place (PHILOSOPHY §8) is standard config-management / 12-factor hygiene; absorb it into the warehouse templates (a `docs/knobs.md` convention). Glossary / ubiquitous-language (warehouse + JDP + Mercatus already do it; = the mattpocock "ubiquitous-language contract" and DDD) is uncontroversial. → Seeds #5 and #9: adopt knobs into templates; standardise the glossary on `### Term` headings (ADR-0018) for deep-link integrity.

### Adversarial notes (where "best practice" is thin or contested)

- Most "2026 best practices" hits are SEO Medium/DEV churn; load-bearing claims here rest on primary sources (Anthropic docs/blogs, agents.md, Fowler), with listicles as weak corroboration only.
- The "100–150 instruction slots" / "80–120 line" figures are practitioner folklore; the official doc only says **"under 200 lines"** and "no guarantee of strict compliance." Treat line budgets as soft.
- The **90.2%** multi-agent figure is from one Anthropic *research-domain* task — do not over-generalise it to coding.
- **Agent Teams** are experimental and token-expensive; do not build the canonical setup on them yet (defined subagents, yes; teams, not yet).

### Net effect on the synthesis seeds

| # | Seed | External verdict |
|---|---|---|
| 1 | ADRs vs append-only log | **Adjust** — keep ADRs canonical; add a separate lightweight operational log for non-architectural calls |
| 2 | Three-tenses vs warehouse layout | **Validated + extend** — adopt `.claude/rules/` (path-scoped) and the <200-line router budget |
| 3 | Maintenance trio vs chains | Open — no strong external signal; decide internally (chains are the richer model) |
| 4 | Memory stance | **Strongly validated** — auto-memory is machine-local; repo-as-memory + warehouse-ticket skill is the only cross-machine substrate |
| 5 | Knobs-in-one-place | **Validated** — adopt into templates |
| 6 | Subagents (ADR-0007) | **Adjust** — defined, scoped subagents are now justified; partly supersede 0007 |
| 7 | Settings baseline | **Validated + extend** — promote curated deny-list; **add hooks** as the enforcement layer |
| 8 | PHILOSOPHY.md itself | Reconcile internally into one philosophy (lineage A + B); no external blocker |
| 9 | Glossary format | **Validated** — `### Term` headings |
| 10 | Stragglers / migration | Unchanged — proceed via existing migration queue |
| 11 (new) | Cross-tool portability | **Consider** — AGENTS.md as canonical, CLAUDE.md importing, if non-Claude tools are in play |
| 12 (new) | Global `~/.claude` under version control | **New top priority** — the enabling step for a multi-machine canonical setup |

## Open ends / next steps

- **Internet best-practices survey** — ✅ complete (section above).
- **Work-PC survey** — a future investigation (same four-subagent method), then a cross-machine merge of the two surveys.
- **Synthesis** — once the work-PC survey lands, run `/finish-analysis` to promote the synthesis seeds into ADRs / `docs/domain/` / template changes: most likely a reconciled single philosophy (A+B), `.claude/rules/` + hooks adopted into templates, ADR-0007 partly superseded (defined subagents), a lightweight operational-log convention alongside ADRs, and — the enabling move — bringing the global `~/.claude` layer under warehouse-managed version control so the canonical setup spans global + per-project across both machines.
