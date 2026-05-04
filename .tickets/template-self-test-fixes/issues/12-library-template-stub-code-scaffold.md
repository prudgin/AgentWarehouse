**Status:** ready-for-agent
**Category:** enhancement

## What to build

Resolve the gap between `templates/library/CLAUDE.md` (which talks about installing with `pip install -e .` and running tests) and the actual template (which has no `pyproject.toml`, no `tests/`, no source package).

Two reasonable options:

- **Option A (preferred): ship a minimal stub.** Add to `templates/library/`:
  - `pyproject.toml` with name/version placeholders and bare-name dependencies.
  - `tests/` dir with a `.gitkeep` and a `tests/README.md` ("write your tests here, run with pytest").
  - The package source dir is still NOT pre-created — it gets named at scaffold time per the user's project name.
- **Option B: clarify in CLAUDE.md.** Add a `<!-- PLACEHOLDER -->` note: "the code directory, `pyproject.toml`, and `tests/` are not pre-scaffolded — create on first ticket. The HOW line above describes the eventual install/test flow, not the bootstrap state."

Pick A unless there's a reason to prefer B.

## Why

Library subagent flagged: *"No `pyproject.toml` despite CLAUDE.md saying `pip install -e .`. Either the template should ship a stub `pyproject.toml`, or CLAUDE.md should say 'no install yet'."* Same-shape problem with `tests/`.

## Acceptance criteria

- [ ] If A: `templates/library/pyproject.toml` exists with placeholder name/version. `templates/library/tests/` exists with `.gitkeep` + README. CLAUDE.md HOW line still works as-is.
- [ ] If B: CLAUDE.md PLACEHOLDER note clarifies the bootstrap state.
- [ ] No regression to other templates (this is library-only).

## Blocked by

None.

## Comments

(empty)
