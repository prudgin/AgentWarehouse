**Status:** done
**Category:** enhancement
**Type:** AFK

## Parent

[../PRD.md](../PRD.md). Implements [ADR-0017](../../../docs/adr/0017-scripts-colocate-with-skills.md).

## What to build

Implement the mechanical doc-sweep script `check-docs.sh` colocated under `/finish`, and rewire `/finish` step 2 (orphan sweep) and step 3 (broken-link sweep) to invoke it.

Specifically:

1. Create `skills/finish/scripts/check-docs.sh`. Bash, executable. Two modes:
   - `--orphans` — derive the target dir list from `CLAUDE.md`'s "Documentation map" section (per existing `/finish` step 2 behaviour). For each derived dir, list every `*.md` and verify it's referenced in the dir's `README.md` index. Print orphans as `<path>` (newline-separated). Exit 0 if none, 1 if any orphans.
   - `--broken-links` — scan every `*.md` in tracked dirs for markdown links `[text](path)`. For each link with a relative path, verify the file (and anchor, if `#` present) resolves. Print broken links as `<source>:<line>:<link>`. Exit 0 if none, 1 if any.
   - `--all` — both, exit 1 if either reports problems.
2. Update `skills/finish/SKILL.md`:
   - Step 2: replace the prose "list files, open README, verify mention" with "run `.claude/skills/finish/scripts/check-docs.sh --orphans` (the script knows where it is via its own path); fall back to manual prose only if the script is missing".
   - Step 3: replace prose with `--broken-links` invocation.
   - Note that judgment-call steps (4 CLAUDE.md drift, 6 future-work graduation) remain agent work.
3. Update `skills/README.md` to document that skills may have an optional `scripts/` subdir (per ADR-0017). One short paragraph in the "Skill format" section.
4. Verify: symlinking `~/AgenticEngineering/skills/finish` into a project's `.claude/skills/finish` brings the script along (the symlink to the dir is sufficient — no extra symlink machinery needed).

## Acceptance criteria

- [x] `skills/finish/scripts/check-docs.sh` exists, executable, runs without error against the warehouse itself.
- [x] Script supports `--orphans`, `--broken-links`, `--all`. Exit codes correct.
- [x] `/finish` SKILL.md step 2 invokes `--orphans`; step 3 invokes `--broken-links`.
- [x] `skills/README.md` documents the `scripts/` subdir convention.
- [x] Tested by running `check-docs.sh --all` against the warehouse — passes (no orphans or broken links introduced by recent work).

## Blocked by

None — can start immediately.

## Comments

(empty)
