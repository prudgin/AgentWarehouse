# External References

External repos and resources cloned or studied during the warehouse design. Live under `references/` at the repo root. Each entry below records what was studied, what was taken into the warehouse, and what was deliberately left behind.

## `references/mattpocock-skills/`

Source: <https://github.com/mattpocock/skills>. Cloned 2026-05-01.

Matt Pocock's daily-use skill collection for Claude Code. The structural inspiration for the warehouse's skills layer.

**What we adopted:**

- **Skill format** — `SKILL.md` with frontmatter (`name`, `description`, optional `disable-model-invocation`).
- **Build chain** — the `/grill-me` → `/to-prd` → `/to-issues` → `/triage` sequence as the spine of the build workflow. Adapted to use local-markdown tickets by default ([ADR-0009](../adr/0009-tickets-as-markdown-files.md)).
- **Ubiquitous-language content contract** — one canonical term per concept, "Avoid" synonyms, relationships, example dialogue, flagged ambiguities. We keep our existing filename `glossary.md` ([ADR-0002](../adr/0002-glossary-keeps-name-adopts-content-contract.md)).
- **ADRs with 3-of-3 admission test** — hard to reverse, surprising without context, real trade-off ([ADR-0005](../adr/0005-adrs-with-3-of-3-admission-test.md)).
- **Triage state machine** — canonical role names (`needs-triage`, `ready-for-agent`, `ready-for-human`, `wontfix`, `needs-info`) with per-project label mapping.
- **Agent brief format** — durable, behavioural, no file paths or line numbers. Survives weeks in the queue.
- **`/diagnose` Phase 1 ("the loop is the skill")** — the primary feedback-loop discipline; supersedes a standalone `/tdd` skill ([ADR-0010](../adr/0010-no-tdd-skill.md)).
- **`/improve-codebase-architecture`** — periodic deepening sweeps with the deletion test and depth-as-leverage vocabulary.
- **Hard- vs soft-dependency split for setup** (Matt's ADR-0001) — skills that absolutely require per-repo config say so loudly; skills that benefit from it but degrade gracefully don't.
- **Lazy doc creation** — `glossary.md`, `docs/adr/`, etc. created only when the first term resolves or the first decision crystallises.
- **Progressive disclosure via skills** — agents see frontmatter descriptions, load bodies on demand.

**What we deliberately left behind:**

- **Plugin packaging** (`.claude-plugin/plugin.json`). We ship plain folders ([ADR-0012](../adr/0012-plain-folders-no-plugin.md)).
- **`CONTEXT.md` filename**. We keep `glossary.md` ([ADR-0002](../adr/0002-glossary-keeps-name-adopts-content-contract.md)).
- **GitHub-Issues-first ticket store**. We default to local markdown ([ADR-0009](../adr/0009-tickets-as-markdown-files.md)).
- **Standalone `/tdd` skill**. Folded into `/diagnose` ([ADR-0010](../adr/0010-no-tdd-skill.md)).
- **`/caveman` mode, `/scaffold-exercises`, `/migrate-to-shoehorn`, `/setup-pre-commit`, `/git-guardrails-claude-code`**. Useful for some users; not core to the warehouse's workflow.

**What was novel and unique to Matt:**

- The grilling skill as a first-class alignment phase (replaces "plan then code").
- The vertical-slice ("tracer bullet") rule for breaking PRDs into AFK-grabbable issues.
- The deletion test for assessing module depth.
- The `.out-of-scope/<concept>.md` knowledge base for durable rejection records — we'll likely adopt this if the build chain produces enough rejected proposals to warrant it.

## Lecture summary used as input

The user provided a written summary of one of Matt's talks covering: smart-zone vs dumb-zone, the Memento problem, the four-phase workflow (grill → PRD → kanban → AFK), TDD as feedback loop, deep modules vs shallow modules, and the philosophy that "code is always the battleground." The talk material informed the framing in [philosophy.md](philosophy.md).

## Future references to consider

- Anthropic's official skills repo (when published) — likely overlaps with Matt's but probably has different opinions worth comparing.
- Other community skill collections referenced from Matt's READMEs.

These will be added under `references/` and documented here when relevant.
