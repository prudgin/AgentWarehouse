---
name: to-issues
description: Break a PRD, plan, or any feature description into independently-grabbable tickets in the project's ticket store, using vertical slices (tracer bullets). Each ticket cuts end-to-end through every layer. Quizzes the user on the proposed breakdown before publishing. Use when the user wants to "break this into tickets", "split into issues", "create implementation tickets", or "plan the work". Interactive — uses AskUserQuestion turn-by-turn; runs fine under auto mode.
---

# To Issues

Break a plan into independently-grabbable tickets using **vertical slices** (tracer bullets). Each ticket cuts end-to-end through every layer (schema, API, UI, tests) — never a horizontal slice of one layer.

## Auto mode is fine

This skill quizzes the user via `AskUserQuestion`, which works under auto mode. Run normally regardless of mode; do not abort on the auto-mode reminder.

## Process

### 1. Gather context

Work from whatever is in the conversation context. If the user passes a PRD reference (path, issue number, URL), fetch it and read the full body and any comments.

### 2. Read the project's language

Read `glossary.md` and any ADRs in the touched area. Ticket titles and bodies should use the project's domain vocabulary.

### 3. Draft vertical slices

Break the plan into **tracer-bullet tickets**:

- Each slice delivers a narrow but COMPLETE path through every layer (schema → API → UI → tests, or whatever layers exist).
- A completed slice is demoable or verifiable on its own.
- Prefer many thin slices over few thick ones.
- A horizontal slice (e.g. "build all schemas first") is wrong — gives no feedback until phase three.

Mark each slice as **AFK** (an agent can pick it up cold and ship it) or **HITL** (human-in-the-loop — needs design review, judgment, external access). Prefer AFK over HITL where possible.

For each slice, identify:

- A short descriptive title.
- AFK / HITL marker.
- `Blocked by`: which other slices (if any) must complete first.
- Which user stories (from the PRD) the slice covers.

### 4. Quiz the user

Present the proposed breakdown as a numbered list. Show the four fields above for each slice. Then ask:

- Does the granularity feel right? (Too coarse / too fine?)
- Are the dependency relationships correct?
- Should any slices be merged or split?
- Are AFK / HITL classifications correct?

Iterate until the user approves.

### 5. Publish in dependency order

Publish blockers first so each ticket can reference real identifiers in its `Blocked by` field.

**Local-markdown backend:**

Create `.tickets/<feature-slug>/issues/NN-<slug>.md` (numbered from `01`) for each slice. Use the body template below.

**GitHub backend:**

```bash
gh issue create --title "<title>" --body "..." --label "needs-triage"
```

### 6. Ticket body template

```md
**Status:** needs-triage
**Category:** enhancement | bug
**Type:** AFK | HITL

## Parent

(Link to parent PRD ticket if applicable; otherwise omit.)

## What to build

A concise description of this vertical slice. Describe end-to-end behaviour, not layer-by-layer implementation.

## Acceptance criteria

- [ ] Specific, testable criterion 1
- [ ] Specific, testable criterion 2
- [ ] ...

## Blocked by

- (issue reference) or "None — can start immediately"

## User stories covered

(from the PRD, if applicable)

- US-1, US-3, US-7

## Comments
```

### 7. Report

Tell the user:

- Number of tickets published.
- Where they live (directory or list of issue URLs).
- Suggested next step: `/triage` to walk each ticket through the state machine and produce agent briefs for the AFK ones.

## What this skill does NOT do

- Does not modify the parent PRD.
- Does not write code.
- Does not assign tickets to anyone.
- Does not auto-promote tickets past `needs-triage` — that's `/triage`.
