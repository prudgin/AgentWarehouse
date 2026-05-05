**Status:** ready-for-agent
**Category:** enhancement
**Type:** AFK

## Parent

[../PRD.md](../PRD.md).

## What to build

Extend `/triage` so that flipping a ticket to `Status: wontfix` (with `Category: enhancement`) triggers writing a `.out-of-scope/<concept>.md` entry capturing the rejection rationale. Add deduplication on subsequent similar requests.

Specifically:

1. Update `skills/triage/SKILL.md`:
   - When the user (or an agent in interactive mode) marks an `enhancement`-category ticket as `wontfix`, prompt for a one-paragraph "why rejected" rationale (or pull it from existing ticket comments if substantial).
   - Compute a kebab-cased concept slug from the ticket title (or accept user override).
   - Check if `.out-of-scope/<slug>.md` already exists. If yes: append a "Re-raised in <ticket-ref>: <date>; rationale matches existing entry / new angle: <one line>" line. If no: create the file with the format below.
   - Make the dedup check sensitive enough to catch synonyms — match on title slug AND a fuzzy substring sweep across existing `.out-of-scope/*.md` titles + first paragraphs. When ambiguous, surface "this might be a re-raise of <existing slug> — append, or create new?" rather than silently picking.

2. Define the `.out-of-scope/<concept>.md` format:
   ```md
   # <Title — what was proposed>
   
   ## Decision
   
   Wontfix.
   
   ## Why rejected
   
   <One-paragraph rationale.>
   
   ## Re-raise log
   
   - <YYYY-MM-DD> — `<ticket-ref>` raised this. <Resolved as: matches | new-angle:...>
   ```
   First raise creates the file; subsequent raises append to the Re-raise log.

3. Update `.tickets/README.md` (warehouse) to document the `.out-of-scope/` convention briefly: where it lives (`<project-root>/.out-of-scope/<concept>.md`), when it gets written (by `/triage` on `wontfix` of `enhancement`), what it contains.

4. Propagate the `.out-of-scope/` mention to `templates/{library,pipeline,tool-integration,analysis}/.tickets/README.md` so projects scaffolded post-this know about the convention.

5. Add `.out-of-scope/` to the warehouse's CLAUDE.md documentation map (the warehouse itself can use the pattern). One bullet pointing at the directory.

6. The directory itself is created lazily on first `wontfix` of an enhancement; no need to pre-create or `.gitkeep` it.

## Acceptance criteria

- [ ] `skills/triage/SKILL.md` documents the `.out-of-scope/` write step on `wontfix` + `enhancement`.
- [ ] The dedup matching mechanism is described (slug match + fuzzy title/body sweep, surface ambiguous cases).
- [ ] `.tickets/README.md` (warehouse) documents the convention.
- [ ] Each of the four templates' `.tickets/README.md` mentions the convention.
- [ ] Warehouse `CLAUDE.md` documentation map includes `.out-of-scope/` if/when it exists (or notes the convention so a future maintainer knows to add the bullet on first use).
- [ ] `bash skills/finish/scripts/check-docs.sh --all` passes after the change.

## Blocked by

None — can start immediately.

## Comments

(empty)
