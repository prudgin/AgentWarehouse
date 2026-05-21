---
name: update-register-entry
description: Maintain a research project's `.register/entry.yaml` — the per-project record of register-relevant data consumed by the research-overseer's `/reconcile-register`. Prompts the human for fields the agent doesn't know; respects `_meta.intentionally_blank` so re-runs don't re-ask. Auto-invoked from `/finish` in research-template projects. Use when the user says "update the register entry", "what's in our register entry", or at end-of-session in a research project.
---

# Update Register Entry

Per-project skill. Maintains `.register/entry.yaml` at the repo root — the canonical record for this project's row in the master R&D research projects register. The research-overseer sweeps these files and reflects them into `sharepoint_planning:PROJECTS/RnD projects register.xlsx`.

This skill is auto-mode safe except for the interactive "ask the human" branch — when the human is absent (auto mode with no terminal), unknowns stay null (not marked intentionally-blank) and the next interactive run will ask.

## When this skill runs

- **Auto-invoked from `/finish`** in research-template projects (per ADR-0006 in `research-overseer`).
- **Manual**: when the user says "update register entry", "set the register status", or wants to push a status change without finishing a session.

## Where this skill applies

The current working directory must be a research-template project (i.e. lives under `~/ResearchProjects/<Project Name>/` with a `.rclone-filter` at the root). If not, refuse and surface why.

## The entry.yaml schema

Lives at `.register/entry.yaml` (canonical home — see ADR-0001 in research-overseer). One file per project. YAML structure:

```yaml
# Stable identifier. Assigned at first run; never changes.
# Matches register.Slug. Used by the overseer as the join key.
id: gut-clearance-2026

# Agent-populated (set from project state, refreshed each run)
title: 2026 Gut Clearance
status: In progress              # OptionsLists: New | Scoping | Approved | Planned | In progress | On hold | Finished | Cancelled
actual_start: 2026-01-30          # date or null
actual_finish: null
outcome_document_link: null
outcome_summary: null
summary: |
  Gut clearance over time after fasting start across MCA RAS facilities.
keywords: gut clearance, fasting, thermal time, degree-hours
next_review_date: null
added_on: 2026-02-03               # date the row was first added to the register

# Static-ish (set at intake from target-projects/<name>/; rarely change)
domain: Fish quality              # OptionsLists: Feed | Water Quality | Process | Data | Genetics | Pond ecology | Design | Fish quality | Fish health
type: Field                       # OptionsLists: Field | Data analysis | Literature review
operational_area: Grow out        # OptionsLists: Hatcheries | Juvenile | Grow out | Mixed
farms: Mixed                      # OptionsLists: Silverwater | Euberta | Bilbul | Bilbul RAS | McFarlens | Whitton | Stanbridge | Mixed | External
organisations_involved: MCA
planned_start: 2026-01-30
planned_finish: 2026-11-01
supporting_document_link: https://murraycod.sharepoint.com/...
files_link: https://murraycod.sharepoint.com/...

# Manager-only (set by the human, agent never decides autonomously — only prompts)
approver: Mat Ryan
decision: Approved                # OptionsLists: Unconsidered | Pending | Approved | Cancelled | Rejected
decision_date: 2026-01-01
decision_notes: null
estimated_cost: null
budget: null
actual_cost: null
estimated_benefit: null
estimated_effort_person_hours: null
estimated_days_span: 275
priority: High                    # OptionsLists: Low | Medium | High
confidential: 'No'                # Yes | No (kept as string for OptionsLists match)
originator: Mat

# Sidecar — agent reads on every run; updates last_populated and populated_by
_meta:
  intentionally_blank:
    - estimated_cost
    - estimated_benefit
  last_populated: 2026-05-22
  populated_by: agent              # agent | human
```

## Field ownership

Three classes:

- **Agent populates** (refresh every run from project state): `title`, `status`, `actual_start`, `actual_finish`, `outcome_document_link`, `outcome_summary`, `summary`, `keywords`, `next_review_date`, `added_on`.
- **Static-ish** (set at intake; carry forward unless project shape changes): `domain`, `type`, `operational_area`, `farms`, `organisations_involved`, `planned_start`, `planned_finish`, `supporting_document_link`, `files_link`.
- **Manager-only** (agent never decides; prompts human when null and not intentionally-blank): `approver`, `decision`, `decision_date`, `decision_notes`, `estimated_cost`, `budget`, `actual_cost`, `estimated_benefit`, `estimated_effort_person_hours`, `estimated_days_span`, `priority`, `confidential`, `originator`.

See `docs/domain/register-shape.md` in `research-overseer` for the full register schema.

## The intentional-blank protocol

For every field, three states:
- **Non-null value** → use it. Don't ask.
- **Null AND in `_meta.intentionally_blank`** → skip silently. The human said this is unknowable; do not re-ask.
- **Null AND NOT in `_meta.intentionally_blank`** → ask the human. If they provide a value, write it. If they say "leave blank" or "skip", add the field name to `_meta.intentionally_blank` and don't ask again.

For **agent-populated** fields, the agent refreshes the value from project state each run (overwriting). The intentional-blank protocol applies only when the agent cannot determine the value from project state — then it asks.

For **static-ish** fields, the agent reads them at first run from `~/AgenticEngineering/target-projects/<name>/_warehouse/intake-notes.md` if present (during initial bootstrap), then carries them forward. Re-asks only if the field is null.

## Process

### 1. Locate and load

- Verify cwd is a research-template project (`.rclone-filter` present, lives under `~/ResearchProjects/`).
- Read `.register/entry.yaml` if it exists. If not, start with an empty schema and proceed (first run / bootstrap).
- Read the project's `CLAUDE.md` and `target-projects/<projname>/` staging if available, to seed agent-populated and static-ish defaults.

### 2. Refresh agent-populated fields

For each agent-populated field, compute the current value from project state:

- `title`: project dir name (verbatim).
- `status`: inferred from project signals. Default: keep existing value; the agent should ask the human if it can detect a transition (e.g. `Reports/` newly populated → propose "Finished"). Heuristic only.
- `actual_start`: earliest commit date in repo, or first sync-down date, whichever is older. Don't overwrite if already set.
- `actual_finish`: if status changed to "Finished" and not yet set, ask the human for the finish date.
- `outcome_document_link`: scan `Reports/` for files with names matching `*outcome*`, `*final*`, `*summary*` and offer the latest. Otherwise leave null.
- `outcome_summary`: prompt only when `status == Finished`. Ask the human; if they decline, mark intentionally_blank.
- `summary`: read from CLAUDE.md's "What this project is" section first paragraph. Don't overwrite if already set by human.
- `keywords`: derive from glossary.md top-level terms + CLAUDE.md keywords if present. Prompt only on first run.
- `next_review_date`: prompt human; usually 3 months out for "In progress", 6+ months for "On hold".
- `added_on`: set at first run; never overwrite.

### 3. Process unknown manager-only fields

For each manager-only field that is `null` and NOT in `_meta.intentionally_blank`:

- Ask the human (one prompt per field, plain text response).
- If they answer with a value, store it.
- If they reply `skip`, `unknown`, `leave blank`, or similar, add the field to `_meta.intentionally_blank` and move on.

In auto mode (no human present), skip the prompts but leave fields null — they'll be picked up on the next interactive run.

### 4. Validate against OptionsLists

For enum-typed fields, check the value is in the controlled vocabulary. If a new value is provided that isn't in OptionsLists, surface this — the overseer's `/reconcile-register` will need to extend OptionsLists (medium-tier confirmation).

Enum-typed fields:
- `status` ∈ {New, Scoping, Approved, Planned, In progress, On hold, Finished, Cancelled}
- `priority` ∈ {Low, Medium, High}
- `domain` ∈ {Feed, Water Quality, Process, Data, Genetics, Pond ecology, Design, Fish quality, Fish health}
- `type` ∈ {Field, Data analysis, Literature review}
- `operational_area` ∈ {Hatcheries, Juvenile, Grow out, Mixed}
- `farms` ∈ {Silverwater, Euberta, Bilbul, Bilbul RAS, McFarlens, Whitton, Stanbridge, Mixed, External}
- `decision` ∈ {Unconsidered, Pending, Approved, Cancelled, Rejected}
- `confidential` ∈ {Yes, No}

### 5. Update meta and write

- Set `_meta.last_populated` to today's date.
- Set `_meta.populated_by`: `agent` if called from `/finish`, `human` if invoked interactively with human prompts answered.
- Write YAML to `.register/entry.yaml`. Preserve key order matching the schema above.

### 6. Report

Print a one-line summary: how many fields were refreshed, how many human prompts were answered, how many fields are still intentionally_blank.

## Bootstrap from existing register row

If this is a first run AND the project already has a corresponding register row (i.e. it was added manually before the overseer existed), seed `entry.yaml` from the register row before prompting:

- The overseer's `_tools/register-read.py` can extract a single row by title or slug. Call it with `--title "<exact title>"` or `--slug <slug>` and parse the JSON output.
- For each register cell value, if non-null, set the corresponding entry.yaml field.
- Then proceed with steps 2–5 normally; the human is only asked about fields the register row also didn't have.

This is the path used during Phase 4 bootstrap of the research-overseer.

## Errors

- **Project is not research-template**: refuse with explanation. Suggest the user wants `/grill` or some other skill instead.
- **Conflicting slug**: `entry.yaml.id` is already set to a slug that the overseer has flagged as taken by another repo. Refuse to write; surface the conflict.
- **`/register/` dir does not exist**: create it.
- **Network error reading register**: continue with what's locally known; warn that initial-bootstrap may pick up stale defaults.

## What this skill does NOT do

- Does not upload anything to SharePoint. That happens via `/sharepoint-sync push` (which `/finish` calls separately).
- Does not write to the master register XLSX. That's the overseer's `/reconcile-register`.
- Does not validate cross-project state (e.g. slug uniqueness across all repos). That's the overseer's job.
