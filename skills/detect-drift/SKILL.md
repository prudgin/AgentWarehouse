---
name: detect-drift
description: Read-only drift report between the master R&D register XLSX and per-project `.register/entry.yaml` files. Surfaces orphans, conflicts, OptionsLists violations, missing entry.yaml files. Never writes. Use when the user says "any drift?", "are we behind on the register?", "what's stale?", or as a dry-run before `/reconcile-register`. Auto-mode safe.
---

# Detect Drift

Read-only sibling of `/reconcile-register`. Produces the same diff report without applying anything.

## Where this skill applies

Only in `~/ResearchProjects/research-overseer/`. Refuse elsewhere.

## Process

1. `cd ~/ResearchProjects/research-overseer`
2. `.venv/bin/python _tools/register_io.py download`
3. `.venv/bin/python _tools/diff_register.py`
4. Format the JSON output as a human-readable report:

```
DRIFT REPORT — <date>

Register XLSX: sharepoint_planning:PROJECTS/RnD projects register.xlsx
Local repos under: ~/ResearchProjects/

== Clean changes pending apply ==
<N> fields across <M> rows. Run /reconcile-register to apply.
  - gut-clearance-2026: status, actual_start
  - bile-staining-2025: outcome_summary
  ...

== New register rows pending creation ==
<C> repos have entry.yaml with no matching register row.
  - chlorella-st2-2026 — ~/ResearchProjects/2026 Chlorella PSB ST2/

== Orphan register rows (no local entry.yaml) ==
<O> register rows are not represented locally.
  - Reduction of Geosmin (& MIB) — slug: reduction-of-geosmin-mib
  - Pond water remediation — slug: pond-water-remidiation
  ...

== Repos without entry.yaml (needs /update-register-entry) ==
<R> repos under ~/ResearchProjects/ lack a .register/entry.yaml.
  - ~/ResearchProjects/2022 Whitton Feed Trial
  ...

== OptionsLists violations ==
<V> entry.yaml values don't match the controlled vocabulary.
  - gut-clearance-2026 — domain="Fish biology" (allowed: Feed, Water Quality, ...)

== Blocking conditions ==
- Duplicate slugs: <list>
- Errors: <list>

== Schema state ==
- Slug column present: yes/no
```

5. If `has_slug_column` is false, prominently flag: "Slug column not yet added to register; first `/reconcile-register` will add it (medium-tier confirm)."

## Auto-mode behaviour

This skill is fully read-only. Auto mode runs it end-to-end and prints the report. The report goes into the conversation; no human prompt needed.

## What this skill does NOT do

- Does not modify any file (locally or on SharePoint).
- Does not file follow-up tickets — that's `/reconcile-register`'s job after a real reconciliation.

## Related

- `/reconcile-register` — apply variant.
- `_tools/diff_register.py` — the underlying engine.
