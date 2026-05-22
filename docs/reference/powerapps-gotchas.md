# Power Apps gotchas

Behaviors that derailed real work in canvas apps. Each entry: what fires, why, how to apply.

## `Concurrent`: refuses multi-branch writes to the same data source

`Concurrent(formula1, formula2, ...)` does a **static analysis** of its arguments. If two branches both write to the same data source — even when the actual rows touched are disjoint — Studio surfaces:

> There is a dependency on '<source>' between two different formulas in the Concurrent function. One formula is changing it while another formula may be reading or also trying to change it.

This is a coarse type-level check, not a row-level conflict check. The runtime can't prove row disjointness, so it refuses.

**How to apply:** group `Concurrent` arguments by data source. Multiple writes to one list → single branch (sequential). Different lists → different branches.

```
// Refused — both branches touch WQ_Flags:
Concurrent(
  Patch(WQ_Flags, ...),
  Remove(WQ_Flags, ...)
)

// OK — sequential within source, parallel across sources:
Concurrent(
  // branch A: all WQ_Flags writes in order
  (Patch(WQ_Flags, ...); Remove(WQ_Flags, ...)),
  // branch B: WQ_Readings writes
  Patch(WQ_Readings, ...)
)
```

## `Select(otherBtn)`: fire-and-forget, not synchronous

`Select(btnCommitSave)` from inside another button's `OnSelect` does **not** block. The caller's formula continues immediately; the target button's `OnSelect` runs concurrently.

So a "Save anyway" confirmation popup that does:

```
Select(btnCommitSave);
Set(varShowFlagSummary, false)
```

will close the popup before the save actually completes.

**How to apply:** any race-protection has to be a guard variable set **inside the target button's** `OnSelect`, not the calling button:

```
// In btnCommitSave.OnSelect:
If(varSaving, false, ...);   // bail if already saving
Set(varSaving, true);
IfError(
  Patch(...),
  Notify("...", Error)
);
Set(varSaving, false);

// btnCommitSave.DisplayMode:
If(varSaving, DisplayMode.Disabled, DisplayMode.Edit)
```

## `pac canvas pack` PA2001 "Checksum mismatch" — benign

After editing any `src/Src/*.fx.yaml` and running `pac canvas pack` (the inner step of `apps-update`), you'll always see:

```
Warning PA2001: Checksum mismatch. Checksum indicates that sources have been edited since they were unpacked. If this was intentional, ignore this warning.
```

**Not a failure signal.** The checksum is a tripwire for "did anything change?" — and we want changes, so it fires every time. The push still succeeds.

Real failure signals are: non-zero exit from `_tools/update-app.sh`, or `pac solution import` reporting a dangling reference (which surfaces above the PA2001 line).

## `pac canvas pack` PA3003 "Property should be at same indent level" — fatal

Truly-empty `\n` lines inside a YAML block-scalar property (anything with `: |` or `: |-`, e.g. `OnSelect: |`) break the pack:

```
Error: Error   PA3003: Parse error: Property should be at same indent level
```

**Why:** Power Fx parser inside `pac canvas` treats the indent of every non-empty line as the column for `Property:` tokens; a zero-indent blank line confuses block-scope inference even though plain YAML tolerates it.

**How to apply:** after any edit that introduces or could introduce a bare `\n` in `.fx.yaml` (Write/Edit tool, `sed`, manual paste), normalize blank lines inside affected block scalars to the indent level the rest of the block uses. For `apps/*/src/Src/*.fx.yaml`, `pac canvas unpack` outputs 12 spaces of left-padding on otherwise-empty separator lines within `OnSelect` bodies — match that.

Quick fix script:

```python
# pad-blanks-12.py <path/to/file.fx.yaml>
import sys, re
p = sys.argv[1]
text = open(p).read()
# Inside OnSelect: | blocks, replace bare \n with 12 spaces + \n
def fix(m):
    body = m.group(0)
    return re.sub(r'^(\s*)$', ' ' * 12, body, flags=re.MULTILINE)
# (Apply only to OnSelect-style bodies; specifics depend on file shape.)
```

In practice, the offending bare-`\n` is usually obvious in diff — just edit it back to 12 spaces.

---

## Source

Gotchas surfaced while working on `apps/WQ_WaterQuality_sp/` in MicrosoftFlowsApps. Extracted to the warehouse 2026-05-22 so future tool-integration projects benefit without rediscovering.
