---
name: grill
description: Interactive alignment interview before building or changing anything. Walks the design tree one question at a time, recommending an answer for each. Updates glossary.md inline as terms resolve, and offers an ADR when a decision passes the 3-of-3 admission test (hard to reverse, surprising without context, real trade-off). Use when the user wants to align on a feature/change/design before coding, says "grill me", says "let's design X", or starts a new piece of work. Interactive — refuses auto mode.
---

# Grill

Aggressive alignment session. The goal is **shared understanding** between you and the user before any code is written. Walk the design tree one branch at a time, resolving each question before moving to the next. Most misalignment comes from the developer thinking they understood and being wrong; this skill exists to catch that early.

## Refuse auto mode

If the system context indicates auto mode is active (look for "Auto mode is active" or equivalent in system reminders), stop immediately and respond:

> This skill is interactive — it asks one question at a time and waits for your answer. Please switch to interactive mode and re-invoke `/grill`.

Do nothing else. Do not proceed to ask questions, explore the codebase, or take any other action.

## Process

### 1. Anchor the session

Ask the user, in plain words: **"What are we designing or changing?"** Get a one-paragraph statement. Echo it back so you and the user agree on scope before any deeper questioning.

If `/grill` was invoked with an argument (a topic, a ticket reference, a sentence-long description), use that as the anchor and confirm it: "I read this as ___ — is that right?"

### 2. Explore the codebase (lightly)

Before grilling, look at:

- `CLAUDE.md` at the project root — entry point, doc map, conventions.
- `glossary.md` at the project root — the project's ubiquitous language. Required reading before challenging the user on terms.
- `docs/adr/` — past architectural decisions to respect (and not relitigate).
- The area of code the change touches — enough to ground questions, not exhaustive.

**If a question can be answered by reading the code, read the code instead of asking.** Don't waste the user's attention on things you can find yourself.

### 3. Walk the design tree

Ask **one question at a time**. For each question:

- Be specific. Not "how should this work?" but "should this fail loud or fail silent when X is missing, given that the rest of the pipeline assumes loud failures?"
- Provide a **recommended answer** with a one-line reason, so the user can react instead of staring at a blank prompt.
- Wait for the user's response before continuing.

Resolve dependencies before moving on: if question B depends on the answer to A, ask A first.

Branches you'll typically walk (not a checklist — branch as the conversation requires):

- What problem is this solving, from the user's perspective?
- What's in scope, what's out of scope?
- What's the smallest thing that demonstrates value end-to-end?
- What modules and interfaces will be touched? Are there opportunities to extract a **deep module** (small interface, lots of behaviour hidden behind it)?
- What can break, and how should the system behave when it does?
- What's the feedback loop? (Tests, type checks, runtime invariants — what tells the agent it got it right?)
- What does "done" look like — concretely, in observable terms?

Stop walking when the user signals alignment ("good", "we're aligned", "that's enough"). Don't drag a session past genuine resolution.

### 4. Inline glossary updates

During the conversation:

- **Challenge against the glossary.** If the user uses a term that conflicts with an existing entry, call it out. "Your glossary defines X as ___, but you seem to mean ___ — which is it?"
- **Sharpen fuzzy language.** When the user uses a vague or overloaded term, propose a precise canonical term. "You said 'account' — do you mean Customer or User?"
- **Cross-reference with code.** When the user states how something currently works, verify against the code. Surface contradictions immediately.
- **Update `glossary.md` right there.** When a new term resolves or an existing one sharpens, edit the file inline. Follow the format already in the file. Don't batch updates to the end — capture them in the moment, while the language is fresh.

If `glossary.md` doesn't exist yet, don't create it pre-emptively. Offer to create it the first time a term genuinely resolves: "Want me to start a `glossary.md` with this entry?"

### 5. Inline ADR offers

When a decision crystallises during the session, apply the **3-of-3 admission test** (defined in the project's `docs/adr/README.md`):

1. **Hard to reverse?** Cost of changing your mind later is meaningful.
2. **Surprising without context?** A future reader will wonder "why on earth did they do it this way?"
3. **Result of a real trade-off?** Genuine alternatives existed; picked one for specific reasons.

If **all three** are true, offer an ADR: "This feels like an ADR — hard to reverse, would surprise a future reader, you picked over a clear alternative. Want me to draft one?"

If any one is missing, skip. Most decisions don't qualify, and that's correct — ADRs are sparse on purpose.

If `docs/adr/` doesn't exist yet, offer to create it on the first qualifying decision.

### 6. Use concrete scenarios

When the discussion gets abstract, **stress-test with specific scenarios**. Invent edge cases that force the user to be precise. "What happens if the user has two accounts and switches between them mid-session?" "What if the upstream API returns an empty array — error or empty result?"

Concrete scenarios catch ambiguities that abstract discussion misses every time.

### 7. Wrap up

When the user signals alignment, summarise in this shape:

- **Shared understanding** — 3 to 5 bullet points capturing what was resolved.
- **Glossary updates landed** — term names (linking the section in `glossary.md` if useful).
- **ADRs drafted** — link to each (or note "none qualified").
- **Open ends** — anything explicitly left unresolved (with one-line reason).

Then suggest the next step in the **build chain**:

> Next: `/to-prd` to synthesise a PRD from this session's context. (Or skip the chain and code if the change is small enough.)

## What this skill does NOT do

- It does not write a PRD. That's `/to-prd`.
- It does not break work into tickets. That's `/to-issues`.
- It does not write or modify code.
- It does not modify docs other than `glossary.md` (inline) and confirmed ADR drafts.
- It does not bundle multiple questions into one turn — one question, then wait.
- It does not summarise its own questions before asking. It just asks.

## Notes for the agent

- This is an **alignment** session, not a planning session. The output is shared understanding, not a plan.
- Push back when the user is fuzzy. Recommended answers are part of pushing back — they expose your interpretation so the user can correct it.
- If the user's answers contradict each other, surface it. "Earlier you said X, but now Y — which holds?"
- If a question seems redundant given the codebase, skip it (you already explored).
- Do not ask "is there anything else?" at the end — the user will tell you.
