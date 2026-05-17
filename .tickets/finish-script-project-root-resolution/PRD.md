**Status:** done
**Category:** bug

## What's the problem

`skills/finish/scripts/check-docs.sh` discovers `project_root` by walking three levels up from `${BASH_SOURCE[0]}`:

```bash
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(cd "$script_dir/../../.." && pwd)"
```

Projects scaffolded by `/create-project` / `/migrate-project` get `.claude/skills/finish/` as a **symlink** into the warehouse (`~/AgenticEngineering/skills/finish/`). `cd "$(dirname …)" && pwd` resolves through the symlink — `script_dir` lands inside the warehouse, and `project_root` resolves to `~/AgenticEngineering/`, **not** the calling project.

Concrete symptom observed during a research-project `/finish` run:

> `warning: ~/AgenticEngineering/.claude/CLAUDE.md not found; skipping orphan sweep`

The orphan sweep silently no-ops. The fallback prose procedure in SKILL.md gets used instead, so `/finish` still completes — but the *mechanical* sweep that ADR-0023 (orphan-sweep extraction) was supposed to deliver does not run for any symlink-installed project. Every research/library/pipeline/tool-integration project hits this; the warehouse itself is the only project where the script works as intended.

## Acceptance criteria

- [ ] `check-docs.sh` resolves `project_root` from the **invoking** project, not the symlink target. Two reasonable shapes:
  - Default to `$PWD` (skill always invokes from project root), **and** accept `--project-root <path>` to override. Pick one as primary, document the other.
  - Alternative: use `pwd -P` from `$PWD`; reject if `CLAUDE.md` is absent at that path.
- [ ] When invoked from a symlink-installed project, the script reads *that* project's `CLAUDE.md` and runs the orphan sweep against *that* project's tree. Verify by running `.claude/skills/finish/scripts/check-docs.sh --all` from a research project and confirming it parses the local doc map (not the warehouse's).
- [ ] `skills/finish/SKILL.md` updated if invocation shape changes (e.g. mentions `--project-root` or notes that `$PWD` must be the project root).
- [ ] Warehouse self-test still passes: `bash skills/finish/scripts/check-docs.sh --all` from `~/AgenticEngineering/` returns OK.
- [ ] No regression in `list_md_files`' `-prune` patterns — those use `$project_root` directly and must continue to exclude `references/`, `templates/`, `target-projects/` in the warehouse case.

## Blocked by

None.

## Comments

Discovered 2026-05-18 during a research-project `/finish` run. Manual fallback sweep was performed at the time; no data loss, just a silently-skipped check.
