# Reports

Human-facing deliverables: interim reports, final reports, presentations. DOCX, PPTX, PDF.

Files are dated in the filename (e.g. `gut_clearance_report_16_04_2026.pdf`). Supersession is by filename, not by overwriting.

When `/finish-analysis` produces a finding worth surfacing as a report, it can be copied here and reformatted for the audience (the canonical writeup stays in `analysis/<dated>/INVESTIGATION.md`).

This directory is **synced to SharePoint** at `sharepoint_planning:PROJECTS/<Project Name>/Reports/`.

## Report backbone

[`report-backbone.md`](report-backbone.md) is the **single assembly surface for the final report**, grown incrementally from project start rather than reconstructed at the end (see "Report backbone" in `../CLAUDE.md`). The scatter of attempts stays in `analysis/`; only keepers are promoted here, via `/finish-analysis` ("aha → backbone"). It holds four things:

- **Story beats** — the narrative order the report will follow. Doubles as the story-spine: when a presentation is built, the deck follows the backbone (keyed to the figure ids below), not the reverse. A deck is an opaque artefact outside the doc graph; the backbone is the machine-readable source of "what matters".
- **Global figure register** — one row per report-candidate figure:

  | R | Message | Current file | Source script | Investigation | report: |
  |---|---------|--------------|---------------|---------------|---------|
  | R-01 | … | `pipeline/output/figures/…png` | `pipeline/figures/…py` | `analysis/<dated>/` | yes / caveated / dropped |

  Stable `R-xx` ids (never renumbered). A figure leaving the report is a `report: dropped` status change **with a reason**, recorded in a "Dropped" table — never a silent deletion, so the absence is intentional, not an oversight.
- **Headline-numbers inventory** — every number the report will state, each traced to one computed source (`pipeline/output/numbers.json`); no number hand-typed twice. Prose claims get pinned to a computed number before they ship.
- **Methods / Caveats / Gaps** — grown as investigations surface them.

Promotion happens in `/finish-analysis`: a register row + numbers entry + a one-command `pipeline/` regenerator (with a blessed `pipeline/golden/` copy). `/finish` runs a backbone-integrity sweep — every `report: yes` figure resolves and has a regenerator; every figure shipped in a `Reports/` deliverable is registered.
