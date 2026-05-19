# Future work — Aquna Farm Reports Ingestion

Pre-decision items. These have not earned an ADR or a ticket yet.

- **Bulk backfill of historical reports.** Walking the existing inbox for messages that match the trigger and storing them retroactively. Separate one-shot job, not part of the live flow. Decide before turning the flow on whether the cutover should be "no backfill" or "backfill from date X".
- **Per-sender retention policy.** If any sender's archive becomes large, SharePoint retention rules can be applied per top-level folder — the sender-first layout (ADR-0002) makes this trivial. Not configured initially.
- **Quarantine folder for parse failures.** If terminal failures become non-trivial, upgrade failure handling from "email-to-self" to "drop raw message into `_quarantine/`". Defer until we see actual failure rates.
- **Sender list expansion.** Adding new `@aquna.com` farm reporters is a small flow edit (extend the trigger filter + add a switch branch). Document the procedure if it happens more than twice.
