# Future Work

Open backlog for the warehouse itself. Top of file = next up. As work ships, the entry moves out: structure goes into `templates/` / `skills/` / `docs/`; rationale (if it passes 3-of-3) becomes an ADR.

See [`README.md`](README.md) for the boundary rule (vs. `.tickets/`) and the entry format.

## Migrations queued

The most important next steps once the warehouse is in use. Each one starts with `/intake-target-project <name>` (stages decisions in `target-projects/<name>/`) followed by `/migrate-project <name>` for execution. In order:

1. **`GutEvac`** — active research project (Murray cod gut clearance). Has a detailed implementation spec, working notes with known issues, and a stage-1 proposal that diverged. First real exercise of the intake → migrate flow. See `docs/domain/existing-projects.md` for state.
2. **`FishGrowthFittingSGRpackage`** — second target. Lowest distance from the library template; clean validation of `/migrate-project` end-to-end.
3. **`MercatusDataFeed`** — third target. Biggest payoff; validates the `pipeline/` template variant and the conversion of append-only `decisions.md` into ADRs.
4. **`MicrosoftFlowsApps`** — fourth target. Validates the `tool-integration/` template variant.
5. **`GrowthModels`** and **`PowerBI`** — when the user activates them. Cold-start with `/intake-target-project` then `/create-project`.

## Skills to refine

All the skills listed in `skills/README.md` are written but unproven. Each should be exercised on real work and tightened based on what shakes out. Specific things to watch for:

- **`grill`** — does the inline `glossary.md` update mechanic actually fire mid-conversation, or does the agent batch updates to the end? If the latter, sharpen the skill body.
- **`work-issue`** — the auto-vs-interactive split (auto for reversible, confirm for shared-state, stop for inconsistency) is a hypothesis. Real use will reveal whether the categories are the right ones.
- **`finish`** — orphan-sweep mechanics. Currently described in prose; if it turns out to need a deterministic check, extract a small script (`scripts/orphan-sweep.sh`) the skill calls.
- **`intake-target-project`** — first real exercise will be GutEvac. Watch for: does inline staging-write actually fire mid-conversation? Does the migration plan in `_warehouse/migration-plan.md` end up actionable for `/migrate-project`, or does it need re-grilling at execution time?
- **`migrate-project`** — the `decisions.md` → ADRs conversion is the trickiest part. Likely needs interactive confirmation per entry. Also: does the staging-transfer step compose cleanly with the existing audit logic?
- **`finish-analysis`** — the cross-doc promotion logic. May need separate sub-skills for "promote to glossary" vs "promote to domain" if the heuristics get complex.

## Templates to refine

Templates exist for `library`, `pipeline`, `tool-integration`, `analysis` — all unproven on real cold-start work. Specific risks:

- **`pipeline/`** — the "Pipeline areas" table in CLAUDE.md and the "one file per stage" reference convention work for MercatusDataFeed but may be over-rigid for simpler pipelines.
- **`tool-integration/`** — drops `docs/reference/` to optional. If first-party code grows in such a project (e.g. a CLI on top of the wrapped tools), reinstating the reference dir should be straightforward.
- **`analysis/`** — first real test will be GutEvac. Watch for: does the "findings provenance" rule hold up in practice (every glossary/domain/ADR claim links a REPORT), or does it become ceremony? Does the ADR-0007 split (caveats → `known-issues.md`, priorities → `future-work.md`, methodology → ADRs) actually absorb the legacy `working_notes_for_future_runs.txt` content cleanly, or does some category fall through? Is the optional-`docs/reference/` decision the right call, or do most research projects accumulate enough utility code to need it?
- The placeholder markers (`<!-- FIXED -->`, `<!-- PLACEHOLDER ... -->`, `<PLACEHOLDER: ...>`) are inconsistent in style across files. A pre-commit-style sweep could enforce a single convention.

## Out-of-scope knowledge base

Matt's pattern: `.out-of-scope/<concept>.md` files capturing why a feature was rejected, with deduplication when similar requests recur. Not yet adopted. Worth picking up the first time the build chain produces a `wontfix` enhancement that isn't trivially obvious. Skill: extend `/triage` to write `.out-of-scope/` entries on `wontfix` of an enhancement (`category: enhancement`, status: `wontfix`).

## Open questions

- **Skill location for global skills**: `~/.claude/skills/` (per-user) or per-project copies? Per-user is cleaner; per-project guarantees portability if the user moves machines. Currently `sudo-script` is documented as `~/.claude/skills/sudo-script/`; the user must symlink manually.
- **Plugin packaging revisited**: at what scale (other users, shareable distribution) does the plain-folders-no-plugin trade-off ([ADR-0012](../adr/0012-plain-folders-no-plugin.md)) flip? Currently solo use; plain folders are correct.
- **`work-issue` interactive in auto mode**: the skill defers shared-state actions ("stop and surface, leave the branch"). On the user's return, what's the resumption skill — `/work-issue` again, or `/finish`? Currently underspecified.
- **`finish` orphan-sweep mechanics**: prose-only currently. If the user wants a deterministic check, build a small script.
