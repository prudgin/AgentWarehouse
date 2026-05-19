# ADR-0002 — SharePoint folder layout is sender-first, then year-month

Date: 2026-05-18
Status: Accepted

## Context

Reports archived from four senders into one SharePoint sub-root. Three layouts considered:

1. `<Sender>/YYYY-MM/` — sender first.
2. `YYYY-MM/<Sender>/` — date first.
3. Flat: one folder, dates encoded in filenames.

## Decision

Option 1: `<Sender>/YYYY-MM/<filename>`.

## Consequences

**Positive**:
- Matches the human mental model: "what's the latest from Stanbridge?" is a single click; under date-first it requires opening every month.
- Each year-month folder stays small (one farm's monthly output is a few-to-few-dozen files), so SharePoint folder views stay browsable.
- Per-sender retention or permission policies become possible without restructuring later.

**Negative**:
- Answering "what arrived in May 2026 across all farms?" requires opening four folders. Acceptable; this query is rarer than "what's the latest from sender X".
- If a new sender is added later, a new top-level folder is created — a minor coordination point but no migration of existing files.

**Reversible?** Moving thousands of files across a SharePoint library after the fact is painful — both technically (slow Graph API moves) and operationally (any external links break). This is the main reason this gets an ADR rather than a glossary note: the cost of changing your mind grows linearly with archive size.

## Alternatives rejected

Date-first (option 2) optimises for the wrong query — month-based browsing is rare; sender-based browsing is the common case.

Flat (option 3) was rejected because folder listings become unwieldy past a few hundred files, and the archive will accumulate well past that.
