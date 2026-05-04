---
name: start-analysis
description: Scaffold a new investigation under analysis/YYYY-MM-DD-<kebab-topic>/ with a REPORT.md stub and a stub entry in analysis-landscape.md. Forces the dated-dir structure at start so investigations cannot drift. Use when the user wants to "start an analysis", "investigate X", "dig into Y", "reverse-engineer Z", or "look at this data". Auto-mode safe.
---

# Start Analysis

Create the structure for a new investigation. The dated-dir + REPORT.md + landscape registration is the project's first-class home for analytical work; this skill makes it impossible to skip.

This skill is auto-mode safe.

## Process

### 1. Get the topic

If the user passed a topic as an argument, use it (kebab-case it if not already). Otherwise ask once: "What's the investigation topic?" — short, kebab-case-able, descriptive.

In auto mode, require the topic as an argument. Without one, refuse and ask the user to re-invoke with `/start-analysis <topic>`.

### 2. Compute the directory name

```
analysis/YYYY-MM-DD-<kebab-topic>/
```

The date is **today** (start date). Verify the directory does not already exist. If it does:

- If empty or contains only a stub REPORT, ask whether to proceed in-place.
- Otherwise propose a different topic name (with a short suffix like `-v2`).

### 3. Verify analysis/ scaffolding exists

If `analysis/` doesn't exist, create it with:

- `analysis/README.md` — copy from `templates/library/analysis/README.md` (or the warehouse equivalent at the same path).
- `analysis/analysis-landscape.md` — copy from the same template.

If `analysis/` exists but `analysis-landscape.md` is missing, create it.

### 4. Create the dated subdirectory

```
analysis/YYYY-MM-DD-<topic>/
├── REPORT.md             (stub — see below)
└── outputs/              (gitignored — empty for now)
```

Add an `outputs/.gitkeep` file so the empty directory is tracked.

### 5. Stub REPORT.md

Use this template:

```md
# <topic, capitalized>

**Date:** YYYY-MM-DD (started) → YYYY-MM-DD (last update)
**Status:** in-progress

## Question

TODO: what did we set out to find out?

## Method

TODO: scripts, data sources, assumptions used.

## Findings

TODO: what we learned, with concrete evidence.

## Implications

TODO: what should land in glossary.md / docs/domain/ / docs/adr/ / future-work.md.

## Open ends

TODO: what's left unresolved.
```

Auto-fill the topic title and date. Leave the `TODO:` lines verbatim — `/finish-analysis` greps for `^TODO:` and refuses to mark the analysis complete while any remain, so the tokens are the mechanical signal that a section hasn't been filled in yet.

### 6. Register in analysis-landscape.md

Add a stub beat in the appropriate Themes section. Format:

```md
- **YYYY-MM-DD — <topic>.** Question: <one-sentence question>. Status: in-progress. → [REPORT](YYYY-MM-DD-<topic>/REPORT.md)
```

If no obvious theme section exists, create one:

```md
### <Theme name>

- **YYYY-MM-DD — <topic>.** ...
```

Inferring the theme from the topic is fine. If unsure, put the new entry under a "Recent" section that can be re-categorised later.

### 7. Report

Tell the user:

- **Created:** path to the dated dir, path to REPORT.md, link in landscape.
- **Suggested next step:** "Run your investigation. Scripts and outputs go in this dir; outputs/ is gitignored. When done, run `/finish-analysis` to finalise the REPORT, register findings in the right docs, and lock the landscape entry."

## What this skill does NOT do

- Does not run any investigation code.
- Does not write findings into the REPORT — only the structural stub.
- Does not modify `glossary.md`, `docs/domain/`, or `docs/adr/` — those updates happen at `/finish-analysis`.
- Does not create the `outputs/` content (only the directory).
