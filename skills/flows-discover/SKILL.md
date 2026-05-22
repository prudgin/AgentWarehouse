---
name: flows-discover
description: Find which Power Automate environment a cloud flow lives in and what regional BAP endpoint to use. Searches every env the current `az login` can see, in both user-scope and admin-scope. Wraps `_tools/find-flow.sh`. Use when you have a flow id or name fragment but don't know its env. Auto-mode safe (read-only).
---

# flows-discover

Search every Power Automate environment visible to the current `az login` for flows matching an id or name substring. Returns env id, env display name, flow id, flow display name, regional BAP endpoint, and which scope (user vs admin) found the flow.

This skill is read-only and auto-mode safe.

## When to invoke

Before `flows-export` or `flows-update`, when you don't already know `<env-id>` and `<flow-id>` for the target flow. Once you have a per-flow folder under `flows/<Friendly_Name>/`, its `flow-meta.json` already records `flowId` and `envId` — no need to discover again.

## Mechanics

```bash
_tools/find-flow.sh <flow-id-or-name-substring>
```

Match is **case-insensitive substring** against both `name` (the GUID) and `properties.displayName`. Returns one block per match:

```
env: <env-id>  (<env display name>)
  flow: <flow-id>  <display name>
  bap : <regional BAP endpoint, e.g. https://australia.api.bap.microsoft.com>
  scope: user|admin-scope
```

Exit code: 0 if matches, 2 if none.

## Why two scopes

Flow REST splits surface between user-scope (flows you own) and admin-scope (every flow in the env; requires env admin role). The script tries both for completeness — sometimes a flow you can edit in the UI shows up only via admin-scope because of an obscure shared-ownership state. Always trust the first match.

## Auth

Needs `az login` to be active. Uses Flow audience (`https://service.flow.microsoft.com/`). See [power-platform-auth](../power-platform-auth/SKILL.md).

## What to do with the result

Stash `(envId, flowId)` for downstream skills. If you intend to export, pass them to `flows-export`, which will write a `flow-meta.json` recording them in a friendly-named folder so subsequent edits never need a fresh discover call.
