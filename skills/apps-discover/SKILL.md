---
name: apps-discover
description: Find which Power Platform environment a canvas app lives in. Searches every env the current `az login` can see for apps whose id or displayName matches a query (case-insensitive substring). Wraps `_tools/find-app.sh`. Use before `apps-export` when you don't know the env id. Auto-mode safe (read-only).
---

# apps-discover

Search every Power Apps environment visible to the current `az login` for canvas apps matching an id or name substring. Returns env id, env display name, app id, app display name, owner email.

This skill is read-only and auto-mode safe.

## When to invoke

Before `apps-export`, when you have an app name fragment but not the env id. Once you have a per-app folder under `apps/<Friendly_Name>/`, `app-meta.json` already records `appId` and `envId`.

## Mechanics

```bash
_tools/find-app.sh <app-id-or-name-substring>
```

Match is case-insensitive substring against both `name` (the GUID) and `properties.displayName`. Returns one block per match:

```
env: <env-id>  (<env display name>)
  app : <app-id>  <display name>
  owner: <owner-email>
```

Exit code: 0 if matches, 2 if none.

## Auth

PowerApps + BAP both accept the same token audience (`https://service.powerapps.com/`). See [power-platform-auth](../power-platform-auth/SKILL.md). Env enumeration uses admin scope; falls through cleanly if the caller is non-admin.

## What to do with the result

Stash `(envId, appId)`. Pass `appId` to `apps-export` (env is auto-derived from the app object).
