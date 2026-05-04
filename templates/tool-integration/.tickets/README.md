# Tickets

Local-markdown issue tracker. PRDs and tickets live as files in this directory; no external system required.

If this project should instead use GitHub Issues, run `/setup-warehouse-skills` and pick GitHub. The skills speak in canonical role names (`needs-triage`, `ready-for-agent`, etc.) and the chosen backend determines storage.

## Layout

```
.tickets/
├── README.md                    # this file
├── inbox/                       # incoming from agents working in dependent repos
│   └── <timestamp>-<slug>.md
└── <feature-slug>/              # one dir per feature
    ├── PRD.md                   # the destination doc, written by /to-prd
    └── issues/
        ├── 01-<slug>.md         # vertical-slice tickets, written by /to-issues
        ├── 02-<slug>.md
        └── ...
```

## Ticket file format

Each ticket file (PRD or individual issue) starts with a status line and uses the same body conventions:

```md
**Status:** needs-triage | needs-info | ready-for-agent | ready-for-human | wontfix | done
**Category:** bug | enhancement | prd

## What to build / What's the problem

...

## Acceptance criteria

- [ ] criterion 1
- [ ] criterion 2

## Blocked by

- (issue reference or "None")

## Comments

(append here as work progresses, oldest first)
```

The status line is the source of truth for triage state. The triage skill reads and updates it.

## Triage states

| Status | Meaning |
|---|---|
| `needs-triage` | Maintainer hasn't evaluated yet. |
| `needs-info` | Waiting for more information from the reporter. |
| `ready-for-agent` | Fully specified, an AFK agent can pick it up cold. |
| `ready-for-human` | Needs human implementation (judgment, external access, design choice). |
| `wontfix` | Will not be actioned. |
| `done` | Implemented and merged. Move to `<feature>/issues/done/` if you want to keep it; otherwise delete. |

## Inbox

`.tickets/inbox/` collects tickets dropped by agents working in **dependent** repos. When an agent in repo A discovers repo B needs a change, it writes a templated ticket to `<repo-B>/.tickets/inbox/<timestamp>-<slug>.md` (via the `/file-cross-repo-ticket` skill).

When you start a session in this repo, the agent should check `.tickets/inbox/` and surface anything new for triage. Inbox tickets are moved into the appropriate `<feature>/` once triaged.

## No orphans

Every ticket file is reachable through this README → directory listing. Skills are responsible for keeping the directory tidy: closed tickets either move to a `done/` subdir or are deleted.
