**Status:** ready-for-agent
**Category:** enhancement

## What to build

In `templates/tool-integration/`:

1. Create an empty `.secrets/` directory with a `.gitkeep` file.
2. Add a line to `.gitignore`: `.secrets/*` followed by `!.secrets/.gitkeep`.
3. Have `/create-project` (or the post-scaffold step) `chmod 700 .secrets/` after copying the template.

## Why

The tool-integration template's CLAUDE.md asserts: *"Real API keys live in `.secrets/` (gitignored, mode 700)."* But the dir doesn't exist on scaffold; the tool-integration subagent flagged this as "the kind of thing a real user would trip on."

Pre-creating it (with the right gitignore + mode) closes the gap so the assertion in CLAUDE.md is true the moment the project is scaffolded.

## Acceptance criteria

- [ ] `templates/tool-integration/.secrets/.gitkeep` exists.
- [ ] `templates/tool-integration/.gitignore` excludes `.secrets/*` and includes `.secrets/.gitkeep`.
- [ ] `/create-project` runs `chmod 700 .secrets/` for tool-integration scaffolds (no-op for other templates since they don't have `.secrets/`).

## Blocked by

None.

## Comments

(empty)
