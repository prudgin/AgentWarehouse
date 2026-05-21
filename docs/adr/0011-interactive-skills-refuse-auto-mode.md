# Interactive skills do NOT refuse auto mode (reversed 2026-05-22)

**Status:** reversed.

## Original decision

Skills that ask the user questions one at a time (`/grill`, `/intake-target-project`, `/to-issues`, `/triage`, `/improve-codebase-architecture`) detected auto mode at invocation and exited cleanly with a short message: "This skill requires interactive mode. Switch and re-invoke." The reasoning was that asking questions to nobody risked silent misalignment.

## What changed

The premise was wrong. Auto mode does not disable user-facing questions — it only biases the agent to avoid pausing for clarifications it could resolve on its own. The auto-mode reminder is explicit: *"If the user, a skill, or the shape of the task suggests they want you to ask (with `AskUserQuestion` or otherwise), do so."* `AskUserQuestion` blocks the turn and waits for the user just the same in auto mode as in interactive mode.

The refusal therefore added pure friction: it forced the user to switch modes before invoking a skill that would have worked identically either way.

[ADR-0016](0016-mixed-mode-for-migrate-and-create.md) already carved out `/migrate-project` and `/create-project` as mixed-mode for a different reason (mechanical bulk with a destructive minority). With this reversal, no warehouse skill refuses auto mode anymore.

## New rule

Interactive skills run regardless of mode. Their SKILL.md states this up front under an "Auto mode is fine" section. The signal to the user that the skill is interactive is the description tagline ("Interactive — uses `AskUserQuestion` turn-by-turn"), not a mode gate.

Skills that genuinely cannot run unattended (none currently exist in the warehouse) would refuse for that reason, not on auto-mode detection.

## Migration

Updated 2026-05-22: `grill`, `to-issues`, `triage`, `intake-target-project`, `improve-codebase-architecture` — all five "Refuse auto mode" sections replaced with "Auto mode is fine" notes; descriptions updated; `skills/README.md` and `docs/reference/skills.md` mirrored. No external child-project copies existed at reversal time, so the warehouse canonical sources cover everything created from this warehouse going forward.
