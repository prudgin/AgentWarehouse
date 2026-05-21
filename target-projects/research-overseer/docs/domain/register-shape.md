# Research projects register — shape and contents

**Source of truth**: `sharepoint_planning:PROJECTS/RnD projects register.xlsx`.

Fetched 2026-05-21 for intake. Snapshot inspected.

## File structure

XLSX workbook with two sheets:

### Sheet 1: `Projects`

Row-per-project. Header in R1, data starts R2. As of snapshot: 27 populated rows (rows 2–27), header is row 1, rest of the 453 rows are blank/junk.

Columns (32 used, rest unused):

| # | Column | Type | Notes |
|---|---|---|---|
| 1 | Title | string | Primary key. Examples: "Bile staining", "2025 RAS feed trial", "Gut evacuation". |
| 2 | Status | enum | New, Scoping, Approved, Planned, In progress, On hold, Finished, Cancelled. |
| 3 | Priority | enum | Low, Medium, High. |
| 4 | Domain | enum | Feed, Water Quality, Process, Data, Genetics, Pond ecology, Design, Fish quality, Fish health. |
| 5 | Type | enum | Field, Data analysis, Literature review. |
| 6 | Operational area | enum | Hatcheries, Juvenile, Grow out, Mixed. |
| 7 | Farms | enum-ish | Silverwater, Euberta, Bilbul, Bilbul RAS, McFarlens, Whitton, Stanbridge, Mixed, External. |
| 8 | Summary | free text | One-paragraph what/why of the project. |
| 9 | Supporting document link | URL | SharePoint link to proposal/spec doc. |
| 10 | Files (Sharepoint folder link) | URL | **Maps register row → SharePoint project folder.** |
| 11 | Next review date | date | |
| 12 | Planned start | date | |
| 13 | Planned finish | date | |
| 14 | Actual start | date | |
| 15 | Actual finish | date | |
| 16 | Approver | string | Person name. |
| 17 | Decision | enum | Unconsidered, Pending, Approved, Cancelled, Rejected. |
| 18 | Decision date | date | |
| 19 | Decision notes | free text | |
| 20 | Organisations involved | enum-ish | MCA, Biomar, Deakin, Nutrisea, CSIRO, ... |
| 21 | Estimated cost | number | |
| 22 | Budget | number | |
| 23 | Actual cost | number | |
| 24 | Estimated benefit | number | |
| 25 | Estimated effort, person hours | number | |
| 26 | Estimated days span | number | |
| 27 | Originator | string | Person name. |
| 28 | Outcome document link | URL | Link to final report. |
| 29 | Outcome summary | free text | One-paragraph finding. |
| 30 | Added on | date | When the row was first added to the register. |
| 31 | Confidential | enum | Yes / No. |
| 32 | Keywords | free text | Comma-separated tags. |

### Sheet 2: `OptionsLists`

Controlled vocabularies powering the dropdowns in sheet 1: Status, Priority, Domain, Type, Operational area, Farms, DecisionOptions, Organisations involved.

When updating the register, new values for any of these columns must either match an existing option or extend the OptionsLists sheet first.

## Editable-by-overseer vs. user-only columns

(To be confirmed — proposed.)

**Likely safe for overseer to write from per-project agents:**
- Status (lifecycle changes when project starts/finishes)
- Actual start / Actual finish
- Outcome document link, Outcome summary (when finished)
- Summary (if the per-project repo restates its purpose)
- Keywords
- Next review date

**Likely manager-only (user owns):**
- Approver, Decision, Decision date, Decision notes (governance metadata)
- Estimated cost / Budget / Actual cost / Estimated benefit (finance)
- Priority (manager judgement)
- Confidential (manager judgement)
- Added on (set once)

## Snapshot of populated rows (intake reference, 2026-05-21)

27 projects. Mix of Finished (15+) and In progress (8). Several already correspond to per-project intakes already in `target-projects/`:
- "Bile staining" → `bile-staining`
- "2025 RAS feed trial" → `ras-feed-biomar-2025`
- "Gut evacuation" → `gutevac` / `stanbridge-gutevac`
- "Artemia enrichment" → `artemia-enrichment`
- "Chlorella and PSB ST1" → `chlorella-psb`
- "Stanbridge feed trial" → `stanbridge-feed-trial`
- ... etc.

This 1:1-ish mapping is what lets the overseer connect a register row to a local repo and a SharePoint folder.
