---
name: apps-discover
description: Find which Power Platform environment a canvas app lives in. Searches every env the current `az login` can see for canvas apps whose id or display-name substring matches. Wraps `_tools/find-app.sh`. Use before `apps-export` when you don't know the env id. Canvas apps only — model-driven apps live inside Dataverse solutions. Auto-mode safe (read-only).
---

# apps-discover

Search every Power Apps environment visible to the current `az login` for canvas apps matching an id or name substring. Same shape as `flows-discover` but for canvas apps.

This skill is read-only and auto-mode safe.

## When to invoke

Before `apps-export`, when you have an app name fragment but not the env id. Once you have a per-app folder under `apps/<Friendly_Name>/`, `app-meta.json` already records `appId` and `envId`.

## Prereq

Load [`power-platform-auth`](../power-platform-auth/SKILL.md) first and ensure `az login` is good for the right tenant.

## Tool

```bash
_tools/find-app.sh <app-id-or-name-substring>
```

Output for each match:

```
env: <env-id>     (<env display name>)
  app : <app-id>  <app display name>
  owner: <owner-email>
```

Exit code: 0 if matches, 2 if none.

## Notes

- Uses the **PowerApps** audience (`https://service.powerapps.com/`) for both env enumeration and the per-env app list. Unlike flows, there's no separate Flow audience to juggle.
- The script enumerates envs via the BAP `scopes/admin/environments` endpoint. If the user is **not** a Power Platform tenant admin, that endpoint returns a subset (envs the user has at least Maker access to). It will not silently miss the user's own environments — you only lose visibility into other people's envs.

## Canvas apps only

**Model-driven apps live entirely inside Dataverse solutions** — they are not enumerable through the PowerApps `apps` REST endpoint. To find one, query the `appmodule` table on the org's Dataverse Web API:

```bash
DV_URL=<env-dataverse-url>
DV_TOKEN=$(az account get-access-token --resource "$DV_URL" --query accessToken -o tsv)
curl -sS -H "Authorization: Bearer $DV_TOKEN" -H "OData-Version: 4.0" -H "Accept: application/json" \
  "$DV_URL/api/data/v9.2/appmodules?\$filter=contains(name,'<query>')"
```

Or use `pac solution export` against the containing solution and read the model-driven app XML inside. There is currently no warehouse skill for model-driven app discovery — write one if a project needs it.
