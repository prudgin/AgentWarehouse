---
name: flows-update
description: PATCH a Power Automate cloud flow's definition from a local `flow-definition.json`, with placeholder→secret substitution at push time and a server-vs-local fingerprint check after. Auto-commits the per-flow folder after a successful push. Wraps `_tools/update-flow.sh`. Use after editing `flows/<Name>/flow-definition.json`. Auto-mode safe (commits locally; never pushes to remote).
---

# flows-update

Push edits to a flow's definition back to Power Automate. Sends a PATCH on `properties.definition` + `properties.connectionReferences` only — leaves state, owner, ownership tags untouched server-side.

## When to invoke

After hand-editing `flows/<Name>/flow-definition.json`. Examples:

- Renamed a variable, changed a header, or rewrote a body expression in an HTTP action.
- Swapped one model/endpoint/API for another.
- Tweaked a condition, expression, or default value.
- Re-pointed connection references inside the same env.

**Don't use this for:**

- Cross-environment migration (use `flows-export` then re-import via the BAP `importPackage` API or `pac solution import` in the target env).
- State changes (turn flow on/off) — those go through the portal or a different REST verb.
- Anything where connections in the target env don't already exist (will 4xx).

## Prereqs

1. [`power-platform-auth`](../power-platform-auth/SKILL.md) — `az login` good for the right tenant.
2. The flow must already have been exported once with `flows-export` so the folder contains `flow-meta.json` (provides `envId`, `flowId`, `displayName`) and `flow-definition.json` (the modified flow object).

## Tool

```bash
_tools/update-flow.sh <flow-dir> [--no-commit]
```

Sequence:

1. Read `flowId` + `envId` + `displayName` from `flow-meta.json`.
2. Build PATCH body: `{properties: {definition, connectionReferences}}`.
3. Resolve placeholder variables (see "Secret handling").
4. **Audience safety check**: if any HTTP action targets `api.anthropic.com`, refuses to push unless the resolved `varClaudeKey` matches `^sk-ant-`. Catches the case where someone pastes the wrong file into `.secrets/anthropic-api-key`.
5. Acquire a Flow-audience token (`https://service.flow.microsoft.com/`).
6. PATCH `https://api.flow.microsoft.com/providers/Microsoft.ProcessSimple/environments/<env>/flows/<flow>?api-version=2016-11-01`.
7. GET the live definition back; sha256-fingerprint it; compare to the just-pushed local body (with placeholders resolved on the local side for a meaningful comparison). Same fingerprint = clean push. Differing fingerprint = API normalised something (key order, added metadata); re-export to sync.
8. Stamp `flow-meta.json.lastUpdatedAt`.
9. Auto `git add` + `git commit` the flow folder, unless `--no-commit`.

`git push` is **not** done by this script — local commit only. Push to GitHub separately when you want off-machine mirroring.

## Secret handling

Committed flow definitions store secret-bearing variable values as `__<NAME>_PLACEHOLDER__` sentinels. At push time, `update-flow.sh` substitutes the real value **in memory** from `.secrets/<file>`. The on-disk JSON is never modified.

Default placeholder: `varClaudeKey` ← `__ANTHROPIC_API_KEY_PLACEHOLDER__` ← `.secrets/anthropic-api-key`. See [anthropic-api-integration](../anthropic-api-integration/SKILL.md) for the full round-trip.

Rotating a key:

1. Mint/rotate on the issuing console.
2. `echo -n "<new-key>" > .secrets/<name> && chmod 600 .secrets/<name>`
3. Verify on-disk `flow-definition.json` still has the placeholder (not a real key).
4. Run `update-flow.sh` — resolves the placeholder and pushes.

**Adding a new placeholder convention**: edit `update-flow.sh`'s `resolve_placeholder` call list **and** the matching scrub rule in `export-flow.sh`. Both ends must agree or the round trip leaks the resolved secret back into the working tree.

## Endpoint reference

```
PATCH https://api.flow.microsoft.com/providers/Microsoft.ProcessSimple/environments/{envId}/flows/{flowId}?api-version=2016-11-01
Authorization: Bearer <Flow-audience token>
Content-Type: application/json

{ "properties": { "definition": { ... }, "connectionReferences": { ... } } }
```

Same domain and audience as the GET in `flows-export`. **Not** the BAP endpoint that `flows-export`'s package step uses.

## Order-of-operations caveats

1. **The flow may already be running.** Power Automate doesn't queue updates against in-flight runs — the PATCH lands immediately and applies to the *next* trigger. If you need atomicity (e.g., a flow polls every minute and a half-applied state would be wrong), turn the flow off via the portal first, push, then turn it back on.
2. **External state must be ready before the next trigger fires.** If the flow reads from SharePoint config (model name, prompt, connection target), update that state *before* you push.
3. **Connection references must exist in the env.** `connectionReferences` map names like `shared_office365` to specific connection IDs (`shared-office365-b3f55178-…`). Those IDs are tenant-scoped. Editing them to point to a connection that doesn't exist makes the PATCH succeed but every subsequent run fail at trigger time. Editing is rare; usually leave them alone.
4. **No optimistic concurrency.** The API doesn't enforce versioning on PATCH. If someone edits in the UI while you have a stale local copy, your push silently overwrites their changes. Tight loop: `flows-export` → edit → `flows-update`. Don't leave a stale local copy lying around for days.
5. **Designer rendering.** If you write JSON the Power Automate designer doesn't recognize, the flow runs fine but the UI shows "unable to render" and the user is forced into code view. Verify in the designer if visual editing matters.

## Failure modes

- **`401 Unauthorized`** → token expired. `az login` is stale; re-login.
- **`403 Forbidden`** → user is not a maker on this flow. Owner needs to share or push themselves.
- **`400 Bad Request InvalidWorkflowDefinition`** → JSON is structurally valid but Power Automate rejects it (references an action that doesn't exist, malformed expression). The API usually points at the specific action — read carefully.
- **Server-vs-local fingerprint differs after success** → not a failure. The API normalises whitespace / key order / adds metadata. Re-sync: `flows-export <env> <flow> <flow-dir>`.

## Verification beyond fingerprint

The fingerprint match confirms the *definition* round-trips, but doesn't prove the flow *runs* correctly. Real verification:

1. Trigger a real run (or wait for the next scheduled trigger).
2. Check run history in the Power Automate portal, or:
   ```
   GET https://api.flow.microsoft.com/providers/Microsoft.ProcessSimple/environments/{envId}/flows/{flowId}/runs?api-version=2016-11-01
   ```
3. Confirm the run succeeded, not just the PATCH.

Fingerprint is the code-correctness gate; run history is the runtime-correctness gate.

## Rollback

No built-in rollback. Use git:

```bash
git checkout <sha> -- flows/<Name>/flow-definition.json
_tools/update-flow.sh flows/<Name>/
```

For SharePoint-backed prompts or config rows (where the runtime value lives in a SharePoint list, not the flow definition itself), use a separate write path — typically a proxy flow ([proxy-flow-scaffolding](../proxy-flow-scaffolding/SKILL.md)) or Graph with the `Sites.ReadWrite.All` consent (see [docs/reference/azure-cli-sharepoint-auth.md](../../docs/reference/azure-cli-sharepoint-auth.md)).
