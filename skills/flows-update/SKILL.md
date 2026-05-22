---
name: flows-update
description: PATCH a Power Automate cloud flow's definition from a local `flow-definition.json`, with placeholder→secret substitution at push time and a server-vs-local fingerprint check after. Auto-commits the per-flow folder after a successful push. Wraps `_tools/update-flow.sh`. Use after editing `flows/<Name>/flow-definition.json`. Auto-mode safe (commits locally; never pushes to remote).
---

# flows-update

Push edits to a flow's definition back to Power Automate. Sends a PATCH on `properties.definition` + `properties.connectionReferences` only — leaves state, owner, ownership tags untouched.

## When to invoke

After hand-editing `flows/<Name>/flow-definition.json` (action graph, variable values, connection references). Don't use it for state changes (turn flow on/off) — those go through the portal or a different REST verb.

## Mechanics

```bash
_tools/update-flow.sh <flow-dir> [--no-commit]
```

`<flow-dir>` must contain:
- `flow-meta.json` — `{flowId, envId, ...}` from a prior `flows-export`.
- `flow-definition.json` — the (possibly modified) flow object.

Sequence:
1. Build PATCH body: `{properties: {definition, connectionReferences}}`.
2. Resolve placeholder variables (see "Secret handling").
3. Audience safety check (see "Audience safety").
4. PATCH `https://api.flow.microsoft.com/.../flows/<flow-id>` with Flow token.
5. GET back the live definition; sha256-fingerprint it; compare to the just-pushed local body. Same fingerprint = clean push. Differing fingerprint = API normalised something (key order, added metadata); re-export to sync.
6. Stamp `flow-meta.json.lastUpdatedAt`.
7. Auto `git add` + `git commit` the flow folder, unless `--no-commit`.

`git push` is **not** done by this script — local commit only. Push to GitHub separately when you want off-machine mirroring.

## Secret handling

Committed flow definitions store secret-bearing variable values as `__<NAME>_PLACEHOLDER__` sentinels (see `flows-export` for the scrub on the other end). At push time, `update-flow.sh` substitutes the real value **in memory** from `.secrets/<file>`. The on-disk JSON is never modified.

Currently wired placeholder: `varClaudeKey` ← `__ANTHROPIC_API_KEY_PLACEHOLDER__` ← `.secrets/anthropic-api-key`.

Add a new placeholder: edit `update-flow.sh`'s `resolve_placeholder` call list, **and** the matching scrub rule in `export-flow.sh`. Both ends must agree or the round trip leaks the resolved secret back into the working tree.

## Audience safety

If the flow contains any HTTP action targeting `api.anthropic.com`, the resolved `varClaudeKey` must start with `sk-ant-`. Refuses the push otherwise — catches the case where someone pasted the wrong key into `.secrets/anthropic-api-key` (e.g. a SharePoint URL or an OpenAI key).

To extend this check for other audiences, add a parallel `if echo "$PATCH_BODY" | jq -e '.. | objects | select(.uri? // "" | test("..."))'` block in `update-flow.sh`.

## Fingerprint mismatch — what to do

If the post-push fingerprint differs from local, re-snapshot:

```bash
_tools/export-flow.sh <env-id> <flow-id> flows/<Name>/
```

The diff between pre- and post-export `flow-definition.json` shows what the API normalised. Common culprits: key order in `connectionReferences`, added `runtimeConfiguration` defaults, whitespace in expressions.

## Auth

Needs Flow token (audience `https://service.flow.microsoft.com/`). See [power-platform-auth](../power-platform-auth/SKILL.md).

## Companion: rollback

There's no built-in rollback in this skill. Use git:

```bash
git checkout <sha> -- flows/<Name>/flow-definition.json
_tools/update-flow.sh flows/<Name>/
```

For SharePoint-backed AI flow prompts (`WQ_AI_Config.PromptBlock` etc.), there's a separate `_tools/rollback-config-prompt.py` that writes directly to SharePoint via Graph — needs the SharePoint consent step (see [docs/reference/azure-cli-sharepoint-auth.md](../../docs/reference/azure-cli-sharepoint-auth.md)).
