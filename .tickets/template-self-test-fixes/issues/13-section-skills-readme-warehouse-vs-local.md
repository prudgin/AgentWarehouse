**Status:** ready-for-agent
**Category:** enhancement

## What to build

Update `templates/tool-integration/.claude/skills/README.md` to section the index into "Project-local skills" vs. "Warehouse skills (symlinks)" subsections.

The README currently has a single "Index" placeholder block. Replace with:

```md
## Index

### Project-local skills

<!-- PLACEHOLDER — list skills authored in this project (real files, not symlinks).
     For tool-integration projects these typically wrap `_tools/` scripts.

- [tasktool-list](tasktool-list/SKILL.md) — list tasks via `_tools/tasktool-list.sh`.

-->

### Warehouse skills

<!-- PLACEHOLDER — list skills installed from the warehouse via symlink.
     These are general-purpose workflows; their canonical sources live in
     ~/AgenticEngineering/skills/.

- [grill](grill/SKILL.md) — alignment interview before building.
- [finish](finish/SKILL.md) — cleanup ritual.

-->
```

Also propagate the same sectioning to `templates/library/.claude/skills/README.md`, `templates/pipeline/.claude/skills/README.md`, `templates/analysis/.claude/skills/README.md` — even though those templates are less likely to grow project-local skills, the convention should be consistent.

## Why

Tool-integration subagent flagged that warehouse skills (symlinks) and project-local skills (real files) live in the same directory with no visual distinction. With 16+ skills, a hand-maintained flat index drifts.

## Acceptance criteria

- [ ] All four templates' `.claude/skills/README.md` use the sectioned layout.
- [ ] PLACEHOLDER comments make clear which section is which.
- [ ] `/finish`'s orphan-sweep still indexes both sections correctly (no regression).

## Blocked by

None.

## Comments

(empty)
