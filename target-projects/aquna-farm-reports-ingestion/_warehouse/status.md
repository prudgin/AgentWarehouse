---
status: created
started: 2026-05-18
completed: 2026-05-18
mode: cold-start
target_install_path: /home/rndmanager/MicrosoftFlowsApps/flows/Aquna_Farm_Reports_Ingestion/
template: tool-integration
scaffold_commit: d194f7e
---

# Status

Project created at `/home/rndmanager/MicrosoftFlowsApps/flows/Aquna_Farm_Reports_Ingestion/`. Initial commit `d194f7e` on `main`. No remote configured; not pushed.

## Staged artifacts

- `CLAUDE.md` (drafted)
- `README.md`
- `glossary.md` — 4 terms (farm report, sender short-name, sanitised subject, sub-root)
- `docs/adr/0001-sender-allowlist-only.md`
- `docs/adr/0002-folder-layout-sender-first.md`
- `docs/domain/flow-spec.md` — canonical flow contract
- `docs/planning/future-work.md` — 4 items
- `_warehouse/migration-plan.md` — 8-step scaffold plan

## Open ends

None. Concrete SharePoint resource IDs (used by Power Automate connectors) will be picked up at flow-build time, post-`/create-project`.

## Next step

```
/create-project aquna-farm-reports-ingestion
```
