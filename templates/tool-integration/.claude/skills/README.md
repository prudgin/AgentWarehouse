# Skills

Procedural workflows the agent can invoke. Each skill lives in its own subdirectory with a `SKILL.md` (required) and any supporting files.

## Format

```
.claude/skills/
└── <skill-name>/
    ├── SKILL.md          # required — frontmatter + instructions
    ├── REFERENCE.md      # optional — supporting reference
    └── scripts/          # optional — utility scripts
```

`SKILL.md` frontmatter:

```md
---
name: skill-name
description: One sentence describing what the skill does, plus "Use when X / Y / Z" triggers.
disable-model-invocation: false   # optional; true means slash-only
---

# Skill body
```

The `description` is the **only** thing the agent sees when deciding whether to load the skill. Make the trigger conditions concrete.

## Source

Canonical skill sources live in the warehouse at `~/AgenticEngineering/skills/`. Per-project copies (or symlinks) live here under `.claude/skills/`. Install by symlink:

```bash
ln -s ~/AgenticEngineering/skills/<name> .claude/skills/<name>
```

For tool-integration projects, the typical install set leans heavier than for libraries — most procedural knowledge lives in skills. At minimum: `grill`, `to-prd`, `to-issues`, `triage`, `work-issue`, `finish`, `file-cross-repo-ticket`, `check-inbox`. Plus any project-specific skills you write to wrap the underlying `_tools/` scripts.

See `docs/reference/skills.md` in the warehouse for the full inventory.

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
