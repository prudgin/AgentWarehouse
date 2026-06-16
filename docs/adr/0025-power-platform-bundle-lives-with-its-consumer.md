# The Power Platform bundle lives with its consumer, not in the warehouse

The warehouse hosted a Power Platform bundle — 10 skills (`power-platform-auth`, `pac-cli-linux`, `flows-*`, `apps-*`, `proxy-flow-scaffolding`, `anthropic-api-integration`) plus 3 reference docs (`powerapps-gotchas.md`, `azure-cli-sharepoint-auth.md`, `pac-canvas-deprecation.md`) — as canonical sources symlinked into the one `tool-integration`-targeting-Power-Platform project, `~/MicrosoftFlowsApps`. The original rationale (recorded in `docs/domain/existing-projects.md` and the gotchas doc's own footer) was the warehouse's standard model: keep the skills canonical in the factory so *future* Power Platform projects reuse them without rediscovery.

There is exactly **one** Power Platform project and none in prospect. (`PowerBI`, the only other candidate `tool-integration` project, is a different stack sharing none of these skills.) With a single consumer the canonical-source-plus-symlink model is all cost and no benefit: propagation pays off only across multiple consumers, while the real cost — cross-repo drift, since the project runs ahead during live use and forces a "harvest drift back into the warehouse" step on every migration/finish — is paid in full. Project-specific canvas war-stories had also leaked *up* into the warehouse gotchas doc "so future projects benefit", future projects that do not exist. `apps-browser-verify` and the most project-specific gotchas had already been pulled back into the project ahead of this decision.

**Decision:** the entire Power Platform bundle (all skills + reference docs) is relocated out of the warehouse and into `~/MicrosoftFlowsApps` as first-party content (real directories under `.claude/skills/`, real files under `docs/reference/`). The warehouse retains only the generic `tool-integration` template skeleton — which never referenced these skills by name. A future Power Platform project, should one ever appear, seeds its bundle **from `MicrosoftFlowsApps`**, not the warehouse. The project records the receiving end in its own `docs/adr/0005-power-platform-bundle-is-first-party.md`.

This narrows the warehouse's remit: it standardises the *generic* cross-project setup (templates + the build/analyse/cross-cutting skills + lifecycle skills), and does **not** carry integration bundles that have a single consumer. Genuinely reusable skills (used by 2+ projects, or expected to be) still belong here; single-consumer bundles live with the consumer.

## Considered options

- **Keep everything in the warehouse (status quo).** Rejected: perpetuates the drift tax and treats speculative reuse as real demand.
- **Split — keep the generic platform skills/docs in the warehouse, repatriate only the project-specific war-stories.** A coherent middle (and the author's initial lean), but it preserves the symlink indirection and its drift surface for a bundle with one consumer. Rejected once the user confirmed there is no second Power Platform project in prospect.
- **Relocate the whole bundle to the consumer (chosen).** Ends the indirection entirely; accepts that a hypothetical second project seeds from the first repo rather than a maintained factory bundle.

## Consequences

**Positive:**
- One canonical home per fact, in the repo that uses it. No more warehouse↔project drift for Power Platform knowledge; no harvest-back step in `/migrate-project` or `/finish`.
- The warehouse stops carrying project-specific canvas knowledge it has no other consumer for, and its skill inventory now reflects only genuinely cross-project skills.

**Negative:**
- The warehouse no longer advertises a ready-made Power Platform skill set. A future second Power Platform project must copy from `MicrosoftFlowsApps` and re-generalise rather than symlinking a maintained factory bundle.
- A reader who remembers the bundle being here needs the trail (this ADR + the relocation notes in `skills/README.md`, `docs/reference/README.md`, `docs/reference/skills.md`) to find where it went.

**Reversible?** Medium. Re-promoting to the warehouse is a copy-back plus re-symlink and a re-generalisation pass — an afternoon's work, but it means re-extracting the generic core from project-specific detail that will have accreted in the project by then.

## Links

- Receiving-end ADR: `~/MicrosoftFlowsApps/docs/adr/0005-power-platform-bundle-is-first-party.md`.
- Project state: [`docs/domain/existing-projects.md`](../domain/existing-projects.md) → `~/MicrosoftFlowsApps`.
