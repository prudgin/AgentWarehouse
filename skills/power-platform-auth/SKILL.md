---
name: power-platform-auth
description: Shared library skill — how to authenticate against the Microsoft Power Platform REST APIs from Linux via Azure CLI. Documents the two REST audiences (Flow vs PowerApps/BAP), one-time pac CLI auth profile, and the tenant-consent gap for SharePoint/Graph. Loaded by flows-*, apps-*, and proxy-flow-scaffolding when they need to authenticate. Auto-mode safe (read-only knowledge skill).
---

# power-platform-auth

How to get a working bearer token for Power Automate, Power Apps, Dataverse, and Graph from Linux. Other skills load this on demand.

This skill is read-only knowledge. It doesn't execute anything itself — `_tools/*.sh` scripts call the underlying `az` commands.

## One-time setup

```bash
az login --allow-no-subscriptions --tenant <tenant-id>
```

`--allow-no-subscriptions` is required for tenants where the user has no Azure subscriptions but has Power Platform / M365 access. Without it, `az login` fails before issuing a token.

`pac` CLI is separate — see `pac-cli-linux`. It needs its own one-time `pac auth create --deviceCode --environment <env-id>` per machine.

## REST audiences

Power Platform splits its REST surface across two audiences. Each requires its own token, acquired by passing a different `--resource` to `az account get-access-token`.

| Audience | `--resource` | Endpoints |
|---|---|---|
| **Flow** | `https://service.flow.microsoft.com/` | `api.flow.microsoft.com/providers/Microsoft.ProcessSimple/...` — flows: list, GET, PATCH definition, run history, trigger callback URL |
| **PowerApps / BAP** | `https://service.powerapps.com/` | `api.powerapps.com/providers/Microsoft.PowerApps/...` (canvas apps) and `api.bap.microsoft.com/providers/Microsoft.BusinessAppPlatform/...` (envs, solutions export/import, package export) |
| **Dataverse (per env)** | `<dv-instance-url>` (e.g. `https://orgXXXX.crmYY.dynamics.com`) | `<dv-instance-url>/api/data/v9.2/...` — solutions, solutioncomponents, canvasapps. The instance URL itself is fetched from BAP via `environments/<env>?api-version=2020-10-01` → `.properties.linkedEnvironmentMetadata.instanceUrl`. |

Idiomatic pattern in this repo's scripts:

```bash
FLOW_TOKEN=$(az account get-access-token --resource https://service.flow.microsoft.com/ --query accessToken -o tsv)
BAP_TOKEN=$(az account get-access-token --resource https://service.powerapps.com/ --query accessToken -o tsv)
```

`flows-export` needs both (Flow for the definition, BAP for the package zip export). `flows-update` needs only Flow. `apps-export` / `apps-update` need BAP, plus Dataverse for the unmanaged-solution wrapper lookup.

## What the default Azure CLI token CANNOT do

The default Azure CLI app registration is **not preauthorized** for SharePoint Online or Microsoft Graph `Sites.*` scopes in most tenants. See [docs/reference/azure-cli-sharepoint-auth.md](../../docs/reference/azure-cli-sharepoint-auth.md) for the failure modes and the one-time `az login --scope "https://graph.microsoft.com/Sites.ReadWrite.All"` consent workaround.

When SharePoint list R/W is needed, the canonical path is **not** direct Graph/REST from Linux. It's a proxy flow (`proxy-flow-scaffolding`) that uses Power Automate's `shared_sharepointonline` connection.

## Scope variants on Flow endpoints

Flow REST endpoints come in two flavours depending on whether the caller is acting as a regular user or as an admin:

- **User scope**: `/providers/Microsoft.ProcessSimple/environments/<env>/flows` — flows you own.
- **Admin scope**: `/providers/Microsoft.ProcessSimple/scopes/admin/environments/<env>/v2/flows` — every flow in the env (requires admin role on the env).

`find-flow.sh` tries both for completeness. `export-flow.sh` / `update-flow.sh` use user scope.

## Token expiry

Azure CLI tokens live ~1 hour. Re-acquire per-script-invocation; don't cache. The `az account get-access-token` call is cheap and idempotent if the cached refresh-token is still valid.

## What lives in `.secrets/`

`.secrets/` holds long-lived tenant-issued secrets — Anthropic API keys and proxy-flow trigger URLs. **Not** Azure tokens (those are CLI-cached). See the project's `## Secrets` section in its CLAUDE.md for the inventory.
