# Upstream sources

The pipeline has one upstream: a Power Automate HTTP-triggered flow that reads from the WQ SharePoint site on behalf of the pipeline. The pipeline never connects to SharePoint directly.

## WQ Reader Proxy flow

- Repo: `~/MicrosoftFlowsApps/flows/WQ_Reader_Proxy/`
- Trigger: HTTP `POST` with `triggerAuthenticationType: All` (SAS-signed URL).
- SharePoint site: `https://murraycod.sharepoint.com/sites/WaterQuality`
- Connector: `shared_sharepointonline` `GetItems`.

Trigger body fields:

| Field | Type | Purpose |
|---|---|---|
| `op` | string | `items` (default) or `lists` |
| `list` | string | List GUID or display name (required for `op=items`) |
| `filter` | string | OData `$filter` (optional) |
| `top` | integer | `$top` (optional, default = all) |
| `orderby` | string | `$orderby` (optional) |
| `view` | string | SharePoint view name/GUID for column selection (optional) |

Response: JSON `{ items: [...] }` for `op=items`, `{ lists: [...] }` for `op=lists`.

## SharePoint lists mirrored

All six non-AI lists from the WQ_WaterQuality_sp PowerApp. Schemas below are from `~/MicrosoftFlowsApps/apps/WQ_WaterQuality_sp/src/DataSources/`.

### `WQ_Readings` — facts

| Column | Purpose |
|---|---|
| `ID` | SP row id |
| `Farm`, `Site`, `Unit`, `UnitId` | WQ-native identifiers (denormalised from `WQ_Units`) |
| `EnteredByInitials` | operator |
| `ReadingDate`, `ReadingTime`, `ReadingDateTime` | timestamps; `ReadingDateTime` is the canonical one (others are display fields) |
| `pH`, `TAN`, `Nitrite`, `Chloride`, `Alkalinity`, `CaHardness`, `FreeCopper1`, `FreeCopper2`, `TurbidityNTU`, `Nitrate`, `Phosphorus`, `GHardness`, `Temperature`, `Salinity` | parameter values |
| `Notes` | free text |
| `Created`, `Modified`, `Author`, `Editor` | SP system fields |

`UnitId` is NA for [site-level readings](../../glossary.md#site-level-reading).

### `WQ_Units` — unit dimension

Columns: `ID`, `Title`, `Farm`, `Site`, `Unit`, `UnitId`. Operator-maintained. `UnitId` is the value stamped onto `WQ_Readings.UnitId`.

### `WQ_Sites` — site dimension

Columns: `ID`, `Title`, `Farm`, `Site`, `IsSiteLevelReading`. The `IsSiteLevelReading` flag distinguishes pond-as-unit farms (false) from cages-in-pond farms (true).

### `WQ_Farms` — farm dimension and terminology overrides

Columns: `ID`, `Title`, `Farm`, `SiteLiteral`, `UnitLiteral`. The two `*Literal` columns let each farm rename "site" and "unit" in the PowerApp UI (e.g. "Pond" instead of "Site"). Not relevant to the pipeline's data model but mirrored for downstream display.

### `WQ_ParameterRanges` — per-farm thresholds

Columns: `ID`, `Title`, `Farm`, `Parameter`, `GreenMin`, `GreenMax`, `YellowMin`, `YellowMax`, `SanityMin`, `SanityMax`. Drives the PowerApp's colour coding. Downstream QA can use these for range alerts without re-encoding them.

### `WQ_Flags` — flagged-reading audit

Columns: `ID`, `Title`, `ReadingTitle`, `Farm`, `Site`, `Unit`, `UnitId`, `Parameter`, `ValueNum`, `Severity`, `IsAcknowledged`, `AcknowledgedBy`, `AcknowledgedAt`, `ReadingDateTime`. Derived from `WQ_Readings` + `WQ_ParameterRanges` at flag-time inside the PowerApp; carries ack state that is not reconstructible from elsewhere, so we mirror it as-is.

## Lists explicitly NOT mirrored

`WQ_AI_Config`, `WQ_AI_Requests` — PowerApp-internal scratchpad for an LLM feature. Not domain data.
