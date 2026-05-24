---
name: pac-cli-linux
description: Install and run the Power Platform CLI (`pac`) on Linux. Includes the nupkg + .NET runtime workaround needed because `dotnet tool install --global Microsoft.PowerApps.CLI.Tool` is broken (nupkg is missing `DotnetToolSettings.xml`). Documents the critical gotcha that `pac` has NO `flow` verb (flow CRUD goes through REST). Use when installing pac on a fresh Ubuntu machine or troubleshooting an existing install. Auto-mode safe.
---

# pac-cli-linux

Microsoft's `pac` CLI is the supported tool for several Power Platform surfaces — canvas-app `unpack`/`pack`, Dataverse `solution` export/import, environment listing. It runs cleanly on Linux but the official install path is broken; this skill documents the working install.

## Why `dotnet tool install --global Microsoft.PowerApps.CLI.Tool` fails

The official nupkg is structured for the Windows MSI installer and is missing the `DotnetToolSettings.xml` that `dotnet tool install` requires. It fails on every platform, not just Linux. The cross-platform install path is to download the nupkg and run the cross-platform DLL directly.

## Install recipe (Ubuntu / Debian / WSL)

`.NET 8 SDK` is not enough — PAC currently targets `net10.0`. Adjust the runtime version below if a newer pac demands something different.

```bash
# 1. .NET 10 ASP.NET Core runtime (no sudo required)
mkdir -p ~/.dotnet
curl -sSL -o /tmp/aspnet10.tar.gz \
  "https://builds.dotnet.microsoft.com/dotnet/aspnetcore/Runtime/10.0.7/aspnetcore-runtime-10.0.7-linux-x64.tar.gz"
tar -xzf /tmp/aspnet10.tar.gz -C ~/.dotnet

# 2. PAC payload from NuGet
mkdir -p ~/.pac && cd ~/.pac
curl -sL -o pac.nupkg "https://www.nuget.org/api/v2/package/Microsoft.PowerApps.CLI.Tool"
unzip -q -o pac.nupkg -d extracted

# 3. shim script
mkdir -p ~/.local/bin
cat > ~/.local/bin/pac <<'EOF'
#!/usr/bin/env bash
export DOTNET_ROOT="$HOME/.dotnet"
exec "$HOME/.dotnet/dotnet" "$HOME/.pac/extracted/tools/net10.0/any/pac.dll" "$@"
EOF
chmod +x ~/.local/bin/pac
```

Add `export PATH="$HOME/.local/bin:$PATH"` to `~/.bashrc` if not already present.

Confirm: `pac help` should list the verbs below.

## One-time auth per machine

`pac` has its own auth store independent of `az`. Create a device-code profile per env you'll operate against:

```bash
pac auth create --deviceCode --environment <env-id>
pac auth list                    # show profiles
pac auth select --index <n>      # switch
```

`--deviceCode` is the right flag for headless or remote sessions; the default browser-popup flow assumes a desktop.

## Critical gotcha: `pac` has NO `flow` verb

PAC v2.x top-level verbs (run `pac help` for the current list):

```
admin application auth canvas catalog code connection connector copilot env help
managed-identity model modelbuilder package pages pcf pipeline plugin power-fx
solution telemetry test tool
```

There is no `flow` command, and `--packagetype SingleMicrosoftFlowMigratingPackage` is **not** a PAC flag — that string belongs to the **Power Automate REST API**'s `exportPackage` endpoint. Documentation or AI-generated snippets that suggest `pac flow export ...` are wrong.

To export a flow as JSON, use one of:

- [`flows-export`](../flows-export/SKILL.md) — calls the REST APIs directly (recommended).
- `pac solution export --name <SolutionName> --path solution.zip --overwrite` — works only if the flow is inside a Dataverse solution; the zip will contain the flow JSON under `Workflows/`.

## Verbs used by the warehouse skills

| Verb | Used by | Purpose |
|---|---|---|
| `pac canvas unpack` | `apps-export` | Expand `.msapp` → editable YAML under `src/`. **Deprecated in pac 2.6.4** — see [docs/reference/pac-canvas-deprecation.md](../../docs/reference/pac-canvas-deprecation.md). |
| `pac canvas pack` | `apps-update` | Repack edited `src/` → `.msapp`. **Same deprecation**. |
| `pac solution export` | `apps-update` | Pull unmanaged solution zip from an env (transport wrapper for canvas-app push). |
| `pac solution import` | `apps-update` | Push modified solution zip back. Use `--force-overwrite --publish-changes`. |
| `pac env list` / `pac env who` | manual | Confirm which env the active profile points at. |

## What pac does NOT do (Linux gaps)

- **No `pac canvas upload`.** There is no public REST endpoint to push a modified `.msapp` to a standalone canvas app on Linux. The supported path is solution-wrapped: `pac solution export → swap .msapp inside the zip → pac solution import`. `apps-update` automates this.
- **No `pac flow` verbs.** See above — REST is the path.

## Suppressing deprecation noise

`pac canvas pack` prints a deprecation warning every run. Filter it in scripts:

```bash
pac canvas pack --sources "$SRC" --msapp "$PACKED_MSAPP" 2>&1 | grep -v "deprecated" || true
```

The `|| true` is needed because `grep -v` exits non-zero if it filters everything out.
