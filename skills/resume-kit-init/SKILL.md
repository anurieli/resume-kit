---
name: resume-kit-init
description: "First-run setup for resume-kit. Scaffolds a private data directory as an ICM workspace (numbered stage folders, CONTEXT.md contracts, a schema v2 career.yaml) and writes a global config pointing at it. Use once, the first time resume-kit is used on a machine, or when the user wants to point resume-kit at a different data directory. Triggers: 'set up resume-kit', 'initialize resume-kit', 'where should my career data live', 'point resume-kit at a new folder'."
---

# resume-kit-init

Sets up the one thing every other resume-kit skill depends on: a private
data directory, separate from this tool repo, that holds the user's actual
career record. This tool repo is meant to be public; the data directory
never should be.

The data directory is an ICM workspace, not a flat folder. Numbered stage
folders each carry a `CONTEXT.md` contract, and the filesystem is the
runtime:

```
<data_dir>/
├── IDENTITY.md              what this workspace is
├── CONTEXT.md               routing: trigger -> stage -> output
├── _config/                 stable reference (schema.md, format.md)
├── 01_intake/               raw documents land here
│   └── output/processed/        consumed originals, archived
├── 02_career-db/
│   ├── career.yaml              the structured spine
│   ├── self/reflections/        long-form rambles, referenced from career.yaml
│   └── output/                  ingest and enrich reports
├── 03_target/output/<slug>/                   posting.md, brief.md
└── 04_deliverable/output/<YYYY-MM-DD>-<slug>/ positioning.md, resume.html, resume.pdf
```

That structure gives the user two ways to work: call a skill
(`career-ingest`, `career-enrich`, `career-target`, `resume-build`), or drop
a file into a stage folder and let an agent read that stage's contract and
walk the pipeline.

## Workflow

1. **Check for an existing config** at `~/.config/resume-kit/config.yaml`.
   If it exists and points at a real directory, tell the user and stop
   (don't silently repoint it, ask first).
2. **Ask the user where their private data should live** if not already
   told. Good defaults to suggest: a private notes vault they already use,
   or `~/resume-kit-data`. It must NOT be inside this tool repo (that repo
   is meant to be shared or published).
3. **Run the scaffold script:**
   ```bash
   ~/Desktop/resume-kit/skills/resume-kit-init/scripts/init.sh "<data_dir>"
   ```
   (Adjust the path to wherever this repo was cloned.) It creates every
   folder and contract above, an empty schema v2 `career.yaml` at
   `<data_dir>/02_career-db/career.yaml`, and writes
   `~/.config/resume-kit/config.yaml` with `data_dir:` and `repo_dir:`.
4. **If the data directory lives inside an Obsidian vault**, set
   `RESUME_KIT_VAULT_BREADCRUMB` to the parent index wikilink first, so
   `IDENTITY.md` is written with vault frontmatter and a breadcrumb:
   ```bash
   RESUME_KIT_VAULT_BREADCRUMB='[[06-Personal/index|Personal]]' \
     ~/Desktop/resume-kit/skills/resume-kit-init/scripts/init.sh "<data_dir>"
   ```
5. **Confirm to the user** what was created, and point them at the next
   step, which depends on what they have:
   - **They have documents** (old resumes, a LinkedIn export, performance
     reviews, offer letters): drop them into `<data_dir>/01_intake/` and run
     `career-ingest`. Mention performance reviews specifically, people
     forget they have them and they hold the best numbers.
   - **They have no documents**: skip ingestion and run `career-enrich`,
     which builds the record by asking instead of by reading.

   Either way, say that ingestion is the bootstrap and `career-enrich` is
   what makes the record actually good.

## Notes

- Every other resume-kit skill reads `data_dir` from
  `~/.config/resume-kit/config.yaml`. If that file is missing, they should
  tell the user to run this skill first rather than guessing a location.
- **The config guard.** If a config already exists and names a *different*
  directory, the script scaffolds the new workspace but refuses to repoint
  the config, since silently repointing would strand an existing career
  record. It prints the re-run command with `RESUME_KIT_FORCE_CONFIG=1`.
  Only use that flag when the user has actually said they want to move.
- Re-running the script is safe. It never overwrites an existing file, so a
  filled-in `career.yaml`, any reflections, and any hand-edited contract all
  survive. To regenerate a contract from the current template, delete that
  file and run the script again.
- The stage contracts are the real interface. If a contract and a skill ever
  disagree about a path or a rule, that is a bug: fix both in one change.
