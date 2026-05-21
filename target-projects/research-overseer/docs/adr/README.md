# ADRs — research-overseer

Architecture Decision Records for the overseer. Each ADR passes the 3-of-3 admission test (hard to reverse, surprising without context, real trade-off).

- [0001 — entry.yaml is canonical for all register fields; XLSX is a downstream view](0001-entry-yaml-canonical.md)
- [0002 — Stable project identity via a `Slug` column on the register](0002-slug-column-for-stable-identity.md)
- [0003 — One register row = one per-project repo = one entry.yaml](0003-one-to-one-to-one-mapping.md)
- [0004 — Tiered destructive-ops auth gate](0004-tiered-destructive-ops-auth-gate.md)
- [0005 — Write scope: `sharepoint_planning:` only; `sharepoint:` read-only](0005-write-scope-sharepoint-planning-only.md)
- [0006 — `/update-register-entry` is auto-invoked from `/finish` in research-template projects](0006-update-register-entry-auto-invoked-from-finish.md)
