# Reference

What the warehouse contains and how it's organised. Source of truth is the actual `templates/` and `skills/` directories — these docs describe what is currently there.

Update after adding/removing/changing a template or skill.

## Index

- [templates.md](templates.md) — inventory of project templates (`templates/<type>/`).
- [skills.md](skills.md) — inventory of skills (`skills/<name>/`).

### Power Platform integration — relocated

The Power Platform reference docs (`powerapps-gotchas.md`, `azure-cli-sharepoint-auth.md`, `pac-canvas-deprecation.md`) and the matching skill bundle are no longer here. They were relocated to their sole consumer, `~/MicrosoftFlowsApps` (`docs/reference/` + `.claude/skills/`), on 2026-06-16 — single consumer, no second in prospect. See [ADR-0025](../adr/0025-power-platform-bundle-lives-with-its-consumer.md).
