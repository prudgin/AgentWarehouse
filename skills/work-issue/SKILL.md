---
name: work-issue
description: Pick up a triaged ticket marked `ready-for-agent`, branch, code, run the feedback loop, update affected docs, commit, and prepare for merge. Auto-mode safe for reversible local actions; pauses with explicit confirmation requests for shared-state actions (push, merge, delete, ticket-close, cross-repo writes). Use when the user says "work on #42", "implement this ticket", or "pick up the next ready-for-agent ticket".
---

# Work Issue

Implement a `ready-for-agent` ticket end-to-end: branch, code, verify, document, commit, prepare for merge.

This skill is auto-mode safe. It does the reversible work autonomously and pauses to surface any **shared-state** action (push to remote, merge to main, delete files, close ticket, write into another repo) for explicit confirmation.

## Process

### 1. Read the ticket

Find the ticket by id, by `ready-for-agent` status, or by user direction.

For local-markdown: read `.tickets/<feature>/issues/NN-<slug>.md`. Confirm `Status: ready-for-agent`.
For GitHub: `gh issue view <number> --comments`.

Read the **agent brief** (the comment posted during triage). The brief is the contract; the ticket body is context. If no agent brief exists, refuse to proceed and tell the user the ticket isn't actually ready.

### 2. Branch

Auto:

```bash
git checkout -b feature/<id>-<slug>
```

If the ticket has no number, derive an id (PRD slug + sequence). Naming: `feature/<id>-<short-slug>` (or `bugfix/...` for bugs).

If the working tree has uncommitted changes, **stop and surface** — don't auto-stash, don't auto-commit, ask the user.

### 3. Read the project's language and decisions

Read `glossary.md` and any ADRs in the touched area before making naming or design choices.

### 4. Build the feedback loop first

Before writing implementation code, make sure there is **a fast, deterministic, agent-runnable pass/fail signal** for whether the ticket's acceptance criteria are met.

Match the loop to the codebase:

- **Library**: a failing test at the public API.
- **Pipeline**: a stage runner with QA invariants.
- **Tool integration**: a CLI invocation with a fixture input and a snapshot comparison.

If no loop exists at the right seam, build one. Use `/diagnose` Phase 1 ("the loop is the skill") as the discipline. Don't proceed to coding until the loop fails for the right reason.

### 5. Code

Implement the smallest thing that turns the loop green. Don't anticipate future tickets. Don't gold-plate.

Cycle:

```
Loop → fails → minimal change → loop → passes → next acceptance criterion
```

If you discover the brief is wrong (acceptance criteria are unclear, contradictory, or impossible), **stop and surface** — re-triage rather than guess.

If you discover that another repo needs a change to make this work, **stop and surface** — option to file a cross-repo ticket via `/file-cross-repo-ticket` rather than monkey-patching.

### 6. Update the docs

When you change behaviour, update the doc that describes it:

- **Code change** → relevant `docs/reference/` doc (auto).
- **New decision passing 3-of-3** → new `docs/adr/NNNN-slug.md` (auto, but show the user what you wrote at the end).
- **New domain term resolved** → `glossary.md` entry (auto).
- **Investigation findings** → finalise the relevant `analysis/<topic>/REPORT.md` if applicable (auto).
- **Project structure changed** → `CLAUDE.md` (auto).

### 7. Commit

Auto:

```bash
git add <relevant-paths>
git commit -m "<imperative tense, describes what the change does>"
```

Stage specific paths, not `git add -A` (avoids accidentally staging secrets or scratch files). The commit message references the ticket id where applicable.

### 8. Pre-merge verification (auto)

- Run the feedback loop one more time. Must pass.
- Run any project-level checks (typecheck, lint, format) if configured.
- Sweep the touched docs for stale references (auto).

### 9. Confirm before shared-state actions

Pause and ask the user before any of these:

- **Push to remote** (`git push`).
- **Merge to main** (`git merge`, `gh pr merge`, or fast-forward).
- **Delete files or branches** (`rm`, `git branch -D`).
- **Close the ticket** (status `done`, `gh issue close`).
- **Write into another repo** (cross-repo file ops).

For each, present what you'd do and wait for explicit yes. In auto mode without a user, **surface and stop** — leave the branch ready for the user to confirm on return.

### 10. Surface unresolvable inconsistencies

Stop and ask the user if you encounter any of these during the doc sweep:

- CLAUDE.md mentions a module that no longer exists.
- A doc references a file or symbol that wasn't found.
- The agent brief's acceptance criteria conflict with each other.
- An ADR contradicts the change you just made.

These can't be safely auto-resolved.

### 11. Report

When work is ready (or paused at a confirmation point):

- **Branch:** name and head commit.
- **Acceptance criteria:** which pass, which (if any) are deferred and why.
- **Docs touched:** list.
- **Confirmation pending:** what you need yes/no on, with the proposed action.
- **Suggested next step:** `/finish` for the cleanup ritual once merged.

## What this skill does NOT do

- Does not push without explicit confirmation.
- Does not merge without explicit confirmation.
- Does not close tickets without explicit confirmation.
- Does not modify another repo without explicit confirmation.
- Does not run the full project test suite if the project doesn't have one configured — does not invent test infrastructure.
