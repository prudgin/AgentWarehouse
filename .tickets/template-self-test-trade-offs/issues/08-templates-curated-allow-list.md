**Status:** ready-for-agent
**Category:** enhancement
**Type:** AFK

## Parent

[../PRD.md](../PRD.md). Implements [ADR-0023](../../../docs/adr/0023-templates-ship-curated-broad-allow-list.md).

## What to build

Replace each template's minimal `.claude/settings.json` (currently just two `rm -r*` denies) with a curated broad allow-list above a uniform tight deny floor. Use the warehouse's own `.claude/settings.json` as the reference shape, but trim warehouse-specific entries (e.g., `unzip -p` patterns used for poking at docx files during the warehouse's own setup) and add per-template additions where the template's nature requires them.

Specifically:

1. **Common base** (all four templates):
   - **Allow** — Read, Edit, Write, NotebookEdit, Glob, Grep, WebFetch, WebSearch.
   - **Allow Bash** (read-only) — `ls*`, `cat*`, `head*`, `tail*`, `wc*`, `find*`, `grep*`, `rg*`, `tree*`, `diff*`, `stat*`, `file*`, `readlink*`, `pwd`, `test*`, `true`, `false`, `echo*`.
   - **Allow Bash** (safe text/data) — `jq*`, `sed*`, `awk*`, `tr*`, `sort*`, `uniq*`, `cut*`, `xargs*`.
   - **Allow Bash** (file ops) — `cp*`, `mv*`, `mkdir*`, `touch*`, `ln*`.
   - **Allow Bash** (Python tooling) — `python*`, `python3*`, `pytest*`.
   - **Allow Bash** (safe git) — `git status*`, `git diff*`, `git log*`, `git show*`, `git branch*`, `git remote -v`, `git config --get*`, `git ls-files*`, `git rev-parse*`, `git add*`, `git commit*`, `git checkout -b*`, `git switch*`, `git init*`, `git mv*`.
2. **Per-template additions**:
   - `tool-integration` adds `Bash(_tools/*)` and `Bash(./_tools/*)` so the tool-wrapping bash scripts can execute.
   - `library`, `pipeline`, `analysis` — no additions beyond the common base.
3. **Deny floor (uniform across all four templates)**:
   - `Bash(rm -rf*)`, `Bash(rm -r*)`, `Bash(rm -f /*)`, `Bash(rm /*)`.
   - `Bash(sudo*)`.
   - `Bash(git push --force*)`, `Bash(git push -f*)`, `Bash(git push --force-with-lease*)`.
   - `Bash(git reset --hard*)`, `Bash(git clean -f*)`, `Bash(git clean -fd*)`.
   - `Bash(git checkout -- *)`, `Bash(git checkout .*)`, `Bash(git restore --staged*)`.
   - `Bash(git branch -D*)`, `Bash(git branch --delete --force*)`.
   - `Bash(git rebase*)`, `Bash(git filter-branch*)`.
   - `Bash(chmod 777*)`.
   - `Bash(curl * | sh*)`, `Bash(curl * | bash*)`, `Bash(wget * | sh*)`, `Bash(wget * | bash*)`.
4. Validate each resulting `.claude/settings.json` is parseable JSON (`jq . < .claude/settings.json` exits 0).

## Acceptance criteria

- [ ] All four templates' `.claude/settings.json` ship the curated allow-list + uniform deny floor.
- [ ] `tool-integration` template includes `Bash(_tools/*)` and `Bash(./_tools/*)` allows; the other three templates do not.
- [ ] Each settings.json is valid JSON.
- [ ] No `Bash(rm *)` blanket allow in any template (the user added that locally to the warehouse, but it's intentionally not in the template default — the deny floor catches the destructive variants and the safer pattern is to add specific `rm` allows per project as needed).
- [ ] No regression to the warehouse's own `.claude/settings.json` (it's a separate file, intentionally tuned for warehouse work).

## Blocked by

None — can start immediately.

## Comments

(empty)
