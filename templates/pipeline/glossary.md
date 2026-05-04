# Glossary — <PLACEHOLDER: project name>

<PLACEHOLDER: one or two sentences describing the project's domain and why this glossary exists.>

This is the project's **ubiquitous language**: one canonical term per concept, with synonyms explicitly avoided. Variables, functions, doc text, and ticket titles should use the canonical term and never the avoided ones.

## Format rules

- **Be opinionated.** When multiple words exist for the same concept, pick one and list the others as "Avoid".
- **Flag conflicts explicitly.** If a term is used ambiguously, call it out in "Flagged ambiguities" with a clear resolution.
- **One sentence per definition.** Define what it IS, not what it does.
- **Show relationships.** Use bold term names and express cardinality where obvious.
- **Domain only.** General programming concepts (timeouts, error types, utility patterns) do not belong, even if the project uses them. Ask: "is this a concept unique to this domain, or a general concept?" Only the former qualifies.

## Language

<!-- PLACEHOLDER — example, replace with real domain terms.

**Order**:
A confirmed customer purchase request, regardless of fulfillment state.
_Avoid_: Purchase, transaction.

**Invoice**:
A request for payment sent to a customer after delivery.
_Avoid_: Bill, payment request.

**Customer**:
A person or organization that places orders.
_Avoid_: Client, buyer, account.

-->

## Relationships

<!-- PLACEHOLDER — example.

- An **Order** produces one or more **Invoices**.
- An **Invoice** belongs to exactly one **Customer**.

-->

## Example dialogue

<!-- PLACEHOLDER — a short conversation between a developer and a domain
     expert that demonstrates how the terms interact naturally.

> **Dev:** "When a Customer places an Order, do we create the Invoice immediately?"
> **Domain expert:** "No — an Invoice is only generated once a Fulfillment is confirmed."

-->

## Flagged ambiguities

<!-- PLACEHOLDER — only list terms that have caused confusion or that have
     been deliberately disambiguated. Empty section is fine for new projects.

- "account" was used to mean both **Customer** and **User** — resolved: these are distinct concepts.

-->
