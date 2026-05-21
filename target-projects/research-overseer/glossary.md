# Glossary — research-overseer

Project-specific vocabulary. Warehouse-level terms ([[skill]], [[library]], [[build chain]], [[ADR]], ...) live in the warehouse glossary; this file only defines terms unique to the overseer.

---

## register

**Avoid**: `xlsx`, `the spreadsheet`, `RnD projects register.xlsx` (those refer to the file; "register" refers to the data).

The master record of R&D research projects. Lives as `sharepoint_planning:PROJECTS/RnD projects register.xlsx`. Two sheets: `Projects` (row-per-project, 32 used columns) and `OptionsLists` (controlled vocabularies). See [[register-shape]] for full schema.

The register is a **downstream view** rendered from the constellation of [[entry-yaml]] files. It is not authoritative — see [[0001-entry-yaml-canonical]].

**Example**: "Sweep the register" = read the XLSX. "Apply to the register" = write the XLSX. "Manager edits the register" = strictly speaking, manager edits the per-project entry.yaml; calling it "register editing" is shorthand.

---

## entry-yaml

**Avoid**: `the yaml`, `metadata file`, `register row` (the entry corresponds to a register row but isn't one).

A per-project YAML file at `.register/entry.yaml` (relative to a per-project research repo root). Holds the canonical values for that project's row in the [[register]]. Maintained by the per-project [[update-register-entry]] skill; consumed by the overseer's [[reconcile-register]] skill.

Has a `_meta` sidecar (`_meta.intentionally_blank`, `_meta.last_populated`, `_meta.populated_by`) to distinguish "unknown — ask" from "intentionally blank — skip."

**Example**: "The Gut clearance entry.yaml is stale" = the file's `_meta.last_populated` is older than the corresponding project work.

---

## slug

**Avoid**: `id`, `name`, `key`.

A stable kebab-case identifier for a research project, e.g. `gut-clearance-2026`. Stored in both `register.Slug` (column added per [[0002-slug-column-for-stable-identity]]) and `entry.yaml.id`. Survives Title renames. The overseer's primary join key across surfaces.

**Example**: "What slug?" → "gut-clearance-2026." Never "What's the title?" when you mean identity.

---

## reconcile / reconciliation

**Avoid**: `sync` (that's `/sharepoint-sync`, a different operation).

The act of sweeping all [[entry-yaml]] files, computing the diff against the current [[register]], applying clean diffs, queuing conflicts, and uploading the updated XLSX. Invoked via `/reconcile-register`. Single-batch.

**Example**: "Reconcile the register" = run the sweep + apply pass. Distinct from "sync the SharePoint mirror" which is the rclone-driven file copy.

---

## sweep

The read-only first half of a reconciliation: walk `~/ResearchProjects/*/.register/entry.yaml` (and optionally the SharePoint mirror for projects without a local clone), collect all entry data into an in-memory map keyed by slug. Distinguished from the *write* half (apply).

---

## drift

Any divergence the overseer notices between expected and actual state. Four classes:
1. Register row exists with no `entry.yaml` (project not cloned locally, or entry never created).
2. `entry.yaml` exists with no matching register row (new project not yet registered).
3. Field value in `entry.yaml` differs from register cell.
4. Cell value not in the OptionsLists controlled vocabulary.

Surfaced by `/detect-drift` (read-only) and by `/reconcile-register` as a side effect.

---

## intentionally blank

A field in `entry.yaml` that is null AND listed in `_meta.intentionally_blank`. Means: the human knows this field's value is unavailable and the agent should not ask about it again. Distinct from `null` alone, which means "unknown — ask next run."

**Example**: a small finished project with no funding might have `estimated_cost: null` and `intentionally_blank: [estimated_cost]` — the per-project agent skips the prompt every run.

---

## tier (auth-gate tier)

The destructive-ops auth model — see [[0004-tiered-destructive-ops-auth-gate]]. Three tiers (low / medium / high) matched to risk. When discussing an action: "What tier is this?" tells you which confirmation pattern applies.

---

## sweep target

A directory the overseer enumerates when sweeping. Two kinds: **local sweep targets** (sibling repos under `~/ResearchProjects/*/`) and **remote sweep targets** (SharePoint folders under `sharepoint_planning:PROJECTS/`). The overseer prefers local when both are available, falling back to remote for projects without a local clone.
