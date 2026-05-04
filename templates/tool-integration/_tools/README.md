# Tools

Reusable bash scripts that wrap the underlying tool/CLI/API calls. **Skills are the human/agent interface; `_tools/` is the implementation.**

When a skill says "wraps `_tools/<script>.sh`", it means the agent invokes the script and interprets the output. The script itself is the reusable bit — same script can be invoked from any skill.

## Conventions

- One script per discrete operation.
- Idempotent where possible.
- `set -euo pipefail` at top.
- All inputs validated; clear error messages.
- Output to stdout for normal results; stderr for diagnostics. Skills parse stdout.
- No interactive prompts inside scripts — input via args or env vars only.
- No hardcoded secrets — read from `.secrets/` or env.

## Index

<!-- PLACEHOLDER — list each script with a one-line summary. The /finish
     skill checks every script is listed.

- [find-flow.sh](find-flow.sh) — find which environment a flow lives in (by id or name).
- [export-flow.sh](export-flow.sh) — export a flow to JSON + .zip.
- [update-flow.sh](update-flow.sh) — PATCH a modified flow back to the platform.
- [find-app.sh](find-app.sh) — find which environment a canvas app lives in.
- [export-app.sh](export-app.sh) — export a canvas app: .msapp + unpacked YAML src/.

-->
