---
name: power-platform-auth
description: Shared library skill — how to authenticate against Microsoft Power Platform REST APIs (Power Automate, Power Apps, BAP, Dataverse) and Graph from Linux via Azure CLI. Documents the two REST audiences, the `--allow-no-subscriptions` requirement, common 4xx causes, and the tenant-consent gap for SharePoint/Graph. Loaded by `flows-*`, `apps-*`, and `proxy-flow-scaffolding` when they need to authenticate. Auto-mode safe (read-only knowledge).
---

# power-platform-auth

This is a **library skill** — task skills (`flows-discover`, `flows-export`, etc.) reference it. It does not perform a task on its own.

## One-time login

```bash
az login --allow-no-subscriptions --tenant <tenant-id>
```

`--allow-no-subscriptions` is **required** for tenants that have no Azure subscription attached (Power Platform tenants typically don't). Without it, `az login` finalizes "successfully" but no credentials are written and every later `get-access-token` call fails with `Please run 'az login' to setup account.`

If a login already exists, `az account show` should return a `tenant-level account` row for the right tenant.

`pac` CLI is a separate auth surface — see [pac-cli-linux](../pac-cli-linux/SKILL.md).

## Two audiences, two tokens

Power Platform splits its REST surface across audiences. **A token for one will not work on the other.**

| Audience (`--resource`) | What it's for | Endpoints |
|---|---|---|
| `https://service.flow.microsoft.com/` | Flows: list, GET, PATCH definition, run history, trigger callback URL | `api.flow.microsoft.com/providers/Microsoft.ProcessSimple/...` |
| `https://service.powerapps.com/` | Canvas apps + BAP packaging (`listPackageResources`, `exportPackage`, `importPackage`) | `api.powerapps.com/providers/Microsoft.PowerApps/...` and `<region>.api.bap.microsoft.com/providers/Microsoft.BusinessAppPlatform/...` |
| `<dv-instance-url>` (per env) | Dataverse — solutions, solutioncomponents, canvasapps | `<dv-instance-url>/api/data/v9.2/...` |

The Dataverse instance URL is fetched from BAP:

```bash
DV_URL=$(curl -sS -H "Authorization: Bearer $BAP_TOKEN" \
  "https://api.bap.microsoft.com/providers/Microsoft.BusinessAppPlatform/scopes/admin/environments/$ENV_ID?api-version=2020-10-01" \
  | jq -r '.properties.linkedEnvironmentMetadata.instanceUrl' | sed 's|/$||')
DV_TOKEN=$(az account get-access-token --resource "$DV_URL" --query accessToken -o tsv)
```

Idiomatic two-token grab:

```bash
FLOW_TOKEN=$(az account get-access-token --resource https://service.flow.microsoft.com/ --query accessToken -o tsv)
BAP_TOKEN=$(az account get-access-token --resource https://service.powerapps.com/ --query accessToken -o tsv)
```

`flows-export` needs both. `flows-update` needs Flow only. `apps-export` needs BAP (+ Dataverse opportunistically). `apps-update` needs BAP + Dataverse.

## What the default Azure CLI token CANNOT do

The default Azure CLI app registration is **not preauthorized** for SharePoint Online or Microsoft Graph `Sites.*` scopes in most tenants. See [docs/reference/azure-cli-sharepoint-auth.md](../../docs/reference/azure-cli-sharepoint-auth.md) for the failure modes and the one-time `az login --scope "https://graph.microsoft.com/Sites.ReadWrite.All"` consent workaround.

When SharePoint list R/W is needed, the canonical path is **not** direct Graph/REST from Linux. It's a proxy flow ([proxy-flow-scaffolding](../proxy-flow-scaffolding/SKILL.md)) that uses Power Automate's `shared_sharepointonline` connection.

## Scope variants on Flow endpoints

Flow REST endpoints come in two flavours:

- **User scope** — `/providers/Microsoft.ProcessSimple/environments/<env>/flows` — flows you own.
- **Admin scope** — `/providers/Microsoft.ProcessSimple/scopes/admin/environments/<env>/v2/flows` — every flow in the env; requires admin role.

`find-flow.sh` tries both for completeness. `export-flow.sh` / `update-flow.sh` use user scope.

## Common 4xx → cause

- `401 InvalidAuthenticationAudience` (listing allowed audiences) → token issued for wrong resource. Re-run `get-access-token` with the right `--resource`.
- `403 InvalidPath` with `does not have permission to call route ...` → audience mismatch (BAP route called with Flow token, or vice versa).
- `Please run 'az login' to setup account` after login appeared to succeed → tenant has no subscriptions; missing `--allow-no-subscriptions`.
- `403 EnvironmentAccessDenied` on a `scopes/admin/...` URL → user is not a Power Platform tenant admin. Use the user-scope URL (drop `scopes/admin/`) and confirm the user owns or is shared on the resource.

## Decoding a token (debugging)

```bash
echo "$TOKEN" | awk -F. '{print $2}' | { tr '_-' '/+'; printf '=='; } | base64 -d 2>/dev/null \
  | jq '{upn, tid, oid, aud, scp}'
```

Useful when a 4xx is ambiguous — confirms the user, tenant, and audience the token actually represents.

## Token expiry

Azure CLI tokens live ~1 hour. Re-acquire per-script-invocation; don't cache. The `az account get-access-token` call is cheap and idempotent if the cached refresh-token is still valid.

## Project-specific bits live in the project

The project's `CLAUDE.md` records the tenant ID, the `pac` auth profile name (e.g. `wq-prod` for one env), and any per-app solution-wrapper names. The skill stays generic; the project carries the specifics.
