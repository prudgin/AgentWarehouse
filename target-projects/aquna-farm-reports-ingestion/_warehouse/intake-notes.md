# Intake notes — aquna-farm-reports-ingestion

Cold-start. Intake date: 2026-05-18.

## User-stated requirements (verbatim, 2026-05-18)

> I get emails to my corporate email in outlook from stanbridge@aquna.com, whitton@aquna.com, MCFdailyreport@aquna.com, BilbulJuvenilereport@aquna.com with subject or body often containing "report"
>
> so they are farm reports and I want to store them.
>
> I want to set up a flow that will trigger on receiving such an email and storing those somewhere on sharepoint.

## Resolved decisions

| # | Decision | Resolution |
|---|----------|-----------|
| 1 | Project slug | `Aquna_Farm_Reports_Ingestion` (Pascal_Snake, matches sibling flows). Warehouse staging: `aquna-farm-reports-ingestion`. |
| 2 | What to store | Full email (`.eml` or `.msg`) **plus** all attachments. |
| 3 | Folder layout | `<Sender>/YYYY-MM/` inside the sub-root. |
| 4 | "report" keyword | **Advisory only** — sender allowlist is the sole hard filter. (See ADR-0001.) |
| 5 | SharePoint sub-root | `Automation/Farm Reports Archive/` inside the `Planning  Development` library. |
| 6 | Sender short-names | `Stanbridge`, `Whitton`, `MCF_Daily`, `Bilbul_Juvenile`. |
| 7 | Filename convention | `YYYY-MM-DD_HH-MM_<sender-short>_<sanitised-subject>.eml` (+ same-prefix `__attN_<original-name>` for attachments). |
| 8 | Dedup | Filename collision → skip (Power Automate "create if not exists"). |
| 9 | Failure handling | Default retries; on terminal failure, email-to-self. |
| 10 | Manifest | None — folder listing is the manifest. |
| 11 | Library name | `Planning  Development` (verbatim, with double space). |

## Identified ADRs (3-of-3 admission test)

- **ADR-0001**: Sender allowlist is the sole filter — no keyword filter. (Hard to reverse: adding a filter retroactively is fine but removing one isn't. Surprising: user explicitly mentioned "report". Real trade-off: false-negative risk vs. simplicity.)
- **ADR-0002**: Folder layout is sender-first, then year-month. (Hard to reverse: moving 1000s of files later is painful. Surprising: many flow archives are date-first. Real trade-off: optimises for "what did this farm send" over "what arrived in May".)

## Identified glossary terms

- Farm report
- Sender short-name (table of four)
- Sanitised subject
- Sub-root

## Open ends

None remaining at intake. Concrete site/library/folder ID values (SharePoint resource IDs used by Power Automate connectors) will be filled in during flow build (post-`/create-project`) when the agent has a Power Automate session.
