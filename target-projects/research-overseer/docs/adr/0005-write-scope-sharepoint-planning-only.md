# ADR-0005 — Write scope: `sharepoint_planning:` only; `sharepoint:` read-only

**Status**: Accepted (intake 2026-05-21)

## Context

Two SharePoint sites are configured as rclone remotes:
- `sharepoint:` — operational data (BILBUL, WHITTON, STANBRIDGE, MCFARLANES, HEALTH, HARVEST, SOPs, Juvenile sites, Forms & Templates, ...).
- `sharepoint_planning:` — R&D (PROJECTS, PROPOSALS, Papers and literature, Fish health, Finance, Automation, Other).

The overseer's stated scope is "the whole R&D SharePoint." Operationally, that means `sharepoint_planning:`. The operational remote is in scope for *reading* (e.g. cross-referencing farm SOPs or harvest data during a meta-investigation), but writing there would touch shared infrastructure used by farm operations staff.

## Decision

The research-overseer has **write access to `sharepoint_planning:` only**. `sharepoint:` is **read-only** context.

In practice this is enforced by skill design and `_tools/` scripts — every write helper takes the remote name as an argument, but the wrappers only invoke them against `sharepoint_planning:`. A write to `sharepoint:` is treated as a programming error.

## Consequences

**Positive:**
- Blast radius of any overseer bug is confined to R&D state. Farm operations cannot be disrupted.
- Clear separation of agent authorization from human authorization (the user has write access to both; the overseer only inherits part of that).

**Negative:**
- If a future use case needs the overseer to write to operational SharePoint (e.g. dropping a finalised SOP draft), it requires a deliberate ADR amendment.
- Mistakes in `_tools/` scripts that target the wrong remote are silently caught by the rule but might leave the agent confused about why a write "did nothing."

## Alternatives considered

- **Write to both.** Rejected: too broad a blast radius for a v1 overseer.
- **Read-only on both, manual writes only.** Rejected: defeats the purpose of an overseer.

## Related

- [[0004-tiered-destructive-ops-auth-gate]] — even within `sharepoint_planning:`, destructive ops are gated.
