# Target Projects

Per-target staging dirs for projects the warehouse is setting up (cold-starting via `/create-project`, or migrating via `/migrate-project`).

A subdir here is the **draft of the eventual project**, accumulated by `/intake-target-project` before any files land in the target repo. See [ADR-0015](../docs/adr/0015-target-projects-staging.md) for the rationale and [ADR-0014](../docs/adr/0014-warehouse-grill-vs-project-grill.md) for why this is a separate skill from the in-project `/grill`.

## Layout

```
target-projects/<name>/
├── _warehouse/                   # warehouse-side scratch — does NOT transfer
│   ├── intake-notes.md           # raw notes from /intake-target-project
│   ├── migration-plan.md         # concrete steps for /migrate-project or /create-project
│   ├── status.md                 # dates, skill versions, completion state
│   └── feedback.md               # post-handoff observations (optional)
├── README.md                     # one-liner: status, target path, completion date
├── CLAUDE.md                     # drafted for the eventual project
├── glossary.md                   # drafted for the eventual project
└── docs/
    ├── adr/NNNN-*.md
    ├── domain/*.md
    └── planning/future-work.md
```

## Transfer rule

`/migrate-project` and `/create-project` copy **everything outside `_warehouse/`** into the target repo. Files inside `_warehouse/` stay here as durable record. The underscore prefix is the marker — same convention used for any other meta dir.

## Lifecycle

1. **Open**: `/intake-target-project <name>` creates `target-projects/<name>/` with `_warehouse/status.md` marking the staging as open. Subsequent invocations resume.
2. **Active**: skill writes glossary terms, ADR drafts, domain docs into staging as decisions resolve. Raw notes accumulate in `_warehouse/intake-notes.md`.
3. **Ready**: skill summarises and marks `_warehouse/status.md` as ready-for-transfer. The user invokes `/migrate-project <name>` or `/create-project <name>`.
4. **Done**: transfer completes. `_warehouse/status.md` records the completion date and target path.
5. **Permanent**: the dir stays here. Future warehouse-agent sessions can read it for institutional memory ("how did we set up that project?"); post-handoff feedback can be appended.

## Index

(none yet)
