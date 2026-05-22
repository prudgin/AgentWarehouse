---
name: proxy-flow-scaffolding
description: Scaffold a new HTTP-triggered Power Automate proxy flow as a 4-piece set — flow folder + `.secrets/<name>-proxy-url` + `_tools/<name>.sh` helper + CLAUDE.md section. The HTTP-trigger URL itself is the bearer credential. Used to give Linux/CLI access to Power Platform connectors that aren't reachable directly via Graph (e.g. SharePoint Online list R/W, Outlook send). Use when the user asks for a new "proxy flow" or wants Linux access to a Power Platform connector. Auto-mode safe.
---

# proxy-flow-scaffolding

When Linux can't reach a Power Platform connector directly (because Azure CLI tokens lack the right consent — see [docs/reference/azure-cli-sharepoint-auth.md](../../docs/reference/azure-cli-sharepoint-auth.md)), the workaround is an HTTP-triggered Power Automate flow that uses Power Automate's own pre-authorized connection on the caller's behalf. This skill scaffolds the four pieces together.

## The pattern

Every proxy flow in this convention has the same four parts. Don't skip any — if the helper or docs are missing, the affordance is invisible to the next agent.

| Piece | Path | Purpose |
|---|---|---|
| **Flow folder** | `flows/<Friendly_Name>/` | Standard `flows-export` output: `flow-meta.json`, `flow-definition.json`, `flow-package.zip`, `flow-package/`. Same shape as any other flow. |
| **Trigger URL secret** | `.secrets/<name>-proxy-url` (mode 600) | The HTTP-trigger callback URL with `sig=...` query param. **The URL itself is the bearer credential** — anyone with it can invoke the flow with the connection's privileges. Fetch via `listCallbackUrl` API; never commit; never echo into logs. |
| **Helper script** | `_tools/<name>.sh` | Bash wrapper: reads URL from `.secrets/`, takes flag args, builds JSON body with `jq`, `curl`s the endpoint, prints raw JSON to stdout. Mirrors the shape of `_tools/wq-read-list.sh` and `_tools/send-email-rnd.sh`. Make executable. |
| **CLAUDE.md updates** | project root `CLAUDE.md` | Add helper to the `_tools/` tree diagram. Add secret to the `## Secrets` list. Add a dedicated `## <Proxy Name>` section explaining JSON contract + response codes. |

## When to invoke

The user says any of:
- "make a proxy flow for X"
- "give me Linux access to <Power Platform connector>"
- "wrap <connector> in an HTTP flow"

Or you discover during work that a desired Power Platform action can't be reached from Linux and a proxy is the cleanest path.

## Workflow

1. **Portal step (one-time per proxy)** — in the maker portal, create a new instant cloud flow with the "When an HTTP request is received" trigger. Add the connector action(s) you need (SharePoint, Outlook, etc.). Save. Run once to authorize the connection.

2. **Discover and export** the empty shell into the repo:
   ```bash
   _tools/find-flow.sh <new-flow-name>
   _tools/export-flow.sh <env-id> <flow-id>
   ```

3. **Fetch the trigger URL** via `listCallbackUrl`:
   ```bash
   FLOW_TOKEN=$(az account get-access-token --resource https://service.flow.microsoft.com/ --query accessToken -o tsv)
   curl -sS -X POST -H "Authorization: Bearer $FLOW_TOKEN" \
     "https://api.flow.microsoft.com/providers/Microsoft.ProcessSimple/environments/<env-id>/flows/<flow-id>/triggers/manual/listCallbackUrl?api-version=2016-11-01" \
     | jq -r .response.value > .secrets/<name>-proxy-url
   chmod 600 .secrets/<name>-proxy-url
   ```

4. **Write the helper script** `_tools/<name>.sh`. Skeleton:
   ```bash
   #!/usr/bin/env bash
   set -euo pipefail
   URL="$(cat "$(dirname "$0")/../.secrets/<name>-proxy-url")"
   BODY=$(jq -n --arg foo "$FOO" '{foo: $foo}')
   curl -sS -X POST -H "Content-Type: application/json" -d "$BODY" "$URL"
   ```
   Add flag parsing, JSON body assembly, error reporting (HTTP status check) as the proxy's contract requires.

5. **Document** in project `CLAUDE.md`: secrets list entry, tree-diagram entry under `_tools/`, dedicated section spelling out the JSON contract (request schema + response codes).

6. **Iterate the flow logic** by editing `flows/<Name>/flow-definition.json` and pushing via `flows-update`. Re-export to capture API normalization.

## Connection reuse

If a sibling proxy already authorizes the connector you need (`shared_office365`, `shared_sharepointonline`, etc.), copy the `connectionReferences` entry verbatim into the new flow's `flow-definition.json` — the connection ID is tenant/env-scoped and the same connection works across flows owned by the same user. No fresh authorization needed.

## Scope discipline

A proxy is a tiny pre-authorized API. Keep its surface narrow:

- **Read-only first.** Add write ops by extending an `op` switch (see `wq-read-list.sh`'s `--op lists` pattern). Don't make a proxy that can both read and write the same resource unless that combination is the point.
- **Site/mailbox-scoped.** A SharePoint read proxy bound to one site cannot reach others — that's a feature. Don't generalize across sites in one proxy; make a separate proxy per scope.
- **Treat the URL as a real secret.** It's not a token with TTL; it doesn't rotate. Anyone with the URL can invoke the flow as the connection owner until the trigger is regenerated.

## Examples in the wild

- `flows/WQ_Reader_Proxy/` + `_tools/wq-read-list.sh` — reads any list on the WaterQuality SharePoint site (workaround for SharePoint REST being unreachable from Linux).
- `flows/Send_Email_To_RnD_Manager_Proxy/` + `_tools/send-email-rnd.sh` — sends email via Office 365 Outlook (default recipient `alexa@aquna.com`).
