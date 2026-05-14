# Reference

How the code works. **Optional in this template.** Many research projects have one or two scripts and no module hierarchy worth a reference doc. If that's you, this directory may stay empty or be deleted entirely.

Reinstate / populate when:

- The project grows first-party utility code (a CLI, a small package, a reusable model class) that future agents will need to navigate.
- A single script grows past ~500 lines and would benefit from a cheat-sheet of "what's where".
- You add modular components that expose a stable interface for re-use across investigations.

If none of those apply, declarative knowledge belongs in `docs/domain/` (mechanics, methodology) and procedural knowledge belongs in `.claude/skills/`.

## Rules (when used)

- Update **after** implementing or significantly changing a module.
- Link to `glossary.md` and `docs/domain/` for context — never duplicate domain knowledge here.
- Link to `docs/adr/` for decisions that shaped the design — never restate the rationale here.
- Describe behaviour, interfaces, and invariants. Don't paste code; link to it.
- One file per module or coherent subsystem. Group small siblings under a single doc rather than fragmenting.

## Index

<!-- PLACEHOLDER — list each reference doc with a one-line summary. The
     /finish skill checks that every file in this directory is listed here.
     If the directory is empty, leave this section empty.

- [<module>.md](<module>.md) — what the module does, its public interface, its invariants.

-->
