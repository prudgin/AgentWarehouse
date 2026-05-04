---
name: finish-analysis
description: Finalise an investigation: verify REPORT.md is complete, promote findings into glossary.md / docs/domain/ / docs/adr/ / docs/planning/future-work.md as applicable, lock the landscape entry, optionally spawn build-chain tickets if findings imply changes. Use when the user says "finish the analysis", "wrap up the investigation", or after an analysis run is complete. Auto-mode safe; pauses for confirmations on cross-doc promotions.
---

# Finish Analysis

End-of-investigation ritual. Closes out an investigation cleanly so its findings land where they belong instead of staying trapped in the analysis dir.

This skill is auto-mode safe for verification work. It pauses to confirm any **cross-doc promotion** (writing to glossary.md, docs/domain/, docs/adr/, docs/planning/future-work.md) before doing it — those edits are durable and shouldn't be silent.

## Process

### 1. Locate the investigation

If the user passes a topic or path, use it. Otherwise look for the most recent `analysis/YYYY-MM-DD-*` dir with `Status: in-progress` in its REPORT.md.

If multiple in-progress investigations exist, ask which one (in interactive mode) or refuse and ask the user to specify (in auto mode).

### 2. Verify the REPORT is complete

Open `REPORT.md`. Check that each required section has real content (not the placeholder text from the stub):

- **Question** — was anything actually asked?
- **Method** — is there a description of what was done?
- **Findings** — are there evidenced results, not just plans?
- **Implications** — has the user thought about what changes downstream?
- **Open ends** — has the user noted what's left, even if "nothing"?

If any section is still the stub, **stop and surface** — the user needs to fill it before finishing.

Auto-update the "Date" line to add the finish date and the "Status" line to `complete`.

### 3. Read the Implications section carefully

The implications section is what drives downstream promotions. Look for:

- **New term resolved** → propose adding to `glossary.md`.
- **Domain mechanic discovered** → propose adding to or extending a doc in `docs/domain/`.
- **Architectural decision crystallised** → check 3-of-3 admission test; if it passes, propose an ADR.
- **Code change implied** → propose a `future-work.md` entry, or a direct `/to-prd` / `/to-issues` invocation.
- **Investigation invalidated a previous one** → propose marking the old one as superseded in the landscape.

For each proposal, **ask the user to confirm** before writing. Show what you'd write and where. In auto mode, don't write — surface all proposals together for the user to review on return.

### 4. Verify all output files are accounted for

Walk the dir contents. Every file should be either:

- Referenced from REPORT.md (script, plot, output table).
- In `outputs/` (gitignored, no need to reference).

Surface any orphan files (e.g. a `scratch.py` not mentioned in the REPORT). Either move to `outputs/`, mention in REPORT, or delete (with confirmation).

### 5. Lock the landscape entry

Update the entry in `analysis/analysis-landscape.md`:

- Change "Status: in-progress" → "Status: complete".
- Replace the one-sentence question with the **finding** (one or two sentences) and what landed downstream.
- Format: `- **YYYY-MM-DD — <topic>.** <finding>. Landed: <list of doc updates>. → [REPORT](...)`

If the investigation has explicit open ends, add or update the "Open ends" section at the bottom of the landscape with a link back to this REPORT.

### 6. Verify reachability (no-orphan check)

The investigation directory must be linked from `analysis/analysis-landscape.md`. Verify after the lock step.

If the directory contains REPORT.md and the landscape entry is in place, you're good.

### 7. Optional: spawn build-chain tickets

If the implications section notes code changes that should happen, ask the user whether to:

- Add an entry to `docs/planning/future-work.md` (lightweight, deferred).
- Run `/to-prd` immediately to create a PRD from this REPORT's content.
- Run `/to-issues` directly if the change is small and well-specified.

Default: add to future-work.md (most flexible). Don't auto-spawn tickets without confirmation.

### 8. Report

- **Investigation:** topic, path.
- **REPORT status:** complete.
- **Landscape entry:** updated, snippet shown.
- **Promotions confirmed:** list of glossary/domain/adr/future-work updates that landed.
- **Promotions pending:** anything you proposed but the user (or auto mode) deferred.
- **Suggested next step:** if the investigation implied build work, suggest `/to-prd` or adding to `future-work.md`.

## What this skill does NOT do

- Does not write findings into the REPORT — that's the work of the investigation itself, before this skill runs.
- Does not silently modify glossary.md, docs/domain/, docs/adr/, or future-work.md without confirmation.
- Does not delete the investigation dir — analysis dirs are append-only history.
- Does not auto-create tickets without explicit confirmation.
