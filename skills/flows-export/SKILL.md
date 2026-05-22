---
name: flows-export
description: Export a Power Automate cloud flow to `flows/<Friendly_Name>/` — produces `flow-definition.json` (raw flow object), `flow-package.zip` (UI-equivalent export package), `flow-package/` (unzipped), and `flow-meta.json` (id + provenance). Wraps `_tools/export-flow.sh`. Use after `flows-discover` (or when you already know env-id + flow-id). Auto-mode safe.
---

# flows-export

Pull a Power Automate flow into the repo as a versioned snapshot. Captures both the raw flow definition (the editable object) and the UI-equivalent `.zip` package (good for re-import via the portal).

This skill writes to the working tree but does **not** auto-commit. The caller (or `flows-update`'s round-trip) is responsible for committing.

## When to invoke

- First time bringing a flow into the repo (e.g. you discovered it via `flows-discover` and want a local copy).
- After a push, to re-snapshot the server-normalised form. The Flow API re-orders JSON keys and adds metadata on PATCH — re-exporting after `flows-update` keeps the working tree's `flow-definition.json` byte-equivalent to what's live.

## Mechanics

```bash
_tools/export-flow.sh <env-id> <flow-id> [out-dir]
```

When `out-dir` is omitted, the folder is named after the flow's display name (sanitized to `[A-Za-z0-9_]`) and placed under `<repo-root>/flows/`.

Output files:

| File | Purpose |
|---|---|
| `flow-definition.json` | Raw GET on the flow object. The editable representation. **This is what you modify** before calling `flows-update`. |
| `flow-package.zip` | UI-equivalent export package — same artifact the portal's "Export → Package (.zip)" produces. Useful for re-importing into another env. |
| `flow-package/` | Unzipped `flow-package.zip` for diff visibility. |
| `flow-meta.json` | `{flowId, envId, displayName, environmentDisplayName, exportedAt}`. Friendly-name folder identification + provenance. |
| `exportPackage.json`, `listPackageResources.json` | API call traces — gitignored, regenerable. |

## Secret scrubbing on export

If the flow has an `Initialize_key_variable` action with a variable named `varClaudeKey` whose value matches `^sk-ant-`, the script rewrites it to `__ANTHROPIC_API_KEY_PLACEHOLDER__` before writing `flow-definition.json`. This prevents live Anthropic keys leaking into git.

Adding new placeholder rules: edit the `SCRUBBED=$(jq …)` block in `_tools/export-flow.sh` and pair it with a matching `resolve_placeholder` call in `_tools/update-flow.sh` so the substitution round-trips.

## Auth

Needs Flow + BAP tokens. See [power-platform-auth](../power-platform-auth/SKILL.md).

## What gets gitignored

`flow-package/`, `flow-package.zip`, `exportPackage.json`, `listPackageResources.json`, `exportPackage.request.json`, `diagnose.sh`, `export-flow.sh` are all regenerable noise. The project `.gitignore` should exclude `flows/*/flow-package/`, `flows/*/flow-package.zip`, `flows/*/exportPackage.json`, `flows/*/listPackageResources.json`. Only `flow-definition.json` + `flow-meta.json` are committed.

## Round trip

```
flows-discover <query>       # find env-id + flow-id
flows-export <env> <flow>    # snapshot to flows/<Name>/
edit flow-definition.json    # ... your changes
flows-update flows/<Name>/   # PATCH back
flows-export <env> <flow> flows/<Name>/  # optional: re-snapshot to capture API normalisation
```
