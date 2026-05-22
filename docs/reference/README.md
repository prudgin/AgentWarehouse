# Reference

What the warehouse contains and how it's organised. Source of truth is the actual `templates/` and `skills/` directories — these docs describe what is currently there.

Update after adding/removing/changing a template or skill.

## Index

- [templates.md](templates.md) — inventory of project templates (`templates/<type>/`).
- [skills.md](skills.md) — inventory of skills (`skills/<name>/`).

### Power Platform integration

Reference material for `tool-integration` projects targeting Microsoft Power Platform. Loaded by the matching skills (`flows-*`, `apps-*`, `proxy-flow-scaffolding`, `power-platform-auth`).

- [azure-cli-sharepoint-auth.md](azure-cli-sharepoint-auth.md) — Azure CLI default tokens cannot reach SharePoint/Graph list endpoints in most tenants; one-time `Sites.ReadWrite.All` consent workaround.
- [powerapps-gotchas.md](powerapps-gotchas.md) — `Concurrent` same-source refusal, `Select` fire-and-forget, `pac canvas pack` PA2001 / PA3003 errors.
- [pac-canvas-deprecation.md](pac-canvas-deprecation.md) — `pac canvas unpack/pack` deprecation watch and mitigation options.
