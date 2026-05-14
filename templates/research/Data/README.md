# Data

Raw and processed data files. Date-range subdirs are the convention for time-series experiments:

```
Data/
├── 13-02-2026 to 26-02-2026/    # one experimental window
├── 27-02-2026 to 12-03-2026/
├── Data compiled.xlsx           # cross-window aggregates at the root
├── Scoring template.xlsx
└── sensor temp data/            # ongoing instrument output
```

Date-range format: `DD-MM-YYYY to DD-MM-YYYY` (matches existing SharePoint convention). Single-event subdirs use `DD-MM-YYYY/`.

This directory is **synced to SharePoint** at `sharepoint_planning:PROJECTS/<Project Name>/Data/`. Watch the volume — large data goes here whether you push it or not, but SharePoint quota is finite.
