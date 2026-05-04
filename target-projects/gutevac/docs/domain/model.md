# Model

How the gut-clearance analysis interprets the data. Formal spec lives in [`docs/reference/model-spec.md`](../reference/model-spec.md); this doc is the *why* and the *what it means*.

For per-term definitions see [`glossary.md`](../../glossary.md). For methodological decisions and their alternatives see [ADR-0002](../adr/0002-two-meal-hump-binomial-likelihood.md) and [ADR-0003](../adr/0003-harvest-threshold-convention.md).

---

## What the data looks like

At each sampling timepoint, 15 fish per pond are lethally sampled and each fish is opened and scored: feed present in stomach (yes/no), feed present in intestine (yes/no). The result for each timepoint is the **fraction of 15 fish still carrying feed**. The time axis is degree-hours since the last feed.

The intestine fraction does **not** simply decline from 100 %. It rises first, peaks at roughly 200–400 DH, then declines. This hump shape is the central observation that drove the model choice.

## Why a hump

Two things are happening at the same time after the last feed:

1. **Today's meal** is moving through the gut. Some fraction of fish ate today (the eating fraction *c*; see glossary). For those fish, today's meal arrives in the intestine over the first few hundred DH and clears over the next thousand or so.
2. **Yesterday's meal** has not finished clearing. At t=0 (just after the last feed) yesterday's residual is still present; it clears with the same kinetics as today's meal but is offset by one feeding cycle.

A monotone-decline model can't reproduce the hump because there's nothing rising inside it. The hump model has a rising arrival sigmoid (`σ_arr`) and a falling clearance sigmoid (`σ_clr`); their **difference** is the per-meal intestinal occupancy — zero before arrival, peaks when arrival is nearly complete but clearance hasn't started, then decays toward zero.

## Two-meal combination

Today's and yesterday's contributions are combined under independence on the same fish:

    P_obs(d_t) = 1 − (1 − f(d_t)) · (1 − f(d_t + d_y))

where `f` is the per-meal hump (scaled by *c*), `d_t` is the row's DH since today's last feed, and `d_y` stands in for yesterday's-meal age. We use `d_y = T_pond_mean × 24` (the 24 wall-clock hours between feeds, integrated at the pond's mean temperature) — a coarse approximation, but the analysis is not sensitive to its exact value because the yesterday-meal contribution is on the steep declining tail of the hump for most rows.

This combination applies uniformly to *every* row — including t=0 rows, which still have a small non-zero `d_t` (0–14 DH) because sampling occurs slightly after the nominal feed cutoff. Do not special-case t=0.

The same kind of combination applies to stomach feed, with a simpler per-meal form `g(DH) = c · (1 − σ_emp(DH))` (no rising sigmoid because feed is in the stomach immediately after eating).

## Eating fraction *c*

Only about 70–87 % of fish were observed to eat on the trial day, varying by pond (mean ≈ 81 %). Fish that didn't eat contribute zero to today's-meal signal but still contribute yesterday's-meal residual. The model handles this by multiplying each meal's contribution by *c*. *c* is computed per pond from `% Today feed in stomach` at t=0, **not** fitted (see `model-spec.md` and glossary → eating fraction).

The current implementation assumes `c_yest = c_today` (eating habits are constant day-to-day per pond). This is an approximation; if eating compliance varies systematically across days the model will absorb that variation into the shape parameters.

## Pooled fit across ponds

The four shape parameters (`m_arr`, `w_arr`, `m_clr`, `w_clr`) are **shared across all ponds**, fitted once. The only things that differ between ponds are:
- pond-mean temperature, which sets `d_y`;
- per-pond `c`.

Pooling buys statistical power on a small dataset (4 ponds, 26 timepoints). The cost is that pond-to-pond differences in clearance kinetics are not reportable from this fit — they would require a hierarchical / random-effects extension, which is deferred until enough ponds are in scope to support it (see [`docs/planning/future-work.md`](../planning/future-work.md)).

## Stomach emptying as a separate fit

Stomach emptying is fitted independently of intestine clearance. It uses a single sigmoid (`σ_emp` declining), not a hump, because there's no arrival phase — feed is in the stomach immediately after eating. The two fits are **not** jointly estimated; one parameter pair (`m_emp`, `w_emp`) is pinned in step 1, then the four intestine parameters are fitted in step 2 with `c` already fixed. The independence between fits is operationally simpler and makes neither fit dependent on the other's pathologies.

## What the model tells you, and what it doesn't

The intestine fit produces the **harvest fasting period** (DH at 5 %, see glossary and [ADR-0003](../adr/0003-harvest-threshold-convention.md)) — the headline operational number. It also produces:

- A peak height of `σ_arr − σ_clr` (the maximum fraction of *eating* fish carrying today's meal in the intestine — should be near 1.0 if the model is well-specified).
- A series of clearance thresholds (50, 25, 10, 5, 1 %) on the decline side, each convertible to clock-hours at any reference temperature.
- Derived intervals: `m_clr − m_arr` (intestinal transit), `m_emp − m_arr` (stomach-dripping duration), `m_clr − m_emp` (intestine-only retention).

The stomach fit produces `m_emp` — the DH at which half of fish have empty stomachs. This sets a **physical lower bound** on inter-meal interval (feeding before the stomach empties means meals mix), but it is **not** the harvest criterion (intestine is) and it does not predict appetite recovery (a separate behavioural question).

Things the model does **not** account for:
- Waste entering cages from the inlet pipe side, or fish eating bugs/detritus. These can produce non-zero gut content even after prolonged fasting; they are out of scope.
- Fish weight as a covariate. The 4 trial ponds ranged 1.1–3.0 kg mean weight; with 4 ponds there is no power to test size effects.
- Pond-specific clearance kinetics (see "Pooled fit" above).

## Failure modes of the fit

The model has two known identifiability problems, fully documented in [`known-issues.md`](known-issues.md):

1. **Arrival sigmoid is poorly identified.** The optimiser tends to push `w_arr` to its lower bound. `m_arr` reads as artificially tight on a boundary corner, not as a biological number. Do not report arrival-side parameters as biology.
2. **Eating fraction *c* is probably underestimated.** Fish that ate today but cleared their stomach quickly look like non-eaters at t=0 sampling. This biases *c* low and contributes to the model under-predicting the early intestine peak.

Neither issue compromises the headline DH-at-5 % materially (it is dominated by the decline-side parameters `m_clr`, `w_clr`), but both should be flagged in any report.

## Provenance

- [`docs/reference/model-spec.md`](../reference/model-spec.md) — formal spec the code implements.
- `gut_clearance_report.docx` (operative interim report, April 2026) — the prose framing of the model used in this doc.
- `analysis/2026-04-16-warm-band-fit/REPORT.md` (planned, retrofit) — the run that produced the current numbers.
- [ADR-0002](../adr/0002-two-meal-hump-binomial-likelihood.md), [ADR-0003](../adr/0003-harvest-threshold-convention.md).
