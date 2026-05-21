# ADR-0001 — `entry.yaml` is canonical for all register fields; XLSX is a downstream view

**Status**: Accepted (intake 2026-05-21)

## Context

The research projects register lives as `sharepoint_planning:PROJECTS/RnD projects register.xlsx`. Historically the manager has edited it directly via the SharePoint Excel UI. We are introducing per-project agents that maintain a structured `.register/entry.yaml` at each project repo root, which the research-overseer sweeps and writes back to the XLSX in a single batch via `/reconcile-register`.

We need to decide: when a per-project `entry.yaml` and a register row disagree, which wins?

## Decision

**`.register/entry.yaml` files are the canonical source of truth for every field in the register, including manager-only fields.** The master XLSX is a downstream rendered view of the constellation of `entry.yaml` files. Manual edits made directly to the XLSX (via SharePoint Excel UI) do **not** survive the next `/reconcile-register` sweep — they are overwritten.

Manager-only fields (Approver, Decision, finance, Priority, Confidential, Originator) are still owned by the human, but the human edits them in the per-project `entry.yaml`, not in the XLSX. The per-project `/update-register-entry` skill prompts the human for unknowns and writes the result to `entry.yaml`.

## Consequences

**Positive:**
- Single source of truth eliminates two-way merge complexity.
- Per-project repos own their data; the register becomes a derived artifact.
- Diffs are reviewable in git on the `entry.yaml` files.
- Manager edits cannot silently disagree with reality on disk.

**Negative:**
- Surprising for anyone trained on Excel. The XLSX *looks* editable but isn't.
- Requires a clear warning at the top of the XLSX (e.g. a banner row, or a `_README` sheet) and in the overseer's CLAUDE.md.
- If the manager edits the XLSX during a sweep window, their edit is lost without warning. Mitigation: weekly schedule runs at a low-traffic time; manual `/reconcile-register` is announced.

## Alternatives considered

- **(ii) entry.yaml proposes; human reviews; only applied diffs land.** Rejected for friction: every sweep would require per-field confirmation.
- **(iii) Hybrid (auto-apply if no manual edit detected).** Rejected because detecting manual register edits is brittle — Excel files have no clean per-cell change log.

## Related

- [[register-shape]] — what the XLSX contains.
- [[update-register-entry]] — the per-project skill that maintains `entry.yaml`.
- [[reconcile-register]] — the overseer skill that applies entry.yaml → XLSX.
