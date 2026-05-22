---
name: pac-cli-linux
description: Install and run the Power Platform CLI (`pac`) on Linux. Useful for `pac canvas` (unpack/pack), `pac solution` (export/import), `pac env`, etc. Pac has no `flow` verb — flow ops go through Flow REST API instead (see flows-* skills). Auto-mode safe.
---

# pac-cli-linux

Microsoft's `pac` CLI is the supported tool for several Power Platform surfaces — canvas-app source unpack/pack, Dataverse solution export/import, environment listing. It runs cleanly on Linux as a `dotnet tool`.

## Install

```bash
# Prereq: .NET 6+ SDK (`dotnet --version`).
dotnet tool install --global Microsoft.PowerApps.CLI.Tool
# Add ~/.dotnet/tools to PATH if not already.
export PATH="$PATH:$HOME/.dotnet/tools"
```

Self-update later: `pac install latest`.

## One-time auth

`pac` has its own auth store independent of `az`. Create a device-code profile per machine, scoped to the env you'll operate against:

```bash
pac auth create --deviceCode --environment <env-id>
pac auth list      # shows the active profile
pac auth select --index <n>  # switch
```

The active profile is what `pac canvas`, `pac solution`, etc. authenticate as. Profiles persist across shells.

## Verbs we use

| Verb | Used by | Purpose |
|---|---|---|
| `pac canvas download` | (rare) | Direct .msapp download by app-id. `apps-export` uses BAP REST instead because it also captures `app-meta.json` provenance. |
| `pac canvas unpack` | `apps-export` (`_tools/export-app.sh`) | Expand `.msapp` into editable YAML under `src/Src/*.fx.yaml` + `src/Assets/`. **Marked deprecated** in pac 2.6.4 — see [docs/reference/pac-canvas-deprecation.md](../../docs/reference/pac-canvas-deprecation.md). |
| `pac canvas pack` | `apps-update` (`_tools/update-app.sh`) | Repack edited `src/` back into a `.msapp`. **Same deprecation** as `unpack`. |
| `pac solution export` | `apps-update` | Pull an unmanaged solution zip from an env (used as a transport wrapper for canvas app push). |
| `pac solution import` | `apps-update` | Push a modified solution zip back. Use `--force-overwrite --publish-changes`. |
| `pac env list` / `pac env who` | manual | Confirm which env the active profile points at. |

## What `pac` does NOT do

- **No `pac flow` verb.** Flow CRUD goes through the Flow REST API (`flows-discover`, `flows-export`, `flows-update`).
- **No `pac canvas upload`.** There is no public REST endpoint to push a modified `.msapp` to a standalone canvas app on Linux. The supported path is solution-wrapped: `pac solution export → swap .msapp inside the zip → pac solution import`. `apps-update` automates this.

## Suppressing deprecation noise

`pac canvas pack` prints a deprecation warning every run. Filter it in scripts:

```bash
pac canvas pack --sources "$SRC" --msapp "$PACKED_MSAPP" 2>&1 | grep -v "deprecated" || true
```

The `|| true` is needed because `grep -v` exits non-zero if it filters out everything.
