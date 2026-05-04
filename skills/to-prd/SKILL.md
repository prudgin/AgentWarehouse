---
name: to-prd
description: Synthesise a PRD from the current conversation context and publish it as a single ticket in the project's ticket store. Does NOT interview the user — assumes alignment has already happened (typically via /grill). Use when the user wants to "write a PRD", "create a destination doc", or "publish a PRD ticket" after a grilling session. Auto-mode safe.
---

# To PRD

Take the current conversation context and codebase understanding and produce a PRD as a single ticket. **Do not ask new questions** — synthesise from what's already been discussed.

This skill is auto-mode safe; it does not require user interaction.

## Process

### 1. Locate the ticket backend

Default to **local-markdown** (`.tickets/<feature-slug>/PRD.md`) unless the project's CLAUDE.md or a `docs/agents/issue-tracker.md` indicates otherwise. If GitHub Issues is configured, use `gh issue create` instead. Confirm the choice in your output.

### 2. Read the project's language

Before writing, read `glossary.md` (if present) and any ADRs in the touched area (`docs/adr/`). Use the project's domain vocabulary throughout the PRD. If a term you need is missing from the glossary, flag it in the PRD's "Open ends" — don't invent new vocabulary silently.

### 3. Identify the modules

Sketch the major modules that will be built or modified. **Actively look for deep-module opportunities** — small interfaces with rich internals that can be tested in isolation. Note these in the Implementation Decisions section.

A deep module hides complexity behind a simple interface. A shallow module's interface is nearly as complex as its implementation. Prefer deepening when the choice exists.

### 4. Slugify and write

Pick a feature slug from the topic (kebab-case, short).

**Local-markdown backend:**

Create `.tickets/<feature-slug>/PRD.md` with the body template below. Create the directory if needed.

**GitHub backend:**

```bash
gh issue create --title "PRD: <topic>" --body "$(cat <<'EOF'
... PRD body ...
EOF
)" --label "needs-triage,prd"
```

### 5. PRD body template

```md
**Status:** needs-triage
**Category:** prd

## Problem Statement

The problem from the user's perspective.

## Solution

The solution from the user's perspective.

## User Stories

A long, numbered list. Format: "As a <actor>, I want a <feature>, so that <benefit>". Cover all aspects of the change.

1. ...
2. ...

## Implementation Decisions

- Modules to build or modify (call out deep-module opportunities)
- Interfaces of those modules
- Technical clarifications from the developer
- Architectural decisions
- Schema changes / API contracts
- Specific interactions

**Do NOT include specific file paths or code snippets.** They go stale fast and the agent that picks this up later will explore the codebase fresh.

## Testing Decisions

- What makes a good test in this codebase (test external behaviour, not implementation details)
- Which modules will be tested
- Prior art for the tests (similar patterns in the codebase)

## Out of Scope

What is explicitly NOT addressed by this PRD.

## Further Notes

Anything else worth recording.

## Comments
```

### 6. Report

Tell the user:

- **Where the PRD landed** — file path or issue URL.
- **Slug** — the feature slug used.
- **Suggested next step** — `/to-issues` to break the PRD into vertical-slice tickets, or proceed straight to coding if the change is small enough that breaking it adds no value.

## What this skill does NOT do

- It does not interview the user — that's `/grill`.
- It does not break the PRD into tickets — that's `/to-issues`.
- It does not modify code or write any other docs.
- It does not include file paths, line numbers, or code snippets in the PRD.
