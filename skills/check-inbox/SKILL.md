---
name: check-inbox
description: List and summarise incoming cross-repo tickets in `.tickets/inbox/`. Surfaces them for the user (or for /triage) to act on. Use at session start, when the user says "check the inbox", "anything new from other repos?", or after a long absence from the project. Auto-mode safe.
---

# Check Inbox

Read `.tickets/inbox/*.md` and present a summary so the user can triage incoming cross-repo work.

This skill is auto-mode safe.

## Process

### 1. Read the inbox

List `.tickets/inbox/*.md` (excluding `.gitkeep` and any directory). Sort by filename (timestamp prefix means oldest first).

If the directory doesn't exist or is empty, report "Inbox empty" and exit.

### 2. Summarise

For each ticket file, extract:

- **Filed:** the timestamp prefix (parse to a human-readable date if useful).
- **Title:** from the first `#` heading.
- **Source:** from the `**Source:**` field in the frontmatter or first paragraph.
- **Status:** `needs-triage` (any other status means it's already been processed and shouldn't be in inbox — flag it).
- **One-line summary:** from the "What we need" section (first sentence).

Present as a numbered list, oldest first:

```
Inbox: 3 tickets

1. [2026-04-12] Pass --debug flag through pipeline runner
   Source: PowerBI
   Need: route the flag from Power BI subprocess invocation through to the pipeline.

2. [2026-04-15] ...

3. [2026-04-30] ...
```

### 3. Suggest next steps

After the list, suggest:

- **`/triage <n>`** — process a specific inbox ticket through the state machine (which moves it out of inbox into a regular `.tickets/<feature>/` location once triaged).
- **Defer** — leave the inbox alone if you're focused on something else.

If any ticket has a non-`needs-triage` status, flag it as anomalous (someone or something already processed it but didn't move it out).

### 4. Auto-suggest at session start (optional)

When invoked without a specific intent, this skill is also a candidate for the agent to run **at session start** if `.tickets/inbox/` is non-empty. The CLAUDE.md update rules can mention this.

This skill itself doesn't auto-fire — it's a regular skill invoked by the agent or user.

## What this skill does NOT do

- Does not triage or process tickets — only lists them.
- Does not modify inbox files.
- Does not move or delete files (that's `/triage`'s job once a ticket is processed).
- Does not invoke `/triage` automatically — surfaces the list and lets the user decide.
