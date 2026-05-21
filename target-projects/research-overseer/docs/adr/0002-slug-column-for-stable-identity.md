# ADR-0002 — Stable project identity via a `Slug` column on the register

**Status**: Accepted (intake 2026-05-21)

## Context

The register Title column is the human-facing name of a project, but Titles drift over time (e.g. "Gut clearence" → "Gut clearance" → "Gut evacuation"). The per-project `entry.yaml` needs a stable link to its register row so renames don't silently fork projects (manager renames "Gut evacuation" → "Gut clearance" and the next sweep treats the old row as orphaned while creating a new row for the new name).

The existing register has no stable identifier column. "Files (Sharepoint folder link)" is partly there but not all rows have it and the URLs can change.

## Decision

Add a `Slug` column to the register. Stable kebab-case identifier assigned at row creation, e.g. `gut-clearance-2026`. Stored both in `register.Slug` and `entry.yaml.id`. The overseer matches `entry.yaml.id` to `register.Slug`; the Title column is then free to change without breaking the link.

One-time migration step (run by overseer at first reconcile): generate slugs for the 27 existing rows from current Titles, write them to `register.Slug`, propose corresponding `entry.yaml.id` values for any local repos that already exist.

## Consequences

**Positive:**
- Renames of Title are safe.
- Cross-surface identity is unambiguous (entry.yaml ↔ register row ↔ per-project repo dir).
- Slug is human-readable enough to use in conversations ("the chlorella-st1 project").

**Negative:**
- Schema change to the register XLSX. Manager has to leave the column alone.
- Slug collisions (two projects with similar names) need disambiguation — overseer asks the human at first conflict.

## Alternatives considered

- **Title-only link.** Rejected: brittle to renames.
- **Use "Files (Sharepoint folder link)" as the identifier.** Rejected: not always populated; URL can change; not human-readable; no per-row guarantee.

## Related

- [[register-shape]]
- [[update-register-entry]]
- [[entry-yaml]] (glossary)
