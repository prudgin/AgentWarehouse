---
name: apply-sharepoint-cleanup
description: Execute an approved cleanup ticket from `/sweep-sharepoint-cleanup`. Reads `.tickets/sharepoint-cleanup-<date>.md`, validates that `status: approved`, applies the checked items, logs each action to a dated `analysis/YYYY-MM-DD-sharepoint-restructure/audit.md`. NEVER auto-applies — the ticket must be explicitly approved. Use when the user says "apply the cleanup", "execute the sharepoint cleanup ticket", or references a specific approved ticket.
---

# Apply SharePoint Cleanup

Destructive execution skill. Pairs with `/sweep-sharepoint-cleanup`. Implements the high-tier auth gate (ADR-0004): destructive ops are queued as a ticket, the human approves the ticket, this skill applies it.

## Where this skill applies

Only in `~/ResearchProjects/research-overseer/`. Refuse elsewhere.

## Process

### 1. Locate and validate the ticket

```bash
TICKET="$1"   # e.g. .tickets/sharepoint-cleanup-2026-05-22.md
```

- Verify the ticket exists.
- Parse the YAML frontmatter. **Require `status: approved`.** If `status: proposed` or anything else, refuse — the human hasn't OKed it.
- Parse the action list: checked items (`- [x]`) are applied; unchecked (`- [ ]`) are skipped.

### 2. Audit-trail setup

```bash
DATE=$(date +%F)
AUDIT_DIR="analysis/${DATE}-sharepoint-restructure"
mkdir -p "$AUDIT_DIR"
```

Open `$AUDIT_DIR/audit.md` for append. Record the source ticket, the timestamp, and a header per action class.

### 3. Apply

For each checked action, in order:

- **Delete empty folder**: `rclone purge "<path>"`. Verify the folder was actually empty first (`rclone lsf -R` returns zero entries) — if not empty, abort that action and log "skipped: not empty (would have lost N files)".
- **Rename / move**: `rclone moveto "<src>" "<dst>"`. SharePoint supports server-side moves.

After each successful action, append to the audit log:

```markdown
## <action class> — <timestamp>

- Source: `<src>`
- Destination: `<dst>` (rename/move) or `(deleted)`
- Result: ok | failed: <reason>
```

### 4. Update the ticket

Change the ticket's frontmatter status to `applied: <date>`. Record per-item outcomes in the body.

### 5. Report

Print to user:
- N actions applied
- M actions skipped (and why)
- Audit log: `$AUDIT_DIR/audit.md`
- Ticket updated.

## Safety rules

- **Refuse to apply** if `status: approved` is not set.
- **Verify-before-delete**: every delete double-checks the target is empty. If not, skip and log.
- **No batch shortcuts**: each action runs and logs individually so partial failures are recoverable.
- **Never touch `sharepoint:` (operational remote).** Even if a ticket somehow references a `sharepoint:` path, refuse — ADR-0005 says the overseer is read-only on the operational remote.

## What this skill does NOT do

- Does not discover candidates — that's `/sweep-sharepoint-cleanup`.
- Does not roll back an already-applied delete. SharePoint's recycle bin is the only recovery path; the audit log records what to look for.

## Related

- `/sweep-sharepoint-cleanup` — discovery / ticket generation.
- ADR-0004 (research-overseer) — tiered auth gate.
- ADR-0005 — `sharepoint:` is read-only.
