**Status:** ready-for-agent
**Category:** enhancement

## What to build

Update `/create-project` (and `/migrate-project` for the CLAUDE.md transfer step, if it copies the template's CLAUDE.md) to strip the leading `<!-- TEMPLATE META — delete this block when putting the template to use. ... -->` block from the scaffolded project's CLAUDE.md.

Detection: the block is the first `<!-- ... -->` HTML comment in the file, starting on line 1, and contains the literal phrase "TEMPLATE META". Strip the entire block, then trim any leading blank lines.

## Why

All four self-test subagents flagged the META block surviving into scaffolded projects. It pollutes the project's CLAUDE.md with warehouse-meta reasoning ("Pipeline variant of the library template. Differs in: ...") that's only useful at scaffold time. Subagents had to recognise and remove it by hand.

## Acceptance criteria

- [ ] `/create-project` strips the META block at step 5 (placeholder substitution) or step 6 (post-substitution scrub).
- [ ] `/migrate-project` strips the META block from the staged-CLAUDE.md handoff if it transfers it.
- [ ] Tested by scaffolding a project from each of the four templates and grepping for "TEMPLATE META" in the result — should be zero hits.

## Blocked by

None.

## Comments

(empty)
