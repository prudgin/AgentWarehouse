# Migration plan — water-quality-feed

Executable handoff for `/create-project water-quality-feed`. Cold-start; no source repo.

## Mode

cold-start

## Target

- Repo path: `~/PycharmProjects/WaterQualityFeed/`
- Git remote: `https://github.com/prudgin/WaterQualityFeed.git`
- Main branch: `master`
- Template: `pipeline`

## Step list

### 1. Scaffold from `templates/pipeline/`

Copy `templates/pipeline/` contents into `~/PycharmProjects/WaterQualityFeed/`. The template provides:
- `CLAUDE.md` skeleton (will be overwritten by the staged version — see step 4)
- `README.md` stub
- `glossary.md` stub (will be overwritten — see step 4)
- `docs/reference/`, `docs/adr/`, `docs/domain/`, `docs/planning/` skeletons
- `analysis/` skeleton with `analysis-landscape.md`
- `.tickets/inbox/` directory
- `.claude/skills/` directory (skill symlinks added in step 3)

### 2. Initialise git

```
cd ~/PycharmProjects/WaterQualityFeed
git init -b master
git remote add origin https://github.com/prudgin/WaterQualityFeed.git
```

Do NOT push until step 7 (initial commit only).

### 3. Install warehouse skills

Symlink each into `.claude/skills/<name>`:

- `grill`, `to-prd`, `to-issues`, `triage`, `work-issue`, `finish`
- `start-analysis`, `finish-analysis`
- `diagnose`, `improve-codebase-architecture`
- `file-cross-repo-ticket`, `check-inbox`

Do **not** install: research-template skills (`sharepoint-sync`), warehouse-only project lifecycle skills (`intake-target-project`, `create-project`, `migrate-project`).

### 4. Transfer staged content from `target-projects/water-quality-feed/`

Copy (overwriting the template stubs):

- `CLAUDE.md` → `<repo>/CLAUDE.md`
- `glossary.md` → `<repo>/glossary.md`
- `docs/adr/0001-standalone-pipeline-not-mdf-stage.md`
- `docs/adr/0002-share-mdf-venv-despite-standalone.md`
- `docs/adr/0003-v1-wq-native-identifiers-no-canonical-mapping.md`
- `docs/domain/sources.md`
- `docs/domain/unit-mapping-puzzle.md`
- `docs/planning/future-work.md`

Create `<repo>/AGENTS.md` as a symlink to `CLAUDE.md`.

### 5. Author code skeleton

Per the pipeline-areas table in `CLAUDE.md`:

- `run_pipeline.py` — top-level orchestrator (`--stage ingestion|clean|publish` flag). Mirrors MDF's CLI shape.
- `config.py` — paths (publish root via `WQ_DATA_ROOT`), Flow URL env var (`WQ_PROXY_FLOW_URL`), Sydney TZ constant, list registry (the six SP lists to mirror).
- `ingestion/` — `wq_proxy_client.py` (POSTs the SAS URL with the trigger body), pagination handling (the SP connector caps at 5000 items; iterate via `$skiptoken` or `$top`/`$orderby`+`ID gt last`), one fetcher per list.
- `processing/clean/` — `01_normalise_datetime_and_units.py` (Sydney TZ, parse parameter values to numeric, rename WQ identifier columns to `WQ*` prefix), `02_validate_types.py`.
- `processing/publish.py` — `<published>/.staging/` write, README schema dump, atomic rename to `<published>/`.
- `pyproject.toml` — bare-name deps: `requests`, `pandas`, `pyarrow`. No pins. Project name `water-quality-feed`, package `water_quality_feed`.
- `.env.example` — `WQ_PROXY_FLOW_URL=`, `WQ_DATA_ROOT=/mnt/data/water_quality` (optional override).
- `.gitignore` — `.venv/` (paranoia — it shouldn't exist), `data/`, `.env`, `.idea/`, `__pycache__/`.

### 6. Install into MDF's shared venv

```
/home/rndmanager/PycharmProjects/MercatusDataFeed/.venv/bin/pip install -e ~/PycharmProjects/WaterQualityFeed
```

Verify: `python -c "import water_quality_feed"` works from MDF's venv.

### 7. systemd deploy/

Create `deploy/wq-pipeline.service` and `deploy/wq-pipeline.timer` modelled on MDF's:

- Timer: `OnCalendar=*-*-* 03:00:00 Australia/Sydney`, `RandomizedDelaySec=300`, `Persistent=true`.
- Service: `Type=oneshot`, `User=rndmanager`, `WorkingDirectory=/home/rndmanager/PycharmProjects/WaterQualityFeed`, `ExecStart=/home/rndmanager/PycharmProjects/MercatusDataFeed/.venv/bin/python run_pipeline.py`, `EnvironmentFile=/home/rndmanager/PycharmProjects/WaterQualityFeed/.env`, `TimeoutStartSec=1800` (the proxy + six list fetches should be well under 5 min), `Restart=no`, `MemoryMax=1G`, `CPUQuota=50%`.
- No `ExecStartPre`-style git refresh — WQ has no volatile dep.

Installation steps documented in `docs/reference/orchestration.md`.

### 8. First commit + push

```
git add -A
git commit -m "scaffold WaterQualityFeed pipeline from warehouse template"
git push -u origin master
```

User must create the `prudgin/WaterQualityFeed` repo on GitHub before push.

### 9. Initial `.tickets/` content

Optional: convert the `docs/planning/future-work.md` canonical-mapping-stage entry into a ticket once the design is ready. Not part of cold-start.

## What's deliberately not in this plan

- No SharePoint-side changes (no new `MercatusUnitId` column on `WQ_Units` — that's part of the future canonical-mapping stage).
- No first end-to-end run — that's a `/work-issue` first ticket, not a scaffolding step.
- No Power BI integration — out of scope; PBI can read `/mnt/data/water_quality/` independently once the mirror is live.
