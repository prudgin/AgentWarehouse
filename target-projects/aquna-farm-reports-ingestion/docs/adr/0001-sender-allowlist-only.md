# ADR-0001 — Sender allowlist is the sole filter; no keyword filter

Date: 2026-05-18
Status: Accepted

## Context

The user described the inbound mail as: emails from four `@aquna.com` senders "with subject or body often containing 'report'". A natural design would be to filter on both sender **and** the keyword `report`, on the theory that the keyword distinguishes real reports from incidental mail from those senders.

Three filter shapes were considered:

1. Sender allowlist only.
2. Sender allowlist **and** require `report` in subject **or** body.
3. Sender allowlist **and** require `report` in subject only.

## Decision

Sender allowlist only. The four addresses are dedicated farm-report senders; the volume of non-report mail from them is expected to be negligible.

## Consequences

**Positive**:
- Zero false negatives — we never miss a report because its subject happened to be "Daily figures" or "Weekly summary" instead of including the word "report".
- Simpler flow logic; the trigger's built-in `From` filter is the only condition.
- Storage cost is trivial for a personal flow; the cost of accidentally storing the occasional non-report email is essentially zero.

**Negative**:
- If one of these addresses ever sends genuinely off-topic mail (signature changes, holiday-cover notices), it lands in the archive. This is judged a tolerable price for not missing real reports.

**Reversible?** Adding a keyword condition later is a one-step change to the trigger. Removing one is also trivial. But the *false negatives* incurred by a hard filter during the window it was active cannot be recovered — they sit unarchived in the inbox forever unless someone hunts for them.

## Alternatives rejected

Option 2 (sender + keyword in subject or body) was the obvious "by-the-book" answer but was rejected because the user's own wording — "often containing 'report'" — admits cases where the keyword is absent.

Option 3 (subject only) compounds the false-negative risk.
