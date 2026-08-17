---
name: resume-kit-init
description: "First-run setup for resume-kit. Creates a private data directory (career.yaml, inbox/, output/) and a global config pointing at it. Use once, the first time resume-kit is used on a machine, or when the user wants to point resume-kit at a different data directory. Triggers: 'set up resume-kit', 'initialize resume-kit', 'where should my resume data live', 'point resume-kit at a new folder'."
---

# resume-kit-init

Sets up the one thing every other resume-kit skill depends on: a private
data directory, separate from this tool repo, that holds the user's actual
career data. This tool repo is meant to be public; the data directory never
should be.

## Workflow

1. **Check for an existing config** at `~/.config/resume-kit/config.yaml`.
   If it exists and points at a real directory, tell the user and stop
   (don't silently overwrite — ask first if they want to repoint it).
2. **Ask the user where their private data should live** if not already
   told. Good defaults to suggest: a private notes vault they already use,
   or `~/resume-kit-data`. It must NOT be inside this tool repo (that repo
   is meant to be shared/public).
3. **Run the scaffold script:**
   ```bash
   ~/Desktop/resume-kit/skills/resume-kit-init/scripts/init.sh "<data_dir>"
   ```
   (Adjust the path to wherever this repo was cloned.) This creates
   `career.yaml` (empty, schema-conformant), `inbox/`, `output/`, and writes
   `~/.config/resume-kit/config.yaml` with `data_dir: <data_dir>`.
4. **Confirm to the user** what was created and point them at
   `resume-ingest` as the next step: drop old resumes / LinkedIn export /
   cover letters into `<data_dir>/inbox/`, then run resume-ingest.

## Notes

- Every other resume-kit skill reads `data_dir` from
  `~/.config/resume-kit/config.yaml`. If that file is missing, they should
  tell the user to run this skill first rather than guessing a location.
- Re-running this skill is safe: it never overwrites an existing
  `career.yaml`.
