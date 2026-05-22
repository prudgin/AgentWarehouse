---
name: apps-update
description: Push edits to a canvas app's `src/` back to Power Apps via the unmanaged-solution route (`pac solution export → swap .msapp → pac solution import`). Requires a one-time portal step per app to wrap it in an unmanaged Dataverse solution. Wraps `_tools/update-app.sh`. Auto-commits the per-app folder after a successful push. Use after editing `apps/<Name>/src/`. Auto-mode safe (local commit only).
---

# apps-update

Push edits to a canvas app's source tree back to Power Apps. Goes via an unmanaged Dataverse solution because there is no public REST endpoint for pushing a standalone canvas app on Linux.

## One-time setup (per app, in the portal)

Microsoft's solution mechanic is the only supported push path. Before this skill works on a given app, the app must be wrapped in an unmanaged Dataverse solution in the same env:

1. Open the maker portal in the target env.
2. Solutions → New solution → unmanaged. Pick a name (convention: `<app-name>_unmanaged`).
3. Add → existing → app → pick the canvas app.

The unmanaged layer sits on top of any managed import without disturbing it. From then on, everything is Linux-side.

## When to invoke

After hand-editing `apps/<Name>/src/Src/*.fx.yaml` or any other file under `src/`.

## Mechanics

```bash
_tools/update-app.sh <app-dir> [--solution NAME] [--no-commit]
```

Sequence:
1. Read `app-meta.json` for `appId` + `envId`.
2. Resolve Dataverse URL for the env (BAP `environments/<env>` → `.properties.linkedEnvironmentMetadata.instanceUrl`).
3. Find the unmanaged wrapper solution: query Dataverse `solutioncomponents` where `objectid=appId AND componenttype=300 AND solutionid.ismanaged=false`. Excludes `Default` and `Active` system solutions. Exactly one match required; pass `--solution NAME` if multiple wrappers exist.
4. Resolve the canvas app's internal name from Dataverse `canvasapps` (`<name>_DocumentUri.msapp` is the filename inside the solution zip's `CanvasApps/`).
5. In a tempdir: `pac solution export` the wrapper, unzip, repack `src/` → fresh `.msapp` via `pac canvas pack`, swap it in, rezip.
6. `pac solution import --force-overwrite --publish-changes` the modified zip.
7. Refresh `app-definition.json` from server (strip rotating SAS URLs).
8. Stamp `app-meta.json.lastUpdatedAt`.
9. Auto `git add` + `git commit`, unless `--no-commit`.

`git push` is **not** done by this script — local commit only.

## Build slug stamping

If any file under `src/` contains a `Build YYYY-MM-DD HH:MM TZ` marker, the script overwrites it with the current timestamp before pack. Used by some apps (e.g. WQ_WaterQuality_sp's home-screen footer) for visual cache-busting. No-op for apps without the pattern. Stamping happens on the on-disk file so the auto-commit records the new slug.

## Gotchas

- **PA2001 "Checksum mismatch" warning is benign** — it fires every time you edit `src/` and pack. Not a failure signal. See [docs/reference/powerapps-gotchas.md](../../docs/reference/powerapps-gotchas.md).
- **PA3003 "Property should be at same indent level" IS fatal** — caused by empty `\n` lines inside `OnSelect: |` block scalars. Pad blanks to 12 spaces after manual edits. See gotchas doc.
- **`Concurrent` refuses multi-branch writes to the same data source**, even if rows are disjoint. Group by source — sequential writes to one list, parallel across lists. See gotchas doc.
- **`Select(otherBtn)` is fire-and-forget**, not synchronous. Race-protection requires a guard variable. See gotchas doc.

## Auth

Needs BAP + Dataverse tokens (BAP for the env lookup; Dataverse for the solution component query). Plus `pac` auth profile selected for the right env. See [power-platform-auth](../power-platform-auth/SKILL.md) and [pac-cli-linux](../pac-cli-linux/SKILL.md).

## Deprecation

`pac canvas pack` is marked deprecated by pac 2.6.4. The script suppresses the per-run warning. When the verb is removed, this skill's mechanics will need updating. See [docs/reference/pac-canvas-deprecation.md](../../docs/reference/pac-canvas-deprecation.md).
