---
name: resume-kit-init
description: "First-run setup for resume-kit. Scaffolds a private data directory as an ICM workspace (numbered stage folders, CONTEXT.md contracts, career.yaml) and writes a global config pointing at it. Use once, the first time resume-kit is used on a machine, or when the user wants to point resume-kit at a different data directory. Triggers: 'set up resume-kit', 'initialize resume-kit', 'where should my resume data live', 'point resume-kit at a new folder'."
---

# resume-kit-init

Sets up the one thing every other resume-kit skill depends on: a private
data directory, separate from this tool repo, that holds the user's actual
career data. This tool repo is meant to be public; the data directory never
should be.

The data directory is an ICM workspace, not a flat folder. Numbered stage
folders each carry a `CONTEXT.md` contract, and the filesystem is the
runtime:

```
<data_dir>/
├── IDENTITY.md          what this workspace is
├── CONTEXT.md           routing: trigger -> stage -> output
├── _config/             stable reference (schema.md, format.md)
├── 01_intake/           raw material lands here
├── 02_career-db/        career.yaml, the durable database
├── 03_target/           one job posting, captured and briefed
└── 04_deliverable/      the tailored resume, HTML and PDF
```

That structure gives the user two ways to work: call a skill
(`resume-ingest`, `resume-build`), or drop a file into a stage folder and
let an agent read that stage's contract and walk the pipeline.

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
   folder and contract above, an empty schema-conformant `career.yaml` at
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
   step: drop old resumes, a LinkedIn export, or cover letters into
   `<data_dir>/01_intake/`, then run `resume-ingest`.

## Notes

- Every other resume-kit skill reads `data_dir` from
  `~/.config/resume-kit/config.yaml`. If that file is missing, they should
  tell the user to run this skill first rather than guessing a location.
- Re-running the script is safe. It never overwrites an existing file, so a
  filled-in `career.yaml` and any hand-edited contract both survive. To
  regenerate a contract from the current template, delete that file and run
  the script again.
- The stage contracts are the real interface. If a contract and a skill ever
  disagree about a path or a rule, that is a bug: fix both in one change.
