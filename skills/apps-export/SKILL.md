---
name: apps-export
description: Export a Power Apps canvas app to `apps/<Friendly_Name>/` — produces `app-meta.json`, `app-definition.json`, `app.msapp`, and `src/` (unpacked editable YAML). Wraps `_tools/export-app.sh`. Use after `apps-discover` (or when you know `appId`). Auto-mode safe.
---

# apps-export

Pull a canvas app into the repo as a versioned snapshot. Captures the raw app metadata, the `.msapp` binary, and an editable `src/` tree of `.fx.yaml` files (one per screen/control) produced by `pac canvas unpack`.

This skill writes to the working tree but does **not** auto-commit.

## When to invoke

- First time bringing a canvas app into the repo.
- After a push via `apps-update`, to re-snapshot the server state.

## Mechanics

```bash
_tools/export-app.sh <app-id> [out-dir]
```

When `out-dir` is omitted, the folder is named after the app's display name (sanitized) and placed under `<repo-root>/apps/`.

Output:

| File | Purpose |
|---|---|
| `app-meta.json` | `{appId, envId, displayName, environmentDisplayName, exportedAt, isManaged, solutionUniqueName?}`. The `isManaged` and `solutionUniqueName` fields come from a best-effort Dataverse lookup — null if the env has no Dataverse instance or auth fails. |
| `app-definition.json` | Raw GET on the app object, with all rotating SAS URLs stripped (`appUris.*`, `backgroundImageUri`, `teamsColorIconUrl`, `teamsOutlineIconUrl`). Without stripping, every export churns the diff and leaks read-only blob credentials into git history. |
| `app.msapp` | Downloaded via the `documentUri` SAS. **Gitignored** — regenerable from `src/` via `pac canvas pack`. |
| `src/` | `pac canvas unpack` output: `Src/*.fx.yaml` (formulas), `Assets/`, `Other/`. The editable form. |

## Why both `.msapp` and `src/`?

`src/` is what humans (and agents) edit — `.fx.yaml` is line-diffable. `.msapp` is the format Power Apps actually accepts back. `apps-update` repacks `src/` → `.msapp` before pushing.

The `.msapp` is gitignored because it's a binary opaque to diff and fully regenerable. Treat `src/` as the source of truth.

## Push gap

There is no public REST endpoint for pushing a modified `.msapp` to a standalone canvas app on Linux. `apps-update` works around this via a one-time unmanaged-solution wrapper; see that skill.

## Auth

Needs BAP token. See [power-platform-auth](../power-platform-auth/SKILL.md). Best-effort Dataverse lookup also tries the env's Dataverse instance URL for `isManaged` and `solutionUniqueName` — skips gracefully if unavailable.

## Deprecation

`pac canvas unpack` is marked deprecated by pac 2.6.4 with no shipped replacement. Track in [docs/reference/pac-canvas-deprecation.md](../../docs/reference/pac-canvas-deprecation.md). When it goes away, both `apps-export` and `apps-update` need new mechanics.
