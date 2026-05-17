**Status:** done
**Category:** bug
**Type:** AFK

## Parent

[../PRD.md](../PRD.md).

## What to build

Fix `skills/finish/scripts/check-docs.sh` so it works correctly when invoked through a symlinked install (the normal case for any project scaffolded by `/create-project` or `/migrate-project`).

Suggested approach:

1. Replace the `${BASH_SOURCE[0]}`-based discovery with `$PWD`:

   ```bash
   project_root="${PROJECT_ROOT:-$PWD}"
   # Optional --project-root override:
   if [[ "${1:-}" == "--project-root" ]]; then
       project_root="$2"
       shift 2
   fi
   ```

   Then proceed with `mode="${1:-}"` as before. `$PWD` works because `/finish`'s SKILL.md already documents invocation from the project root.

2. Sanity-check `project_root`: if `$project_root/CLAUDE.md` does not exist, error out (`exit 2`) with a clear message rather than silently skipping the sweep. A missing `CLAUDE.md` at the invocation root means the caller is in the wrong place — surface it.

3. Update `skills/finish/SKILL.md`:
   - In the orphan-sweep step, mention that the script reads `$PWD/CLAUDE.md` (or the `--project-root` override). One sentence.
   - The existing fallback prose stays (covers older projects without the script).

4. Test matrix:
   - From `~/AgenticEngineering/`: `bash skills/finish/scripts/check-docs.sh --all` → still OK.
   - From a research project with `.claude/skills/finish` symlinked to the warehouse: `.claude/skills/finish/scripts/check-docs.sh --all` → reads the project's own `CLAUDE.md`, runs sweeps against the project's tree. (If no research project is available locally, fake one: create a tmpdir with `CLAUDE.md` + a doc-map, symlink `.claude/skills/finish` to the warehouse, `cd` in, run the script.)
   - From a directory with no `CLAUDE.md`: clear error, non-zero exit.

5. Verify `list_md_files`' `-prune` patterns still exclude `references/`, `templates/`, `target-projects/` correctly — those use `$project_root` directly, so they should work as soon as `$project_root` is correct.

## Acceptance criteria

- [x] `check-docs.sh` resolves `project_root` from `$PWD` (with optional `--project-root` override).
- [x] Sweep runs against the **calling** project, not the warehouse, when invoked through a symlink.
- [x] Missing `CLAUDE.md` at the invocation root produces a clear error and non-zero exit (no silent skip).
- [x] `skills/finish/SKILL.md` mentions the new invocation contract.
- [x] Warehouse self-test still passes: `bash skills/finish/scripts/check-docs.sh --all` from `~/AgenticEngineering/`.
- [x] Symlink-install test passes (see test matrix above).

## Blocked by

None.

## Comments

- 2026-05-18 — Fixed. `check-docs.sh` now anchors on `$PWD` with `--project-root <path>` override; hard-errors (exit 2) when `CLAUDE.md` is absent at the invocation root rather than silently skipping. `SKILL.md` step 2 updated to reflect the new contract. Verified end-to-end with a tmpdir fake project that symlinks `.claude/skills/finish` into the warehouse: orphan correctly detected in the *fake project's* `docs/reference/`, not the warehouse. Warehouse self-test still returns OK.
