---
name: anthropic-api-integration
description: How to call the Anthropic API from a Power Automate flow — HTTP action wiring, key placeholder convention, audience safety check, model-version handling, response parsing. Use when adding LLM calls to a Power Automate flow or modifying an existing AI flow. Auto-mode safe (knowledge skill).
---

# anthropic-api-integration

Wire an Anthropic API call into a Power Automate flow without leaking the key into git, without hard-coding a model version that'll go stale, and with enough validation that bad keys fail loudly at push time.

This skill is mostly knowledge — the heavy lifting is in `flows-update`'s secret substitution and audience safety check.

## Key handling (placeholder round-trip)

The Anthropic API key lives in `.secrets/anthropic-api-key` (mode 600, plaintext). It is never committed and never appears in `flow-definition.json` on disk.

The pattern:

1. **In the flow definition**, the key is held in an `Initialize_key_variable` action's `varClaudeKey` variable.
2. **On disk** in `flows/<Name>/flow-definition.json`, `varClaudeKey.value` is the sentinel string `__ANTHROPIC_API_KEY_PLACEHOLDER__`.
3. **At push time**, `flows-update` substitutes the real key from `.secrets/anthropic-api-key` into the in-memory PATCH body. The on-disk file keeps the placeholder.
4. **At export time**, `flows-export` scrubs any resolved `sk-ant-...` value back to the placeholder before writing `flow-definition.json`.

Both ends are wired in `_tools/update-flow.sh` (resolve_placeholder call) and `_tools/export-flow.sh` (SCRUBBED jq block). Touch both or the round trip leaks.

## HTTP action shape

Typical Power Automate HTTP action for `/v1/messages`:

```
Method:  POST
URI:     https://api.anthropic.com/v1/messages
Headers:
  x-api-key:         @{variables('varClaudeKey')}
  anthropic-version: 2023-06-01
  content-type:      application/json
Body:
  {
    "model": "@{variables('varModelName')}",
    "max_tokens": 4096,
    "system": "@{variables('varSystemPrompt')}",
    "messages": [{"role": "user", "content": "@{variables('varUserPrompt')}"}]
  }
```

Don't use Power Automate's "Use sample payload to generate schema" — it'll bake the current model name into the action's metadata. Reference variables instead.

## Audience safety check

`flows-update` has a guard: if any HTTP action in the flow targets `api.anthropic.com`, the resolved `varClaudeKey` must start with `sk-ant-`. The push is refused otherwise. This catches the case where someone pastes the wrong file into `.secrets/anthropic-api-key` (e.g. a SharePoint URL or an OpenAI key).

## Model versioning

Hard-coded model names go stale fast. Two strategies in this codebase:

1. **SharePoint-driven** — keep the model name in a SharePoint config list (e.g. `WQ_AI_Config.ModelName`), have the flow read it at run time. Updates require no flow redeploy.
2. **Best-effort latest-Sonnet discovery** — at the start of the run, GET `/v1/models` and pick the highest-version Sonnet; fall back to a hard-coded default if the call fails. Used by `WQ_AI_Prompt_Tuner` to keep its own model current.

Default to #1 unless the flow explicitly needs to auto-track Anthropic's newest releases. Strategy #2 means a Power Automate run can suddenly use a model the prompt wasn't tuned against — fine for a tuner, dangerous for a downstream summariser.

## Response parsing

`/v1/messages` returns:

```json
{
  "id": "msg_...",
  "type": "message",
  "role": "assistant",
  "content": [{"type": "text", "text": "..."}],
  "model": "claude-...",
  "stop_reason": "end_turn",
  "usage": {"input_tokens": N, "output_tokens": M}
}
```

In Power Automate, extract with: `body('HTTP_Anthropic')?['content']?[0]?['text']`. The `[0]` is required — `content` is an array even when there's only one text block.

## Error handling

Anthropic returns standard HTTP status codes:

- `400` — usually malformed request body or empty messages array.
- `401` — bad key (the audience safety check above prevents this from making it out of `flows-update`, but a revoked key still hits here).
- `429` — rate limited or daily-quota exhausted.
- `529` — overloaded.
- `5xx` — transient.

For production AI flows, wrap the HTTP action in a Scope, follow with a parallel "Run after" that catches failures, and notify via the email proxy (see [proxy-flow-scaffolding](../proxy-flow-scaffolding/SKILL.md)). Don't retry inside the flow — Power Automate's auto-retry on 5xx is usually enough; manual retry loops complicate Run history.

## Prompt caching

If the system prompt is large and stable across calls (>1024 tokens that don't change run-to-run), use the `cache_control: {"type": "ephemeral"}` block to enable prompt caching:

```json
{
  "system": [
    {"type": "text", "text": "...long stable prompt...", "cache_control": {"type": "ephemeral"}}
  ],
  ...
}
```

Caches live ~5 minutes per Anthropic's TTL. For a flow that runs every minute (e.g. `WQ_AI_Pond_Summary_Processor`), cache hits dominate after the first call of any 5-minute window — typically 90%+ token discount.

## Token accounting

`usage.input_tokens` includes everything in the `system` + `messages` payload (including cached tokens at the discounted rate). `usage.output_tokens` is the assistant's response. Log both into SharePoint if you need cost attribution per run.
