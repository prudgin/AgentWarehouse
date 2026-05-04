---
name: diagnose
description: Disciplined diagnosis loop for hard bugs and performance regressions. Build a fast deterministic feedback loop first, then reproduce, hypothesise, instrument, fix, regression-test. Use when the user says "diagnose this", "debug this", reports a bug, says something is broken/throwing/failing, or describes a performance regression. Auto-mode safe.
---

# Diagnose

A discipline for hard bugs. Skip phases only when explicitly justified.

When exploring the codebase, use `glossary.md` to get a clear mental model of the relevant modules, and check ADRs in the touched area.

## Phase 1 — Build a feedback loop

**This is the skill.** Everything else is mechanical. If you have a fast, deterministic, agent-runnable pass/fail signal for the bug, you will find the cause — bisection, hypothesis-testing, and instrumentation all just consume that signal. If you don't have one, no amount of staring at code will save you.

Spend disproportionate effort here. **Be aggressive. Be creative. Refuse to give up.**

### Ways to construct one — try in roughly this order

1. **Failing test** at whatever seam reaches the bug — unit, integration, e2e.
2. **Curl / HTTP script** against a running dev server.
3. **CLI invocation** with a fixture input, diffing stdout against a known-good snapshot.
4. **Headless browser script** (Playwright / Puppeteer).
5. **Replay a captured trace** — save a real network request, payload, or event log; replay through the code path in isolation.
6. **Throwaway harness** — minimal subset of the system (one service, mocked deps) that exercises the bug code path with one function call.
7. **Property / fuzz loop** — for "sometimes wrong output", run 1000 random inputs and look for failure modes.
8. **Bisection harness** — for bugs that appeared between two known states (commit, dataset, version), automate "boot at state X, check, repeat" so `git bisect run` can drive it.
9. **Differential loop** — same input through old-version vs new-version; diff outputs.
10. **HITL bash script** — last resort. If a human must click, drive them with a structured script so the loop is still bounded.

### Iterate on the loop itself

Treat the loop as a product. Once you have one, ask:

- Can I make it faster? (Cache setup, skip unrelated init, narrow the test scope.)
- Can I make the signal sharper? (Assert on the specific symptom, not "didn't crash".)
- Can I make it more deterministic? (Pin time, seed RNG, isolate filesystem, freeze network.)

A 30-second flaky loop is barely better than no loop. A 2-second deterministic loop is a debugging superpower.

### Non-deterministic bugs

The goal is not a clean repro but a **higher reproduction rate**. Loop the trigger 100×, parallelise, add stress, narrow timing windows, inject sleeps. A 50%-flake bug is debuggable; 1% is not — keep raising the rate until it's debuggable.

### When you genuinely cannot build a loop

Stop and say so explicitly. List what you tried. Ask the user for: (a) access to whatever environment reproduces it, (b) a captured artifact (HAR, log dump, core dump, screen recording), or (c) permission to add temporary instrumentation. **Do not proceed to hypothesise without a loop.**

Do not proceed to Phase 2 until you have a loop you believe in.

## Phase 2 — Reproduce

Run the loop. Watch the bug appear.

Confirm:

- [ ] The loop produces the failure mode the **user** described — not a different failure that happens to be nearby. Wrong bug = wrong fix.
- [ ] The failure is reproducible across multiple runs (or, for non-deterministic bugs, at a debuggable rate).
- [ ] You have captured the exact symptom (error message, wrong output, slow timing).

Do not proceed until reproduced.

## Phase 3 — Hypothesise

Generate **3–5 ranked hypotheses** before testing any. Single-hypothesis generation anchors on the first plausible idea.

Each hypothesis must be **falsifiable**: state the prediction.

> Format: "If <X> is the cause, then <changing Y> will make the bug disappear / <changing Z> will make it worse."

If you cannot state the prediction, the hypothesis is a vibe — discard or sharpen it.

**Show the ranked list to the user before testing.** They often have domain knowledge that re-ranks instantly. Cheap checkpoint, big time saver. Don't block on it — proceed with your ranking if the user is AFK.

## Phase 4 — Instrument

Each probe maps to a specific prediction from Phase 3. **Change one variable at a time.**

Tool preference:

1. **Debugger / REPL inspection** if the env supports it.
2. **Targeted logs** at boundaries that distinguish hypotheses.
3. Never "log everything and grep".

**Tag every debug log** with a unique prefix, e.g. `[DEBUG-a4f2]`. Cleanup at the end is a single grep. Untagged logs survive; tagged logs die.

**Perf branch.** For performance regressions, logs are usually wrong. Establish a baseline measurement (timing harness, profiler, query plan), then bisect. Measure first, fix second.

## Phase 5 — Fix + regression test

Write the regression test **before the fix** — but only if there is a **correct seam** for it.

A correct seam is one where the test exercises the **real bug pattern** as it occurs at the call site. If the only available seam is too shallow (single-caller test when the bug needs multiple callers, unit test that can't replicate the chain), a regression test there gives false confidence.

**If no correct seam exists, that itself is the finding.** Note it. The codebase architecture is preventing the bug from being locked down. Flag for `/improve-codebase-architecture`.

If a correct seam exists:

1. Turn the minimised repro into a failing test at that seam.
2. Watch it fail.
3. Apply the fix.
4. Watch it pass.
5. Re-run the Phase 1 feedback loop against the original (un-minimised) scenario.

## Phase 6 — Cleanup + post-mortem

Required before declaring done:

- [ ] Original repro no longer reproduces.
- [ ] Regression test passes (or absence of seam is documented).
- [ ] All `[DEBUG-...]` instrumentation removed (`grep` the prefix).
- [ ] Throwaway prototypes deleted (or moved to a clearly-marked debug location).
- [ ] The hypothesis that turned out correct is stated in the commit / PR message.

**Then ask: what would have prevented this bug?** If the answer involves architectural change (no good test seam, tangled callers, hidden coupling), hand off to `/improve-codebase-architecture` with the specifics. Make the recommendation **after** the fix is in.

## What this skill does NOT do

- Does not skip Phase 1. The loop is the skill.
- Does not propose architectural rewrites — that's `/improve-codebase-architecture`.
- Does not replace project-specific debugging conventions; if the project has documented debugging patterns in `docs/reference/`, follow them in addition to this discipline.

(Adapted from Matt Pocock's `/diagnose` skill — see `references/mattpocock-skills/skills/engineering/diagnose/`.)
