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

Edits to the canonical source then propagate to every project that has installed the skill.

Which skills to install depends on the project — see `docs/reference/skills.md` in the warehouse for the inventory and `docs/domain/philosophy.md` for the build/analyse chain context.

## Index

### Project-local skills

<!-- PLACEHOLDER — list skills authored in this project (real files, not symlinks).
     Research projects rarely need project-local skills; leave empty unless a
     methodology-specific workflow emerges.

-->

### Warehouse skills

<!-- PLACEHOLDER — list skills installed from the warehouse via symlink.
     These are general-purpose workflows; their canonical sources live in
     ~/AgenticEngineering/skills/.

- [start-analysis](start-analysis/SKILL.md) — scaffold a new investigation.
- [finish-analysis](finish-analysis/SKILL.md) — finalise an investigation and promote findings.

-->
