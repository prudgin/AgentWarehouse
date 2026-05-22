# `pac canvas unpack/pack` deprecation

Tracking the deprecation of the two `pac canvas` verbs that the `apps-export` and `apps-update` skills depend on.

## Status

As of pac 2.6.4, both `pac canvas unpack` and `pac canvas pack` print a deprecation warning on every invocation:

```
Warning: 'pac canvas unpack' is deprecated and will be removed in a future release.
```

Microsoft has not shipped a replacement yet. The verbs still work; the warning is informational.

`_tools/update-app.sh` suppresses the warning in its output via `2>&1 | grep -v "deprecated" || true`. `_tools/export-app.sh` lets it through.

## Why this matters

The two skills below depend on these verbs. When they go away, both break:

- [`apps-export`](../../skills/apps-export/SKILL.md) — calls `pac canvas unpack` to expand the downloaded `.msapp` into editable `src/`.
- [`apps-update`](../../skills/apps-update/SKILL.md) — calls `pac canvas pack` to rebuild `.msapp` from edited `src/` before importing via the solution wrapper.

There is no public REST endpoint for round-tripping canvas-app source on Linux outside of these verbs. If Microsoft removes them without a replacement, the working theory of the canvas-app workflow has to change — likely to a portal-only push path or a Windows-only tool.

## Watch points

- **pac release notes** — track `pac install latest` and read the changelog.
- **`pac canvas` help output** — if `unpack`/`pack` disappear from `pac canvas --help`, they've been removed.
- **Replacement verbs** — likely candidates are `pac canvas download` (already exists; pulls `.msapp` by app-id) and a yet-to-ship `pac canvas upload`. Watch for the latter.

## Mitigation if removed

In priority order:

1. **Pin pac to the last version that supports the verbs.** Document the pinned version in this file, install via `dotnet tool install --version <X> Microsoft.PowerApps.CLI.Tool`. Loses upgrades to other verbs but preserves the workflow.
2. **Switch to the replacement verbs.** Update `_tools/export-app.sh` and `_tools/update-app.sh`. Likely small change if the new verbs are `download`/`upload`.
3. **Move canvas-app editing to a Windows VM.** The full pac toolkit ships on Windows; this is the supported path Microsoft assumes. Use Linux for everything else, Windows only for canvas-app round-trips.

Track in `docs/planning/future-work.md` until resolution.
