# A PreToolUse hook blocks shell-sourcing of `.env` files

Every template (and the warehouse itself) ships a `PreToolUse` Bash hook — `.claude/hooks/guard-env-source.py`, wired in `.claude/settings.json` — that blocks any command which shell-sources a `.env` file (`source .env`, `. .env`, the `set -a; . .env; set +a` idiom). Sourcing makes the shell *execute* the file: a secret whose value contains `&` or whitespace — most often a URL that is itself the bearer credential — is parsed as shell, the `&` backgrounds a job, and job-control echoes the full command line (secret included) into the session log. The hook exits 2 (hard block) with a message pointing at the safe loader, `python-dotenv`, which already exists in every scaffolded project. Discovered when an agent in WaterQualityFeed sourced a `.env` of HTTP-trigger SAS URLs and leaked two live credentials that had to be rotated.

**Why a hook and not a deny-list entry** — this is the trade-off against [ADR-0023](0023-templates-ship-curated-broad-allow-list.md). The deny floor in ADR-0023 is expressed as `Bash(<prefix>*)` globs, which match on the *command prefix*. This footgun can't be expressed that way: the danger isn't the `source` command, it's the *argument* (`.env`) together with the *value's contents*. A `Bash(source*)` deny would also kill every legitimate `source .venv/bin/activate`. A content-aware decision requires inspecting the full command string — which only a hook can do.

## Considered options

- **Documentation only** — a "never source `.env`" rule in the template `CLAUDE.md`. Kept (the templates carry the rule and the safe pattern), but insufficient alone: it's passive, and the footgun still fires when the rule isn't recalled — which is exactly how it fired the first time.
- **A `Bash(source*)` / `Bash(. *)` deny entry** (ADR-0023 style). Rejected: prefix globs can't see the `.env` argument, so they are either too narrow (miss the case) or too broad (block legitimate `source .venv/bin/activate` and every other `source`).
- **A PreToolUse hook that inspects the command (chosen).** Content-aware: blocks `source`/`.` of a `.env` in command position; lets `source .venv/...`, `cat .env`, `find . -name .env`, `grep source .env` through. Belt-and-suspenders with the documentation rule.
- **Warn instead of block.** Rejected for a credential-leak footgun: a warning the agent can step past still leaks. Exit 2 (hard block) plus a message naming the safe alternative is the right severity.

## Consequences

**Positive:** the footgun is caught mechanically in every scaffolded project — and in the warehouse, which dogfoods the hook — not merely documented. The block message teaches the safe `python-dotenv` path at the moment of the mistake.

**Negative:** another moving part in the template `.claude/`. The hook **fails open** (a JSON-parse error or a missing `python3` disables it rather than wedging the session), so it is a guardrail, not a guarantee. Its regex is command-position-anchored to avoid false positives but is **not a sandbox** — `eval`/`bash -c` wrappers and other deliberate obfuscation bypass it. Acceptable: the threat model is the *innocent* ad-hoc `source .env` (how the real leak happened), not an adversary evading the guard.

**Reversible?** Easy. Delete the hook script and the `hooks` block from each `settings.json`; nothing depends on it.

## Links

- Sibling: [ADR-0023](0023-templates-ship-curated-broad-allow-list.md) — curated allow/deny list. This hook is the content-aware layer the static globs can't express.
- Origin: cross-repo ticket filed from WaterQualityFeed (`.tickets/guard-against-shell-sourcing-env/`).
- Templates inventory: [`docs/reference/templates.md`](../reference/templates.md) → Shared guardrails.
- The session-start venv hook in [`docs/planning/future-work.md`](../planning/future-work.md) is separate hook machinery, intentionally not folded in.
