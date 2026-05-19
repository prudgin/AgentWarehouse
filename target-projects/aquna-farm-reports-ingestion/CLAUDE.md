# CLAUDE.md — Aquna Farm Reports Ingestion

A Power Automate flow that archives farm-report emails sent from four `@aquna.com` senders to the user's corporate Outlook mailbox into a dedicated SharePoint sub-root.

## What this project is

**WHAT**: One Power Automate flow plus its exported package, source-controlled with supporting docs (glossary, ADRs, flow spec) on warehouse conventions. The shipped artefact is `flow-package.zip` exported from Power Automate; the docs explain *what it must do* and *why*.

**WHY**: Four `@aquna.com` mailboxes send daily/periodic farm reports to the user's corporate inbox. Reports need a durable home on SharePoint so they can be referenced and audited without spelunking in mail.

**HOW**: Trigger on new mail from the allowlisted senders → route by sender → store the full email (`.eml`) plus attachments in `Automation/Farm Reports Archive/<Sender>/YYYY-MM/` inside the `Planning  Development` library on `https://murraycod.sharepoint.com`. Full contract in [`docs/domain/flow-spec.md`](docs/domain/flow-spec.md).

## Working approach

State your reading of the task before acting. Edits to the flow happen in Power Automate's web designer; the local repo holds the *exported* package plus the docs that explain it. When the flow changes, re-export and check in both the new `flow-package.zip` and any doc updates in the same commit.

## Git conventions

- Remote: <to be set on first push>
- Main branch: `main`.
- Commit messages: imperative tense.

## Documentation philosophy

Single canonical home per fact. CLAUDE.md indexes top-level directories; each top-level dir has a `README.md` (or this file plays that role for a small project). No orphans.

## Documentation map

- **[`README.md`](README.md)** — human-facing entry.
- **[`glossary.md`](glossary.md)** — project vocabulary: farm report, sender short-name, sanitised subject, sub-root.
- **[`docs/adr/`](docs/adr/)** — design decisions:
  - [ADR-0001](docs/adr/0001-sender-allowlist-only.md) — sender allowlist is the sole filter (no keyword filter).
  - [ADR-0002](docs/adr/0002-folder-layout-sender-first.md) — folder layout is sender-first, year-month inside.
- **[`docs/domain/flow-spec.md`](docs/domain/flow-spec.md)** — canonical spec for the flow (trigger, routing, filename, storage, failure handling, non-goals).
- **[`docs/planning/future-work.md`](docs/planning/future-work.md)** — pre-decision items.
- **`flow-package/` & `flow-package.zip`** — exported Power Automate package (the actual flow). Re-export after every change.
- **`flow-definition.json`** — the flow's JSON definition (extracted from the package for diff-friendly review).

## Update rules

- **Flow behaviour change** → update `docs/domain/flow-spec.md` *and* re-export the package in the same commit.
- **New design decision (passes 3-of-3 admission test)** → new `docs/adr/NNNN-slug.md`; link from this file.
- **New project term** → add to `glossary.md`.
- **New planned work** → append to `docs/planning/future-work.md`.

## What does NOT belong in CLAUDE.md

Step-by-step procedures for editing the flow (Power Automate's UI is the source of truth for that). Deep domain knowledge belongs in `glossary.md` or `docs/domain/`.

## Portability

`AGENTS.md` is a symlink to this file.
