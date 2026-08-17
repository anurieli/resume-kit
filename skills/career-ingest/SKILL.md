---
name: career-ingest
description: "Bootstrap a career record from raw material sitting in a resume-kit workspace's 01_intake/ folder: old resumes, LinkedIn exports, performance reviews, offer letters, cover letters, past job postings. Merges what it finds into career.yaml with an evidence_type and source on every claim, dedupes the same job across sources, tags skills, reports files it skipped, and says how thin the resulting record is. Use when the user has dropped career material into 01_intake/ and wants it absorbed, or says 'ingest my resumes', 'process the intake', 'ingest these performance reviews', 'update my career.yaml from these files'."
---

# career-ingest

The bootstrap step. It reads documents a person already has and turns them
into structured entries in `career.yaml`, without ever inventing a fact that
isn't traceable to a source.

Ingestion is not the main event. Documents hold titles, dates, and whatever
bullets survived the last resume rewrite. They do not hold scope, judgment,
or what the person is actually good at. That comes from `career-enrich`.
This skill's job is to get the skeleton in place and then say plainly how
thin it is.

It ingests more than resumes. Performance reviews, offer letters, and
LinkedIn exports are all fair input, which is why the skill is named for
careers rather than resumes.

This skill runs stages `01_intake` and `02_career-db` of the resume-kit ICM
workspace. The stage contracts at `<data_dir>/01_intake/CONTEXT.md` and
`<data_dir>/02_career-db/CONTEXT.md` say the same thing in short form, so
the user can also just drop a file into `01_intake/` and ask an agent to
continue without naming this skill. Keep the two in sync: if you change a
rule here, change it in the contract too.

## Before starting

Read `~/.config/resume-kit/config.yaml` for `data_dir`. If it's missing,
tell the user to run `resume-kit-init` first and stop. Read
`<data_dir>/_config/career-schema-full.md` (repo copy: `../../schema/career-schema.md`, in the resume-kit
repo) for the exact shape of `career.yaml` and its hard rules. Follow those
rules literally, especially the evidence rule below.

## The evidence rule

Every claim written to `career.yaml` carries an `evidence_type` and a
`source`. No exceptions, no defaults filled in later.

Everything this skill extracts from a source document is
`evidence_type: documented`, with `source:` pointing at the file it came
from under `01_intake/output/processed/`. That is what "documented" means:
it is written down somewhere the person can go back and check.

When the user answers a question during a run, what they said is
`evidence_type: self-reported`, `source: user-confirmed <YYYY-MM-DD>`. Their
saying it confidently does not make it documented. Never promote evidence.

Opinions a person holds about themselves belong in `self_assessment` as
`self-assessment`, and this skill mostly does not produce them. Documents
rarely contain them honestly. `career-enrich` gets those by asking.

## Life-update check (runs first, every time)

Before anything else, read `<data_dir>/02_career-db/self/life-log.md` and look
at the date on the top entry.

- **Under 2 months old:** say nothing, carry on.
- **2 months old or more, or the log is empty:** ask, before doing the work
  you were called for:

  > What are you up to right now, or what have you been up to?

  Take the answer as it comes. Write it to `life-log.md` as a new dated entry
  at the top, in their words. Then file what it contains: concrete events as
  `self-reported` material in `career.yaml`, opinions about themselves as
  `self-assessment`, anything worth a longer telling as a file in
  `02_career-db/self/reflections/`. If it opens up more than one question,
  say so and suggest `career-enrich` rather than turning this into a full
  interview.

One question. Then get on with the task.

## Workflow

1. **List `<data_dir>/01_intake/`** (root only, excluding `CONTEXT.md` and
   `output/`).

   **If the folder is empty**, do not just report an empty folder and stop.
   Tell the user what to put in it and in what form:
   - Old resumes, as many versions as they can find. PDF, DOCX, TXT, MD.
   - A LinkedIn "Download your data" export (the zip, or the unzipped
     folder of CSVs). This is the most reliable source for exact dates and
     titles.
   - **Performance reviews.** Say this one out loud, people forget they
     have them. See step 3.
   - Offer letters and promotion letters, for titles, dates, and scope.
   - Cover letters and job postings they applied to, for context.

   Then add: if they have none of that, they can skip ingestion entirely
   and run `career-enrich`, which builds the record by asking instead of
   by reading.

2. **Read `<data_dir>/02_career-db/career.yaml`** to see what's already
   there. You're merging into this, not starting over.

3. **Classify every file in the folder into one of three buckets, by name
   and by opening it.** Users drop things in here that are not career
   material. Handle that without choking and without deleting anything.

   - **Usable career material.** Old resumes, CVs, LinkedIn exports,
     performance reviews, offer and promotion letters, project write-ups,
     internal brag documents. These produce entries.
   - **Context only.** Cover letters, old job postings the person applied
     to, recommendation letters. These never become experience or
     education entries. A cover letter can confirm phrasing the person
     likes; an old posting shows what roles they target. Read them, use
     them to inform questions, do not force them into the schema.
   - **Not relevant.** Screenshots, tax documents, a photo, an unrelated
     PDF that got dragged in. Skip it.

   **Report every skipped file by name**, with one line saying why, in both
   your summary and the ingest report. Silently ignoring a file is how a
   real performance review gets lost because it was named `scan_004.pdf`.
   If a file's contents are genuinely unreadable or ambiguous, ask rather
   than assuming it is junk.

   **Never delete anything from the intake folder**, including files you
   classified as not relevant. Leave those where they are.

4. **Extract raw content from each usable file:**
   - PDF / TXT / MD: read directly.
   - DOCX: `pandoc "<file>" -t markdown` to get readable text.
   - LinkedIn export (a zip, or a folder of CSVs like `Positions.csv`,
     `Education.csv`, `Skills.csv`): these are structured, so parse them
     directly rather than treating them as prose. Best source for exact
     dates and titles.
   - **Performance reviews: read these closely, they are the highest-value
     document in the folder.** They routinely contain hard numbers the
     person no longer remembers ("cut incident response time from 4 hours
     to 40 minutes", "shipped 3 of 4 roadmap commitments"), plus a
     manager's account of scope and impact that the person would never
     claim about themselves. Pull the metric verbatim, log it as
     `documented`, and cite the review file. A number from a review is the
     strongest evidence in the whole record.
   - Offer and promotion letters: titles, start dates, level changes,
     sometimes team scope. Precise and `documented`.

5. **Extract candidate entries** (experience, education, projects,
   certifications), each carrying `evidence_type: documented` and a
   `source:` pointing at the intake file it came from.

6. **Merge against existing `career.yaml`:**
   - Match experiences by `(company, overlapping dates)`, not exact title
     text. The same job is often titled slightly differently across two
     resumes.
   - When two sources describe the same job, union their achievement
     lists. Don't drop one source's material because another already
     covered the job. Dedupe near-identical achievement bullets (same
     underlying fact, reworded), but keep distinct achievements even if
     they're from the same role.
   - When two sources state the same fact at different strengths, keep the
     stronger evidence. A metric from a performance review outranks the
     same claim rounded off on an old resume, and its `source:` should
     point at the review.
   - New companies/roles not seen before become new entries with a fresh
     stable `id` (e.g. `exp-<company-slug>-<start-year>`).
   - Never overwrite anything `career-enrich` wrote. `context:`,
     `reflections:`, and `self_assessment` are not this skill's to edit.

7. **Tag as you go.** Every achievement gets `tags:` (skills/technologies/
   themes it demonstrates). Be specific and consistent: reuse existing tag
   names already in `career.yaml` rather than inventing near-duplicates
   (`python` not `Python3`).

8. **Ask when stuck.** Concretely, ask the user rather than guessing when:
   - Two sources give conflicting dates or titles for what looks like the
     same job.
   - An achievement's company/role attribution is unclear.
   - A resume format doesn't map cleanly onto the schema (e.g. a
     freelance/consulting block with multiple clients under one heading).
   - A file could be career material or junk and you cannot tell.

   Batch these into one set of questions per ingestion run rather than
   asking one at a time back and forth. Anything the user answers is
   `self-reported`, sourced `user-confirmed <YYYY-MM-DD>`.

9. **Regenerate the `skills:` section from scratch** by aggregating tags
   across all experiences/projects/achievements: `first_used` /
   `last_used` from the date range of entries carrying that tag,
   `evidence_count` from how many entries carry it, `confidence` as
   high (5+ entries or used in the last 2 years), medium (2-4, or used
   3-5 years ago), low (1 entry, or not used in 5+ years). Every entry
   carries `evidence_type: derived`.

10. **Write the updated `career.yaml`** to
    `<data_dir>/02_career-db/career.yaml`, bumping `meta.last_ingested` to
    today's date. Leave `meta.last_enriched` alone, it is not yours.

11. **Update `meta.enrichment_gaps`** with what ingestion could not answer,
    so `career-enrich` knows where to start. Typical entries: a role with
    no metrics, a recent role with no reflections, an empty
    `self_assessment`, a job with dates but no achievements at all.

12. **Archive consumed originals** to
    `<data_dir>/01_intake/output/processed/`, keeping the filename exactly
    so every `source:` in `career.yaml` still resolves. Move, never copy
    and never delete. Files classified as not relevant stay in the intake
    root untouched.

13. **Write an ingestion report** to
    `<data_dir>/02_career-db/output/<YYYY-MM-DD>-ingest.md`: entries added
    vs. merged into existing ones, skills now tracked, files skipped and
    why, every question you asked with how it was answered, and the
    thinness assessment from step 14.

14. **Assess how thin the record is, and say so.** Ingestion produces a
    skeleton by design. Count what is missing and report it plainly:
    - how many experiences have no metric,
    - how many have no `context:` (team size, scope, whether the work was
      unprompted),
    - how many have no `reflections:`,
    - whether `self_assessment` is still empty.

    Then recommend running `career-enrich` and name one or two specific
    things it should ask about first, drawn from
    `meta.enrichment_gaps`. Something like: "Four roles, no metrics on
    three of them, and nothing at all on what you are good at. Run
    `career-enrich` and start with the Northwind role, it has dates and a
    title and nothing else." A resume built off a record this thin will
    read like a job description, and the user should know that before they
    build one.

15. **Report a short summary** to the user, matching the written report,
    and name the report's path.

## Don't

- Don't write a claim without both `evidence_type` and `source`. If you're
  inferring rather than reading it directly, ask instead of inferring.
- Don't mark anything `documented` that did not come from a document. What
  the user told you in conversation is `self-reported`.
- Don't skip a file silently. Name it and say why in the report.
- Don't delete anything a user put in the intake folder, junk included.
- Don't silently merge two different jobs at the same company just
  because the company matches. Check for overlapping or adjacent dates.
- Don't hand-edit `skills:` incrementally; always regenerate it fully from
  current tags so it stays accurate.
- Don't write to `self_assessment`, `context:`, or `reflections:`. Those
  belong to `career-enrich`.
- Don't report a thin record as a finished one. Say what's missing.
