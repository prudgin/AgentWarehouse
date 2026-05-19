# Glossary — Aquna Farm Reports Ingestion

Project-specific vocabulary. Other docs link here rather than redefining terms.

Glossary contract: canonical term, "Avoid" synonyms, one-sentence definition, relationships, example dialogue, flagged ambiguities.

---

## Farm report

**Avoid**: "farm email", "report email", "daily mail".

**Definition**: Any email arriving in the user's corporate Outlook inbox from one of the four allowlisted `@aquna.com` senders. The historical convention is that the subject or body contains "report", but the system does **not** require this — see [ADR-0001](docs/adr/0001-sender-allowlist-only.md).

**Relationships**: Each farm report is stored as one `.eml` file plus zero or more attachment files in [SharePoint sub-root](#sub-root) `<Sender>/YYYY-MM/`.

**Example**: "We had three farm reports yesterday — two from Stanbridge and the MCF daily."

**Ambiguity**: If a sender forwards an unrelated message, it still counts as a farm report by this definition. The trade-off (no keyword filter) is recorded in ADR-0001.

---

## Sender short-name

**Avoid**: "abbreviated sender", "sender code".

**Definition**: A short identifier used as both the SharePoint subfolder name and the `<sender-short>` slot in stored filenames. Mapping:

| Sender email                       | Short-name        | Origin                       |
|------------------------------------|-------------------|------------------------------|
| `stanbridge@aquna.com`             | `Stanbridge`      | Farm name                    |
| `whitton@aquna.com`                | `Whitton`         | Farm name                    |
| `MCFdailyreport@aquna.com`         | `MCF_Daily`       | Farm code + report flavour   |
| `BilbulJuvenilereport@aquna.com`   | `Bilbul_Juvenile` | Farm code + report flavour   |

**Relationships**: Used by the flow's switch step to route the email to the correct subfolder.

**Example**: "Anything from `MCFdailyreport@aquna.com` goes to the `MCF_Daily` folder."

---

## Sanitised subject

**Avoid**: "cleaned subject", "filename-safe subject".

**Definition**: The email's `Subject` header after the following normalisation: replace any character outside `[A-Za-z0-9_-]` with `_`; collapse runs of `_`; strip leading/trailing `_`; truncate to 80 characters.

**Relationships**: Forms the trailing slot of the storage filename. Empty result → fallback to `no_subject`.

**Example**: Subject `Daily Report — 18/05/2026 (final)` → `Daily_Report_18_05_2026_final`.

---

## Sub-root

**Avoid**: "destination folder", "target dir".

**Definition**: The single SharePoint folder beneath which all of this flow's output lives. Concretely: `https://murraycod.sharepoint.com/Planning  Development/Automation/Farm Reports Archive/`. Inside the sub-root, the layout is `<Sender>/YYYY-MM/` per [ADR-0002](docs/adr/0002-folder-layout-sender-first.md).

**Relationships**: All `.eml` files and attachment files this flow writes land somewhere inside the sub-root.

**Example**: "If the sub-root permissions change we'll see every step fail at once."

**Note**: The library name `Planning  Development` has a literal double space.
