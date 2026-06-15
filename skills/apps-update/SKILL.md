---
name: apps-update
description: Push edits to a canvas app's `src/` back to Power Apps via the unmanaged-solution route (`pac solution export → swap .msapp → pac solution import`). Requires a one-time portal step per app to wrap it in an unmanaged Dataverse solution. Wraps `_tools/update-app.sh`. Auto-commits the per-app folder after a successful push. Use after editing `apps/<Name>/src/`. Auto-mode safe (local commit only).
---

# apps-update

Push edits to a canvas app's source tree back to Power Apps. Goes via an unmanaged Dataverse solution because there is no public REST endpoint for pushing a standalone canvas app on Linux (see [`apps-export`](../apps-export/SKILL.md) "Push gap").

## When to use

The user has modified `src/` under an exported canvas-app folder and wants the change live. Examples:

- Tweaking a `Fill` expression, a label `Text`, or a `Visible` rule in a `.fx.yaml`.
- Renaming a control, adjusting a layout, editing screen-level logic.
- Swapping a data source name (in `DataSources/` + screen yamls).

**Don't use this for:**

- Cross-env migration. This pushes back to the *same* env the app was exported from. For dev→prod, use `pac solution export` + import to a different env separately.
- An app that hasn't been wrapped in an unmanaged solution yet — the script says so and exits.

## One-time setup (per app, in the portal)

Microsoft's solution mechanic is the only supported push path. Before this skill works on a given app, the app must be wrapped in an unmanaged Dataverse solution in the same env:

1. Maker portal → target env → Solutions → New solution → unmanaged. Convention name: `<app-name>_unmanaged`.
2. Add → existing → app → pick the canvas app.

The unmanaged layer sits on top of any managed import without disturbing it. From then on, everything is Linux-side. Project root `CLAUDE.md` should record the wrapper name in a "Pac profiles + wrappers" table (one row per app).

## Prereqs

1. [`power-platform-auth`](../power-platform-auth/SKILL.md) — `az login` good for the right tenant. The script also needs a Dataverse token, which `az account get-access-token --resource <org-url>` produces automatically.
2. [`pac-cli-linux`](../pac-cli-linux/SKILL.md) — a `pac` auth profile pointing at the target env must exist (one-time):
   ```bash
   pac auth create --name <profile> --deviceCode --environment <env-id>
   ```
3. The app folder under `apps/` must already have `app-meta.json` (from `apps-export`) and an edited `src/` tree.

## Tool

```bash
_tools/update-app.sh <app-dir> [--solution NAME] [--no-commit]
```

`<app-dir>` must contain `app-meta.json` (`{appId, envId, ...}` from `apps-export`) and `src/` (the edited source tree).

Sequence:

1. Read `appId`, `envId`, `displayName` from `app-meta.json`.
2. Resolve the Dataverse URL for the env (BAP `environments/<env>` → `.properties.linkedEnvironmentMetadata.instanceUrl`) and acquire BAP + Dataverse tokens.
3. **Find the unmanaged wrapper solution.** Query Dataverse `solutioncomponents` where `objectid=appId AND componenttype=300 AND solutionid.ismanaged=false`. **Excludes** the `Default` and `Active` system pseudo-solutions (the `Default` solution acts as a catch-all for every unmanaged customization in the env, so it always matches and would otherwise force the multi-match path). Errors out if zero or multiple real unmanaged wrappers contain the app — in the multi-match case, pass `--solution NAME` explicitly.
4. **Resolve the canvas app's internal name** (`canvasapps.name`, e.g. `xxxxx_wqwaterquality1_e5807`). That's the filename prefix inside the solution zip's `CanvasApps/` folder.
5. `pac solution export --name <wrapper> --path /tmp/.../solution.zip --overwrite` to fetch the current solution package.
6. Unzip the solution. **Stamp the build slug:** if any file under `src/` contains a `Build YYYY-MM-DD HH:MM TZ` marker (used by some apps for visual cache-busting on a home-screen footer), the script rewrites it to the current local time before packing. No-op for apps without the pattern. The stamped file is included in the auto-commit so the recorded slug reflects when the push happened.
7. `pac canvas pack --sources src/ --msapp packed.msapp`, then replace `CanvasApps/<canvas-name>_DocumentUri.msapp` with the freshly packed file.
8. Re-zip the modified solution.
9. `pac solution import --path solution-modified.zip --force-overwrite --publish-changes`. `--force-overwrite` is required because we're updating an existing unmanaged customization; `--publish-changes` means the app is live immediately.
10. Re-GET app metadata and rewrite `app-definition.json` (rotating SAS stripped).
11. Stamp `app-meta.json.lastUpdatedAt`.
12. **`git add` + `git commit`** the app folder, unless `--no-commit`.

The temp working dir is wiped on exit. `git push` is **not** done — local commit only.

## What it does NOT do

- **Does not re-unpack `src/`** from the freshly-imported app. The local `src/` you edited is treated as authoritative — refreshing it would risk noisy diffs from server-side normalisation clobbering your edits. If you want a fresh server pull after a push, run `apps-export` explicitly.
- **Does not support cross-env push.** The wrapper solution must exist in the same env as the app.
- **Does not rotate connection references.** Connections are stored at the env level; if you swap a data source in `DataSources/`, the connection must already exist in that env.

## Failure modes

| Symptom | Cause | Fix |
|---|---|---|
| `No unmanaged solution contains this canvas app` | Wrapper not created in portal | Maker portal → Solutions → New solution (unmanaged) → Add existing → App → Canvas app → pick the app. |
| `Multiple unmanaged solutions contain this app` | More than one unmanaged solution wraps the app | Pass `--solution NAME` to disambiguate. Usually means an orphan wrapper to clean up. |
| `Expected ..._DocumentUri.msapp inside the solution zip but it's not there` | Canvas app row's `name` field doesn't match the solution payload (rare; e.g. the app was renamed and not republished) | Re-add the app to the wrapper solution from the portal, or remove + re-add. |
| `pac solution import` fails with version-related error | Already-imported solution at same/higher version | The script doesn't bump the version. Manually bump the wrapper's version in the portal (Solutions → Properties → Version) and re-run. |
| `pac canvas pack` warns "deprecated" | Pac 2.6.4 marked unpack/pack deprecated | Benign for now. The successor verb hasn't shipped. See [docs/reference/pac-canvas-deprecation.md](../../docs/reference/pac-canvas-deprecation.md). |

## Before pushing: refresh the data-source schema if you referenced a new column

If a `.fx.yaml` edit references a SharePoint column that was **just added** to the list, the Studio data-source schema must be refreshed (maker portal → **Data → `<list>` → ⋯ → Refresh**) *before* you run `update-app.sh`. Skipping it produces a **silent runtime failure**: the published app no-ops the entire `OnSelect`/formula block that contains the unknown field — no error toast, no overlay, no state change. The user reports "I click and nothing happens."

This is a portal step the **user** performs; on Linux you cannot refresh the schema yourself. So when an edit adds a reference to a new column, confirm with the user that the refresh is done before pushing. Verified by the 2026-06-01 WaterQuality production incident (a `ClientVersion` column reference shipped against a stale cached schema; saves silently no-opped). Edits that touch only columns the app already knows about do **not** need this — don't let it become a reason to gate routine pushes.

## Canvas-app gotchas (in your `.fx.yaml`)

These commonly bite during edits — read once before any non-trivial `src/` change:

- **PA2001 "Checksum mismatch"** is benign (fires every edit; not a failure signal).
- **PA3003 "Property should be at same indent level"** IS fatal — bare `\n` lines inside `OnSelect: |` block scalars break the pack. Pad blanks to 12 spaces after manual edits.
- **`Concurrent` refuses multi-branch writes to the same data source**, even if rows are disjoint. Group by source.
- **`Select(otherBtn)` is fire-and-forget**, not synchronous. Race-protection requires guard variables.

Full text in [docs/reference/powerapps-gotchas.md](../../docs/reference/powerapps-gotchas.md).

## Source-control behavior

The auto-commit makes the local tree the durable record of what's live in Power Apps for this app. Rollback: `git revert <sha>` (or `git checkout <sha> -- apps/<Name>/src/`) followed by another `update-app.sh` to push the rolled-back state. No separate dev environment needed.
