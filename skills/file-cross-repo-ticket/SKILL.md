---
name: file-cross-repo-ticket
description: Drop a templated ticket into another repository's `.tickets/inbox/` directory so an agent working there picks it up next session. Lazy filesystem-based cross-repo coordination. Use when an agent in repo A discovers repo B needs a change, or when the user says "file a ticket in <other-repo>" or "tell <other-repo> agent about this". Auto-mode safe.
---

# File Cross-Repo Ticket

Drop a markdown ticket into another repo's `.tickets/inbox/` so the agent that next runs in that repo picks it up during triage.

This skill is auto-mode safe.

## Why this exists

When working in repo A, you discover repo B needs a change to make A's work complete. Options:

1. Modify B yourself — risky, A's agent doesn't fully understand B's conventions.
2. Tell the user verbally — relies on the user remembering.
3. Drop a file in B's filesystem — captures the intent durably; B's next agent triages it like any other ticket.

Option 3 is what this skill does.

## Process

### 1. Inputs

Get from the invocation arguments or by asking once (interactive only):

- **Target repo path** — absolute path to the dependent repo. If unsure, ask. In auto mode without an argument, refuse.
- **Title** — one-line summary.
- **Body** — what the other repo needs to do, written as if for that repo's agent (use that project's vocabulary if you know it).

### 2. Verify the target

Check that:

- The target path exists.
- It looks like a project repo (has CLAUDE.md or AGENTS.md or similar).
- The target's `.tickets/inbox/` directory exists. If not, **create it** (mkdir -p) — the convention should self-bootstrap when adopted.

If the target doesn't look like a project repo, surface and ask the user to confirm the path.

### 3. Compose the ticket

File path:

```
<target-repo>/.tickets/inbox/<YYYY-MM-DD-HHmmss>-<kebab-slug>.md
```

The timestamp prefix sorts inbox entries by drop time. The slug is derived from the title.

Body template:

```md
**Status:** needs-triage
**Category:** enhancement | bug
**Source:** filed from <source-repo-name> on <YYYY-MM-DD> by AI agent

## What we need

<Behavioural description of the change. Use the target repo's vocabulary if you know it. No file paths, no line numbers — those live in the target repo's reality.>

## Why we need it

<Context: what we were doing in the source repo, what we discovered, why it can't be solved on the source side. Link the source ticket if applicable.>

## Acceptance (proposed)

- [ ] <criterion 1>
- [ ] <criterion 2>

## Source

- Source repo: <source-repo-name>
- Source ticket: <link or "none — discovered during exploratory work">
- Source agent: AI (filed automatically via /file-cross-repo-ticket)

## Comments
```

### 4. Write

Create the file. Verify by re-reading.

### 5. Optionally announce in the source repo

If the source repo has a place to record outgoing cross-repo tickets (it doesn't by convention, but `docs/planning/future-work.md` is reasonable), append a brief note: "Filed cross-repo ticket to <target-repo>: <title> → <target-path>".

This is optional and only happens if the user opts in. Default: don't write to the source repo, the cross-repo ticket itself is the durable record.

### 6. Report

- **Filed at:** absolute path to the inbox file.
- **Target repo:** name.
- **Title:** the ticket's title.
- **Next step (for the target):** when the user opens a session in the target repo, the agent will see the inbox entry during triage (or via `/check-inbox`) and process it like any other `needs-triage` ticket.

## What this skill does NOT do

- Does not modify any source-repo files (other than the optional announce step).
- Does not push or commit anything in the target repo — leaves the file uncommitted.
- Does not invoke any skills in the target repo — it's a fire-and-forget drop.
- Does not interpret the source repo's intent — relies on the agent invoking the skill to compose a clear ticket.
