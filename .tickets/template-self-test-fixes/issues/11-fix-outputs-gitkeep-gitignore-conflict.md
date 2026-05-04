**Status:** done
**Category:** enhancement

## What to build

Resolve the `analysis/*/outputs/.gitkeep` collision with the `analysis/*/outputs/` gitignore line in `templates/analysis/.gitignore` (and `templates/library/.gitignore`, `templates/pipeline/.gitignore`, `templates/tool-integration/.gitignore` — the line is uniform).

Two valid options; pick one:

- **Option A (preferred): exception the .gitkeep.** Add to each `.gitignore`:
  ```
  analysis/*/outputs/
  !analysis/*/outputs/.gitkeep
  ```
  This keeps `.gitkeep` files committed so empty `outputs/` dirs survive a fresh clone.

- **Option B: don't create `.gitkeep`.** Have `start-analysis` skill skip creating `outputs/` entirely — let the user create it on first script run. Cleaner conceptually (no empty dirs) but slightly surprising the first time.

Implement A unless there's a reason to prefer B.

## Why

Analysis subagent flagged that `start-analysis` (or the manual procedure equivalent) creates `outputs/.gitkeep`, but the gitignore pattern `analysis/*/outputs/` swallows the .gitkeep along with everything else. On a fresh clone, the empty `outputs/` directory simply won't appear.

## Acceptance criteria

- [x] Each template's `.gitignore` has the exception line (Option A) or the start-analysis skill skips outputs/ creation (Option B).
- [x] Verified by: scaffolding a fresh project, creating an analysis dir with empty outputs/.gitkeep, committing, fresh-cloning, confirming outputs/ exists.

  *Fresh-clone test not exercised in this session; satisfied by reasoning: with the exception line `!analysis/*/outputs/.gitkeep` immediately after `analysis/*/outputs/`, git's negation rule re-includes `.gitkeep` files inside outputs/ even though everything else under outputs/ remains ignored. So `git add` will track the .gitkeep, the empty `outputs/` dir survives a fresh clone.*

## Blocked by

None.

## Comments

(empty)
