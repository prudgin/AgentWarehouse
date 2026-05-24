---
name: apps-export
description: Export a Power Apps canvas app to `apps/<Friendly_Name>/` — produces `app-meta.json`, `app-definition.json`, `app.msapp`, and `src/` (unpacked editable YAML via `pac canvas unpack`). Wraps `_tools/export-app.sh`. Use after `apps-discover` (or when you know `appId`). Companion to `apps-update` which pushes edits back via an unmanaged-solution wrapper. Auto-mode safe.
---

# apps-export

Pull a canvas app into the repo as a versioned snapshot. Captures the raw app metadata, the `.msapp` binary, and an editable `src/` tree of `.fx.yaml` files (one per screen/control) produced by `pac canvas unpack`.

This skill writes to the working tree but does **not** auto-commit.

## When to invoke

- First time bringing a canvas app into the repo.
- After a push via `apps-update`, to re-snapshot the server state.

## Prereqs

1. [`power-platform-auth`](../power-platform-auth/SKILL.md) — `az login` good for the right tenant.
2. [`pac-cli-linux`](../pac-cli-linux/SKILL.md) — uses `pac canvas unpack` to materialise sources.
3. Know the **app id**. If unsure, run [`apps-discover`](../apps-discover/SKILL.md).

## Tool

```bash
_tools/export-app.sh <app-id> [out-dir]
```

When `out-dir` is omitted, the folder is named after the app's display name (sanitized) and placed under `<repo-root>/apps/`. Provenance lives in `app-meta.json`.

Output:

| File | Purpose |
|---|---|
| `app-meta.json` | `{appId, envId, displayName, environmentDisplayName, exportedAt, isManaged, solutionUniqueName}`. The `isManaged` and `solutionUniqueName` fields come from a best-effort Dataverse lookup — null if the env has no Dataverse instance or auth fails. |
| `app-definition.json` | Raw GET on the app object, with all rotating SAS URLs stripped (`appUris.*`, `backgroundImageUri`, `teamsColorIconUrl`, `teamsOutlineIconUrl`). Without stripping, every export churns the diff and leaks read-only blob credentials into git history. |
| `app.msapp` | Downloaded via the `documentUri` SAS. **Gitignore this** — regenerable from `src/` via `pac canvas pack`. |
| `src/` | `pac canvas unpack` output: `Src/*.fx.yaml` per screen, `Assets/`, `Connections/`, `DataSources/`, `Entropy/`, `Other/`, `pkgs/`, plus `CanvasManifest.json`, `ComponentReferences.json`, `ControlTemplates.json`. |

Project `.gitignore` should include `apps/*/app.msapp`.

## Why both `.msapp` and `src/`?

`src/` is what humans (and agents) edit — `.fx.yaml` is line-diffable. `.msapp` is the format Power Apps accepts back. `apps-update` repacks `src/` → `.msapp` before pushing.

The `.msapp` is gitignored because it's a binary opaque to diff and fully regenerable. Treat `src/` as the source of truth.

## What the script does

1. **GET app metadata** — `https://api.powerapps.com/providers/Microsoft.PowerApps/apps/<appId>` with the **PowerApps** audience. Returns the app object including `properties.appUris.documentUri.value`, a SAS URL pointing at the .msapp blob in Azure Storage.
2. **Resolve env display name + Dataverse URL** — same audience, BAP admin-scope env GET.
3. **Best-effort: query Dataverse** for `canvasapps.ismanaged` and the related solution `uniquename`, to record managed/unmanaged status in the meta. Tokens are acquired against the env-specific Dataverse URL (separate audience). Failures here are non-fatal — meta fields stay `null`.
4. **GET .msapp** via the SAS URL. The SAS in `documentUri.value` has `sp=rl` (read+list) — works for download but not upload.
5. **`pac canvas unpack`** — extract the `.msapp` to a YAML source tree.

## SAS quirk

`documentUri.value` is short-lived (~5 days from the `se=` query param). If the .msapp download 403s, GET the app metadata again — the API issues a fresh SAS each call.

## "Active" solution in meta

Dataverse stores every canvas app row under the system-internal `Active` "solution" pseudo-bucket; the original managed solution is recorded separately in `solutioncomponent`/`msdyn_solutioncomponentsummary`. So `solutionUniqueName: "Active"` in `app-meta.json` does **not** mean the app is solutionless — it just means we read the live row, not the import history. Treat as a hint, not authoritative.

## Push gap (why `apps-update` goes through a solution)

`pac canvas` has `download`, `unpack`, `pack`, `validate`, `create` — and **no `upload`**. Microsoft has not shipped a Linux-friendly way to push a modified `.msapp` back to a standalone canvas app. The known options, in order of supportability:

1. **Solution-based push** *(supported, requires a one-time UI step)*. Add the canvas app to a *new unmanaged* Dataverse solution in the maker portal. Then on Linux: `pac solution export → swap the .msapp inside the solution zip → pac solution import`. The unmanaged solution becomes a layer on top of any managed import. This is what [`apps-update`](../apps-update/SKILL.md) implements.
2. **Maker-portal manual upload** — Power Apps Studio has no "import .msapp into existing app" UI. You'd have to create a new app from the file and re-share — losing the existing app id, share list, and runs. Generally a no-go.
3. **Direct REST upload** — Power Apps Studio uses an internal endpoint to PUT new .msapp blobs. Undocumented; community guesses (`/uploadDocument`, `/document`, `/generateResourceStorage`, `/uploadResource`, `/createDocumentUpload`, `/document/createUploadResource`) all 404 against the public BAP/PowerApps surface as of this writing. Reverse-engineering Studio's network traffic is the only way to find the real endpoint, and any push tooling built on it would be brittle.

Use (1).

## Deprecation

`pac canvas unpack` is marked deprecated by pac 2.6.4 with no shipped replacement. Track in [docs/reference/pac-canvas-deprecation.md](../../docs/reference/pac-canvas-deprecation.md). When it goes away, both `apps-export` and `apps-update` need new mechanics.

## When the script fails

- `404` on the GET app → wrong app id, or no access in this env.
- `403` on the SAS download → SAS expired or revoked. Re-run `export-app.sh` to refresh.
- `pac canvas unpack` errors → usually a corrupt `.msapp` (re-download) or a pac/.NET runtime version mismatch (see [`pac-cli-linux`](../pac-cli-linux/SKILL.md)).
