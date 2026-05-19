# Flow specification — Aquna Farm Reports Ingestion

Canonical human-readable spec for the Power Automate flow. The exported `flow-definition.json` is the implementation; this doc is the contract it must satisfy.

## Trigger

**Connector**: Office 365 Outlook — *When a new email arrives (V3)*.
**Mailbox**: user's corporate inbox (the one running the flow).
**Trigger condition** (`From` field, OR-joined):

- `stanbridge@aquna.com`
- `whitton@aquna.com`
- `MCFdailyreport@aquna.com`
- `BilbulJuvenilereport@aquna.com`

**Include attachments**: yes. **Only with attachments**: no (we still store the `.eml` even when there are no attachments).

No keyword filter — see [ADR-0001](../adr/0001-sender-allowlist-only.md).

## Routing

Switch on the sender's email (lowercase) to a [sender short-name](../../glossary.md#sender-short-name):

| From                              | Short-name        |
|-----------------------------------|-------------------|
| `stanbridge@aquna.com`            | `Stanbridge`      |
| `whitton@aquna.com`               | `Whitton`         |
| `MCFdailyreport@aquna.com`        | `MCF_Daily`       |
| `BilbulJuvenilereport@aquna.com`  | `Bilbul_Juvenile` |

`default` case (should be unreachable due to trigger filter) → send a self-notification email "unexpected sender hit the switch" and exit.

## Filename building

Compute once per email:

```
received_ts   = formatDateTime(triggerOutputs()?['body/receivedDateTime'], 'yyyy-MM-dd_HH-mm')
sender_short  = <from switch>
subject_raw   = triggerOutputs()?['body/subject']
subject_clean = sanitise(subject_raw)         // see glossary
filename_stem = '{received_ts}_{sender_short}_{subject_clean}'
```

[Sanitised subject](../../glossary.md#sanitised-subject) rules: keep `[A-Za-z0-9_-]`, replace anything else with `_`, collapse runs, strip ends, truncate to 80 chars, fallback `no_subject`.

## Storage

**Library**: `Planning  Development` (literal double space) at `https://murraycod.sharepoint.com`.
**Sub-root**: `Automation/Farm Reports Archive/` — the [sub-root](../../glossary.md#sub-root).
**Per-email folder**: `{sub-root}/{sender_short}/{YYYY-MM}/` where `YYYY-MM` is derived from `received_ts`.

Files written:

1. `{filename_stem}.eml` — the full email exported via Outlook's *Export email (V2)*.
2. For each attachment (1-indexed `N`): `{filename_stem}__att{N}_{original-name}`.

**Create mode**: "If file exists" → **Skip**. (Power Automate's `Create file` action supports this natively; if not available, follow with a "file exists" check before write.) Same-name files are treated as duplicates per the filename-collision-dedup decision.

## Failure handling

- Each SharePoint write inherits Power Automate's default retry policy (exponential, 4 attempts).
- A scoped "Run after — has failed / has timed out" branch at the flow's root sends a notification email to the flow owner with the failed run URL and the trigger email's subject.

## Out of scope (explicit non-goals)

- No PDF rendering of the email body. The `.eml` carries the body verbatim and any modern client can open it.
- No virus scanning beyond what Outlook + SharePoint perform by default.
- No manifest/index list. The folder listing **is** the manifest.
- No archiving of pre-existing inbox history; the flow only acts on new mail arriving after it is turned on. Bulk-backfill, if wanted later, is a separate one-shot job.
