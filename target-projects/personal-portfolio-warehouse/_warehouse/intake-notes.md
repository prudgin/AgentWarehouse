# Intake notes (pre-interview)

Source: 2026-05-19 discussion in the warehouse session. Captured before any `/intake-target-project` run, to seed that future session with context so we don't re-litigate already-settled framing.

## Already settled

- **Format**: one fused site (blog + portfolio together), not two separate surfaces.
- **Funnel framing**: site is a public discovery funnel, not a private application attachment. POSSE pattern (publish on own site, syndicate elsewhere).
- **Stack hypothesis**: Astro + MDX + Tailwind → Cloudflare Pages → custom domain. Open to revision during intake but this is the working default.
- **VPS role**: not the host. Reserved for companion services (analytics, newsletter, small API) if/when those are needed.
- **Architecture pattern**: warehouse repo (content + tooling) with an Astro `site/` subfolder that builds the published surface. Mirrors the AgenticEngineering "factory" pattern user already runs.
- **Positioning angle**: AI applied to aquaculture R&D management — under-served intersection, real expertise, plausible top-5-voice path.
- **Content slots**: home / essays / case studies / lab / archive / about+CV / now / subscribe / contact. Mixed-readiness handled via explicit status badges, not hidden sections.
- **Out of scope**: video content, Twitter/X, paywall, premium.

## Decisions deferred to intake interview

(Mirrors `idea.md` section 10. Reproduced here so the intake skill has a checklist.)

1. Domain name + registrar.
2. Whether to also register a short professional alias.
3. Starter theme: fork an Astro portfolio template vs. build layout from scratch.
4. Initial seed: which 3 case studies and which first essay to write before launch.
5. NDA boundaries: which past employers need a permission ask vs. fully sanitisable.
6. Newsletter provider: Buttondown vs beehiiv vs self-hosted listmonk on VPS.
7. Warehouse visibility: public (transparency, dogfooding) vs private (drafts stay private).
8. CV format: PDF only or HTML + PDF.
9. "Now" page: yes/no.
10. Comment system: giscus or none at launch.

## Things to verify at intake time

- Confirm `tool-integration` is the right template (it has the closest shape, but research/library aren't right either — may want a new `personal-site` template if this becomes a recurring pattern).
- Confirm the warehouse-vs-site split is still the user's preferred shape after a night's sleep.
- Confirm "1 site, fused" is still the call (cheap to revisit before scaffolding).

## Pointers

- Target repo idea doc: `~/PersonalPortfolioWarehouse/idea.md` (single source of truth for the vision).
- Discussion that produced this: AgenticEngineering session, 2026-05-19.
