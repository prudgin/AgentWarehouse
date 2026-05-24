---
name: flows-export
description: Export a Power Automate cloud flow to `flows/<Friendly_Name>/` — produces `flow-definition.json` (raw flow object), `flow-package.zip` (UI-equivalent export package), `flow-package/` (unzipped), and `flow-meta.json` (id + provenance). Scrubs resolved secrets back to placeholders before writing to disk. Wraps `_tools/export-flow.sh`. Use after `flows-discover` (or when you already know env-id + flow-id). Auto-mode safe.
---

# flows-export

Pull a Power Automate flow into the repo as a versioned snapshot. Captures both the raw flow definition (the editable object) and the UI-equivalent `.zip` package (good for re-import via the portal or another env).

There is **no `pac flow export` command** — exports go through the Power Automate / BAP REST APIs directly. See [pac-cli-linux](../pac-cli-linux/SKILL.md).

## When to invoke

- First time bringing a flow into the repo.
- After a push, to re-snapshot the server-normalised form. The Flow API re-orders JSON keys and adds metadata on PATCH — re-exporting after `flows-update` keeps the working tree's `flow-definition.json` byte-equivalent to what's live.

## Prereqs

1. [`power-platform-auth`](../power-platform-auth/SKILL.md) — `az login` good for the right tenant.
2. Know the **env id**. If unsure, run [`flows-discover`](../flows-discover/SKILL.md).

## Tool

```bash
_tools/export-flow.sh <env-id> <flow-id> [out-dir]
```

When `out-dir` is omitted, the folder is named after the flow's display name (sanitized to `[A-Za-z0-9_]`) and placed under `<repo-root>/flows/`. Folders are named by friendly display name; the original GUIDs go in `flow-meta.json` — do **not** name folders by GUID.

Output:

| File | Purpose |
|---|---|
| `flow-meta.json` | `{flowId, envId, displayName, environmentDisplayName, exportedAt}`. Friendly-name folder identification + provenance. |
| `flow-definition.json` | Raw GET on the flow object. `.properties.definition` is the Logic Apps definition; `.connectionReferences` + `.referencedResources` describe dependencies. Resolved secrets are scrubbed back to placeholders before this file lands — see "Secret scrubbing". This is what you modify before calling `flows-update`. |
| `flow-package.zip` | Importable UI-equivalent package. The .zip's embedded definition contains the live secret unredacted; **the .zip is gitignored** for this reason. |
| `flow-package/` | Unzipped contents — `manifest.json` + `Microsoft.Flow/flows/<internal-id>/{definition,apisMap,connectionsMap}.json`. Also gitignored. |
| `listPackageResources.json`, `exportPackage.json` | Raw API responses, kept for debugging. Gitignored. |

The project `.gitignore` should exclude `flows/*/flow-package/`, `flows/*/flow-package.zip`, `flows/*/exportPackage.json`, `flows/*/listPackageResources.json`, `flows/*/exportPackage.request.json`. Only `flow-definition.json` + `flow-meta.json` are committed.

## Secret scrubbing

Power Automate stores variable initializer values as plaintext, so a raw GET of the flow returns live API keys inside `properties.definition.actions.Initialize_key_variable.inputs.variables[].value`. To keep those out of the working tree and git history, the script post-processes the downloaded JSON: any variable whose value matches a known resolved-secret pattern is rewritten back to its `__<NAME>_PLACEHOLDER__` sentinel **before** the file lands on disk.

Default scrub rule: `varClaudeKey` values matching `^sk-ant-` → `__ANTHROPIC_API_KEY_PLACEHOLDER__`. The script prints `scrubbed N resolved secret(s) back to placeholder` when this fires. This is the exact inverse of the substitution done by `_tools/update-flow.sh` at push time — see [anthropic-api-integration](../anthropic-api-integration/SKILL.md) for the full round-trip.

**When adding a new placeholder-bearing variable**: extend the `jq` scrub block in `_tools/export-flow.sh` AND add a matching `resolve_placeholder` call in `_tools/update-flow.sh`. The two scripts must stay symmetric, or the next export will leak the new secret into the working tree.

## What the script does (debugging notes)

The export is a four-part REST dance against two different audiences. This section is for when something fails.

1. **GET flow definition** — `https://api.flow.microsoft.com/providers/Microsoft.ProcessSimple/environments/<env>/flows/<flow>` with the **Flow** audience. Returns the raw flow JSON.
2. **Discover the regional BAP endpoint** — same env GET, read `.properties.runtimeEndpoints["microsoft.BusinessAppPlatform"]` (e.g. `https://australia.api.bap.microsoft.com`). The packaging API is **regional** — the global `api.bap.microsoft.com` returns 404.
3. **POST `listPackageResources`** — to `<bap-region>/providers/Microsoft.BusinessAppPlatform/environments/<env>/listPackageResources` with the **PowerApps** audience (`https://service.powerapps.com/`). Body: `{"baseResourceIds":["/providers/Microsoft.Flow/flows/<id>"]}`. Returns a `resources` dictionary keyed by base64-encoded resource paths.
4. **POST `exportPackage`** — same BAP base, body containing `includedResourceIds`, `details`, `resources`. Returns `packageLink.value` (SAS URL); GET that to download the zip.

## Gotchas (the four things that break)

If `export-flow.sh` regresses, check these first:

1. **Wrong endpoint host** — the package APIs are **not** on `api.flow.microsoft.com`. They're on the env's regional BAP endpoint.
2. **Wrong token audience** — BAP rejects the Flow-audience token with `403 InvalidPath`. Use `https://service.powerapps.com/` for BAP, `https://service.flow.microsoft.com/` for Flow.
3. **`includedResourceIds` content** — must be the actual resource id strings (`/providers/Microsoft.Flow/flows/<id>`), **not** the base64 keys returned by `listPackageResources`. Passing the keys triggers `400 ProviderNamespaceUnsupported`.
4. **`creationType` per resource** — set to `Update` for the flow itself (`type == "Microsoft.Flow/flows"`) and `Existing` for connectors/connections. The script sets both `suggestedCreationType` and `creationType` to be safe across API versions.

## When the script fails

- `404` on the GET flow → wrong env id. Use `flows-discover`.
- `403 EnvironmentAccessDenied` → user is not a maker on this env. Get owner to share, or use admin scope (requires tenant admin).
- `400 ProviderNamespaceUnsupported` → `includedResourceIds` regression (gotcha #3).
- `403 InvalidPath` → audience regression (gotcha #2).

## Round trip

```
flows-discover <query>       # find env-id + flow-id
flows-export <env> <flow>    # snapshot to flows/<Name>/
edit flow-definition.json    # ... your changes
flows-update flows/<Name>/   # PATCH back
flows-export <env> <flow> flows/<Name>/  # optional: re-snapshot to capture API normalisation
```
