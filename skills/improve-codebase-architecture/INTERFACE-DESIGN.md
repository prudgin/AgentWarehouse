# Interface Design — "Design It Twice"

When the user wants to explore alternative interfaces for a chosen deepening candidate, use this parallel sub-agent pattern. Based on Ousterhout's "Design It Twice" — your first idea is unlikely to be the best.

Uses the vocabulary in [LANGUAGE.md](LANGUAGE.md) — **module**, **interface**, **seam**, **adapter**, **leverage**.

## Process

### 1. Frame the problem space

Before spawning sub-agents, write a user-facing explanation:

- The constraints any new interface would need to satisfy.
- The dependencies it would rely on, and which category they fall into (in-process, local-substitutable, remote-but-owned, true-external).
- A rough illustrative code sketch to ground the constraints — not a proposal, just a way to make constraints concrete.

Show this, then proceed to Step 2 in parallel.

### 2. Spawn sub-agents

Spawn 3+ sub-agents in parallel using the Agent tool. Each must produce a **radically different** interface for the deepened module.

Prompt each with a separate technical brief (file paths, coupling details, dependency category, what sits behind the seam). Include both this language and `glossary.md` vocabulary so each sub-agent names things consistently.

Give each agent a different design constraint:

- **Agent 1**: Minimise the interface — 1–3 entry points max. Maximise leverage per entry point.
- **Agent 2**: Maximise flexibility — support many use cases and extension.
- **Agent 3**: Optimise for the most common caller — make the default case trivial.
- **Agent 4** (if applicable): Design around ports & adapters for cross-seam dependencies.

Each sub-agent outputs:

1. Interface (types, methods, params — plus invariants, ordering, error modes).
2. Usage example showing how callers use it.
3. What the implementation hides behind the seam.
4. Dependency strategy and adapters.
5. Trade-offs — where leverage is high, where it's thin.

### 3. Present and compare

Present designs sequentially so the user can absorb each one, then compare them in prose. Contrast by **depth** (leverage at the interface), **locality** (where change concentrates), and **seam placement**.

After comparing, give your own recommendation: which design you think is strongest and why. If elements from different designs would combine well, propose a hybrid. Be opinionated — the user wants a strong read, not a menu.

## Dependency categories (for adapter design)

Classify dependencies before spawning agents — the category determines testing strategy.

### 1. In-process

Pure computation, in-memory state, no I/O. Always deepenable — merge the modules and test through the new interface directly. No adapter needed.

### 2. Local-substitutable

Dependencies that have local test stand-ins (PGLite for Postgres, in-memory filesystem). Deepenable if the stand-in exists. The deepened module is tested with the stand-in running in the test suite. Seam is internal; no port at the module's external interface.

### 3. Remote but owned (Ports & Adapters)

Your own services across a network boundary. Define a **port** at the seam. The deep module owns the logic; the transport is an injected **adapter**. Tests use an in-memory adapter; production uses HTTP/gRPC/queue.

### 4. True external (Mock)

Third-party services (Stripe, Twilio, etc.). The deepened module takes the dependency as an injected port; tests provide a mock adapter.

## Seam discipline

- **One adapter means a hypothetical seam. Two adapters means a real one.** Don't introduce a port unless at least two adapters are justified (typically production + test). A single-adapter seam is just indirection.
- **Internal seams vs external seams.** A deep module can have internal seams (private to its implementation, used by its own tests) as well as the external seam. Don't expose internal seams through the interface just because tests use them.

(Adapted from Matt Pocock's `INTERFACE-DESIGN.md` and `DEEPENING.md` — see `references/mattpocock-skills/`.)
