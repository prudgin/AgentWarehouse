# Future work — 2023 Feeding Frequency

Pre-decision items: things worth doing if a future session has the budget. Each entry should have enough context that an agent can pick it up cold.

When an item is decided to be done, transition it to a `.tickets/` issue and remove it from this file.

## Methodology extensions

### Threshold sensitivity on the books-noisy filter

The 9% threshold in [ADR-0002](../adr/0002-books-clean-filter-at-nine-percent.md) is a deliberate round number. A short investigation could rerun all four analyses (SGR, SFR, Cross, Pretrial) at thresholds `[5, 7, 9, 11, 13] %` and tabulate how the trial-pooled headline numbers shift. If conclusions are stable across the range, that's a stronger story than "9% is what we chose"; if they shift materially, the threshold choice becomes load-bearing and deserves a separate ADR.

### Per-cage uncertainty bands on the cross plot

The cross plot in `analyses/cross/` currently renders point estimates. A bootstrap CI on each `(pond, group)` point — resampling cages within group with replacement and recomputing biomass-weighted aggregates — would communicate that the T2 treatment point's "below model on both axes" reading is robust against per-cage noise.

### Compare the workbook vs MDF feed sources beyond ~1.6% headline

[ADR-0004](../adr/0004-hybrid-feed-source-workbook-and-mdf.md) cites overall agreement of ~1.6%. A focused audit could identify the day-by-day disagreements, classify them (operator-corrected typos vs. MDF-side adjustments vs. timezone artefacts), and decide whether the hybrid stitch can be replaced by a single source.

## Code/structural

### Add `pyproject.toml` and `pip install -e .`

Post-migration, the `src/feeding_frequency_2023/` package will use `sys.path` inserts to import `growth_models` and MDF internals (the existing pattern preserved through migration). A separate ticket can introduce a proper `pyproject.toml`, install the package editable into the MDF venv, and replace the runtime `sys.path` inserts with regular imports. Low priority — current pattern works; cleaner long term.

### Pre-trial extended-window plot for T1 post-trial

The extended SFR-ratio plot's T1 post-trial extent currently runs to the earliest cycle end among its books-clean cages (P1C8, 2023-11-09). Other T1 cycles continue further; rendering a per-pond view (instead of per-trial pool) would expose more post-trial dynamics. Worth doing if the post-trial behaviour is interesting enough to write up.

## Cross-project

### Share the books-clean filter approach with the RAS sibling

When the `FrequencyRAS` (sibling project) migration happens, the books-clean filter is a strong candidate for shared methodology. The threshold and the exact metric (`adj_daily_pct × trial_days`) may need a sibling-specific recalibration; the filter shape itself can be reused. **Do not** factor into a shared library prematurely — duplicate first, then extract if the third reuse appears.
