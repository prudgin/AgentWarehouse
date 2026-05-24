---
name: flows-discover
description: Find which Power Automate environment a cloud flow lives in. Searches every env the current `az login` can see, in both user-scope and admin-scope, for flows whose id or display-name substring matches. Prints env id, env display name, flow id, flow display name, regional BAP endpoint, and the scope under which the flow was found. Wraps `_tools/find-flow.sh`. Use this before `flows-export` to confirm an env id, or whenever you have a flow id or name fragment but don't know its env. Auto-mode safe (read-only).
---

# flows-discover

Search every Power Automate environment visible to the current `az login` for flows matching an id or name substring.

This skill is read-only and auto-mode safe.

## When to invoke

Before `flows-export` or `flows-update`, when you don't already know `<env-id>` and `<flow-id>` for the target flow. Power Platform tenants commonly contain several environments (Default, per-user developer envs, sandbox/prod), and the same flow id will 404 against the wrong env.

Once you have a per-flow folder under `flows/<Friendly_Name>/`, its `flow-meta.json` already records `flowId` and `envId` — no need to discover again.

## Prereq

Load [`power-platform-auth`](../power-platform-auth/SKILL.md) first and ensure `az login` has succeeded for the right tenant.

## Tool

```bash
_tools/find-flow.sh <flow-id-or-name-substring>
```

Match is **case-insensitive substring** against both `name` (the GUID) and `properties.displayName`. Returns one block per match:

```
env: <env-id>     (<env display name>)
  user-scope | admin-scope
  flow: <flow-id>  <flow display name>
  bap : https://<region>.api.bap.microsoft.com
  scope: user | admin
```

Exit code: 0 if matches, 2 if none.

The `bap` URL is the env's regional BAP base — `flows-export` needs it (auto-discovers from env metadata, but knowing the region helps when debugging).

## Why two scopes

Flow REST splits surface between **user scope** (flows the current user owns or is shared on) and **admin scope** (every flow in the env; requires Power Platform tenant admin role). The script tries both — sometimes a flow you can edit in the UI shows up only via admin-scope because of an obscure shared-ownership state. Trust the first match.

A flow that appears **only** under admin-scope means you're an admin but not a maker on it — exports will need admin scope, or the flow's owner has to share it with you first.

## When no matches return

A flow with no matches in any environment usually means:

- Wrong tenant logged into `az` — check with `az account show`.
- The flow was deleted.
- The query substring is too narrow (try shorter).

## What to do with the result

Stash `(envId, flowId)`. Pass them to `flows-export`, which writes a `flow-meta.json` recording them in a friendly-named folder so subsequent edits never need a fresh discover call.
