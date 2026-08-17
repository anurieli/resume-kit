---
name: resume-ingest
description: "Process raw career material (old resumes, LinkedIn exports, cover letters, past job postings) sitting in a resume-kit data directory's inbox/ folder, and merge it into career.yaml — deduping the same job across multiple sources, tagging skills, keeping a source trail for every fact, and asking the user when something is ambiguous or doesn't fit the schema. Use when the user has dropped resume material into inbox/ and wants it absorbed into their career database, or says 'ingest my resumes', 'process the inbox', 'update my career.yaml from these files'."
---

# resume-ingest

Turns messy raw material into structured entries in `career.yaml`, without
ever inventing a fact that isn't traceable to a source.

## Before starting

Read `~/.config/resume-kit/config.yaml` for `data_dir`. If it's missing,
tell the user to run `resume-kit-init` first and stop. Read
`../../schema/career-schema.md` (relative to this skill, in the resume-kit
repo) for the exact shape of `career.yaml` and its hard rules — follow
those rules literally, especially rule 1 (never fabricate) and rule 3
(ask when ambiguous).

## Workflow

1. **List `<data_dir>/inbox/`** (excluding `processed/` and `README.md`).
   If empty, tell the user there's nothing to ingest and stop.
2. **Read `<data_dir>/career.yaml`** to see what's already there — you're
   merging into this, not starting over.
3. **For each inbox file, extract raw content:**
   - PDF / TXT / MD: read directly.
   - DOCX: `pandoc "<file>" -t markdown` to get readable text.
   - LinkedIn export (a zip, or a folder of CSVs like `Positions.csv`,
     `Education.csv`, `Skills.csv`): these are structured — parse them
     directly rather than treating them as prose. They're usually the most
     reliable source for exact dates and titles.
   - Cover letters and old job postings: don't turn these into
     experience/education entries. Use them as *context* — a cover letter
     may confirm phrasing/achievements the user likes; an old job posting
     you applied to is a useful data point for what kinds of roles they
     target, but nothing here forces its way into the schema.
4. **Extract candidate entries** (experience, education, projects,
   certifications) from each source, each carrying a `source:` pointing at
   the inbox file it came from.
5. **Merge against existing `career.yaml`:**
   - Match experiences by `(company, overlapping dates)`, not exact title
     text — the same job is often titled slightly differently across two
     resumes.
   - When two sources describe the same job, union their achievement
     lists — don't drop one source's material because another already
     covered the job. Dedupe near-identical achievement bullets (same
     underlying fact, reworded), but keep distinct achievements even if
     they're from the same role.
   - New companies/roles not seen before become new entries with a fresh
     stable `id` (e.g. `exp-<company-slug>-<start-year>`).
6. **Tag as you go.** Every achievement gets `tags:` (skills/technologies/
   themes it demonstrates). Be specific and consistent — reuse existing tag
   names already in `career.yaml` rather than inventing near-duplicates
   (`python` not `Python3`).
7. **Ask when stuck.** Concretely, ask the user rather than guessing when:
   - Two sources give conflicting dates or titles for what looks like the
     same job.
   - An achievement's company/role attribution is unclear.
   - A resume format doesn't map cleanly onto the schema (e.g. a
     freelance/consulting block with multiple clients under one heading).
   Batch these into one set of questions per ingestion run rather than
   asking one at a time back and forth.
8. **Regenerate the `skills:` section from scratch** by aggregating tags
   across all experiences/projects/achievements: `first_used` /
   `last_used` from the date range of entries carrying that tag,
   `evidence_count` from how many entries carry it, `confidence` as
   high (5+ entries or used in the last 2 years), medium (2-4, or used
   3-5 years ago), low (1 entry, or not used in 5+ years).
9. **Write the updated `career.yaml`**, bump `meta.last_ingested` to
   today's date.
10. **Move processed files** from `inbox/` to `inbox/processed/` so a
    re-run doesn't re-ingest the same material.
11. **Report a short summary**: how many experiences/entries were
    added vs. merged into existing ones, how many skills now tracked, and
    anything you asked the user about.

## Don't

- Don't write an achievement, date, or skill that isn't backed by a
  `source:`. If you're inferring rather than reading it directly, ask
  instead of inferring.
- Don't silently merge two different jobs at the same company just
  because the company matches — check for overlapping or adjacent dates.
- Don't hand-edit `skills:` incrementally; always regenerate it fully from
  current tags so it stays accurate.
