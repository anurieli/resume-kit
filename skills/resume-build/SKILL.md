---
name: resume-build
description: "Build a tailored resume PDF for a specific job from the resume-kit career database. Takes a job posting (pasted text, URL, or file), reads career.yaml and the positioning brief career-target produced for this role, selects and orders the relevant experience/achievements/skills, writes a resume HTML from the template, and renders it to a consistently formatted PDF. Use when the user pastes/links a job posting and wants a resume, or says 'build me a resume for this job', 'tailor my resume to this posting', 'make a resume for the X role at Y'."
---

# resume-build

Turns a job posting plus the career database into one tailored, consistently
formatted resume PDF. Every run produces the same visual format. What
changes is which experience gets selected and how it's emphasized, never the
layout.

This is the last step of the loop, not the product. The product is
`career.yaml`. A resume is a view of it, rendered for one company.

This skill runs stages `03_target` and `04_deliverable` of the resume-kit
ICM workspace. The stage contracts at `<data_dir>/03_target/CONTEXT.md` and
`<data_dir>/04_deliverable/CONTEXT.md` say the same thing in short form, so
the user can also just drop a posting into `03_target/` and ask an agent to
continue without naming this skill. Keep the two in sync: if you change a
rule here, change it in the contract too.

## Before starting

Read `~/.config/resume-kit/config.yaml` for `data_dir`. If missing, tell the
user to run `resume-kit-init` first and stop. Read
`<data_dir>/02_career-db/career.yaml`. If it's empty or has no
`experiences:`, tell the user to run `career-ingest` first (or
`career-enrich`, if they have no documents to ingest).

If the record is present but thin (few metrics, no `context:`, no
`reflections:`, empty `self_assessment`), say so up front and offer
`career-enrich` first. You can still build from a thin record, the resume
will just read like a job description. That is worth one sentence before
spending the run, not a refusal.

## What may be printed

`career.yaml` carries an `evidence_type` on every claim, and it decides what
this skill is allowed to put on a page. Read
`<data_dir>/_config/career-schema-full.md` for the full rule. Applied here:

| `evidence_type` | May it appear in the resume? |
|---|---|
| `documented` | Yes. Strongest material, prefer it. |
| `self-reported` | Yes, as experience. Never dressed up as a verified metric. |
| `self-assessment` | **No.** It shapes which experience you select and the words you choose. It is never printed as a claim. |
| `derived` | No. Internal only. `skills:` entries are a selection input, and the skill names themselves may be listed, but no derived confidence or evidence count reaches the page. |

The practical version: "I'm good at getting non-technical stakeholders to
accept technical risk" is a `self-assessment`. It never appears on the
resume as a bullet. What it does is tell you to lead with the migration
achievement where that actually happened, and to say "aligned finance and
engineering on the rollout" rather than "wrote the migration script."

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

1. **Check for a positioning brief.** Build the slug `<company>-<role>`,
   lowercase and hyphenated, then look under
   `<data_dir>/04_deliverable/output/` for a `<YYYY-MM-DD>-<slug>/`
   folder containing `positioning.md`, written by `career-target`.
   - **If one exists, read it and follow it, and write this resume into
     that same dated folder** rather than creating a second one for today.
     The positioning, the resume, and the PDF for one application belong
     together. If several dated folders match the slug (the person applied
     to this company before), use the most recent, and read the older ones
     for what was said last time.
   - `positioning.md` says how to angle this person for this role: which
     experience to lead with, which gaps exist, what to emphasize. It is
     the tailoring instruction, and it outranks your own read of the
     posting.
   - **If none exists**, tell the user that `career-target` produces one
     and that running it first gives a better resume, since it does the
     positioning and gap analysis this skill does not. Offer to continue
     without it. If they say go, proceed on `brief.md` alone and create
     `<data_dir>/04_deliverable/output/<YYYY-MM-DD>-<slug>/` yourself,
     dated today.
2. **Capture the job posting (stage `03_target`)**, if `career-target`
   hasn't already. Accept pasted text, a URL (fetch it), or a file path.
   Use the same slug through stage 04.
   - Write the posting verbatim to
     `<data_dir>/03_target/output/<slug>/posting.md`. Don't summarize here;
     postings get taken down and the raw text is the record.
   - Write `<data_dir>/03_target/output/<slug>/brief.md` with four sections:
     target title, company, emphasized skills and technologies, key
     responsibilities. Keep it to the posting's own claims.
3. **Select relevant material from `career.yaml`:**
   - Follow `positioning.md` when there is one.
   - Rank experiences by relevance to the posting (tag overlap with the
     posting's emphasized skills, plus recency. Don't bury a highly
     relevant older role under a less relevant recent one, but don't
     resurrect something a decade stale over recent equivalent experience).
   - Within a selected experience, include the achievements most relevant
     to the posting first. Don't include every achievement ever logged for
     a role. That's what makes it "tailored" rather than a dump of the
     full database. Prefer `documented` achievements, especially ones
     carrying a `metric`.
   - Use `context:` and `reflections:` to choose and phrase, not to quote.
     They tell you which role actually shows the thing this job wants.
   - Use `self_assessment` for emphasis and word choice only, per the table
     above. Never as a bullet.
   - Pull skills for the Skills section from `career.yaml skills:`,
     prioritized by relevance to the posting, not just by `confidence`.
   - **Honor `meta.presentation_preferences` if it exists.** A person may
     have decided that some class of skill reads as dated in their market,
     or that a capability framing beats a tool list. That is their call
     about their own field, so follow it even when the raw tags would
     suggest otherwise. It governs framing and ordering only. It cannot
     promote a skill that no role or project carries, and it cannot
     suppress something the posting explicitly requires: name that
     conflict in your summary instead of quietly resolving it.
   - A skills list of bare tool names is the weakest version of this
     section. Where the record supports it, group by what the person can
     do and put the tools inside the group. `skills:` is a set of tags,
     not a sentence, so it is on you to render it as one.
   - **Every fact used must come from `career.yaml` verbatim or a light
     rewording that doesn't change its meaning.** This skill selects and
     orders; it does not invent achievements, dates, or skills to better
     match the posting. If the posting wants something genuinely missing
     from the database, leave it out, don't fabricate it, and mention
     the gap to the user in your summary at the end.
4. **Write a tailored summary** (2-3 sentences) grounded in
   `person.summary`, angled toward this posting, without inventing claims
   not supported elsewhere in `career.yaml`. A summary is the one place
   `self-assessment` can shape tone, and even there it cannot become a
   stated fact.
5. **Build the HTML (stage `04_deliverable`).** Write a fresh,
   fully-populated HTML file to
   `<data_dir>/04_deliverable/output/<YYYY-MM-DD>-<slug>/resume.html`,
   the dated folder resolved in step 1. The date prefix keeps a second
   application to the same company from overwriting the first, so the
   folder is a history of what was actually sent and when. Build it from
   the repo's `templates/` folder:
   - **Read `<data_dir>/_config/theme.css` and inline its full contents
     verbatim**
     into the output's `<style>` block. Do not rewrite, reformat, tune, or
     "improve" any rule, and do not add styles of your own. This file is
     the format; copying it unchanged is what keeps every resume this tool
     produces visually identical.
   - **Follow `<data_dir>/_config/resume-template.html` for structure**: the same
     section order, the same class names (`.entry`, `.entry-head`,
     `.entry-title`, `.entry-org`, `.entry-dates`, `.entry-loc`,
     `ul.bullets`, `.skills-list`), repeating the `.entry` block per
     selected experience.
   - If the user has edited either file, those edits are the format now.
     Follow them, and never revert to what's described here.
   Keep it to one page unless the person has substantial (12+ years)
   directly relevant experience.
6. **Render to PDF:**
   ```bash
   ~/Desktop/resume-kit/skills/resume-build/scripts/render-pdf.sh \
     "<data_dir>/04_deliverable/output/<YYYY-MM-DD>-<slug>/resume.html" \
     "<data_dir>/04_deliverable/output/<YYYY-MM-DD>-<slug>/resume.pdf"
   ```
   (Adjust the repo path to wherever resume-kit was cloned, or read
   `repo_dir` from `~/.config/resume-kit/config.yaml`.) This step needs
   shell access, since it drives headless Chrome. On a surface without a
   shell, stop after `resume.html` and tell the user the PDF is pending.
7. **Verify.** Confirm the PDF exists and is a single reasonable page count
   (1-2 pages). If `pdftoppm` is available, spot-check by rendering to PNG
   and reading it: confirm nothing overflows or looks cramped.
8. **Build the submission kit.** In the dated folder, write
   `SUBMISSION-KIT.md` and a `submission/` subfolder:
   - `submission/` holds the send-ready file, named as the employer will see
     it: `<Person Name> - Resume.pdf`. The working `resume.html` and
     `resume.pdf` stay in the dated folder. One folder to open when it is
     time to actually apply.
   - `SUBMISSION-KIT.md` covers: what to send, what is here for the person
     rather than the employer (positioning, posting, brief, with links), how
     the resume was angled for this posting, the known risk a screener will
     hit, and what to do once it is sent.
9. **Promote it, and log it.** Copy the finished PDF and HTML to
   `<data_dir>/CURRENT-RESUME.pdf` and `<data_dir>/CURRENT-RESUME.html`.
   That pair is always the newest finalized resume, so anyone who just needs
   "the resume" takes it without reading the archive. Copies, not symlinks,
   so they survive being emailed or moved. Then add a row to
   `<data_dir>/04_deliverable/output/index.md`: date, what it was built for,
   folder, status.
   - **A build that has been sent is frozen.** Never edit, re-render, or
     overwrite a dated folder afterwards. It is the record of what that
     company actually received, and the only way to answer "what did I tell
     them?" later.
   - A newer finalized build becomes current. The previous one keeps its
     folder and its row; being archived just means no longer being newest.
   - Only the person overrides this. Do not unfreeze a sent resume, and do
     not overwrite `CURRENT-RESUME.pdf` with an unfinished draft.
10. **Report to the user**: which experiences and achievements were selected
   and why, any gap between what the posting wants and what's in the
   database (don't paper over this, it's useful signal for what to add next
   time), and the output path. If a gap looks like something the person
   probably did but never logged, say so and point at `career-enrich`.

## Don't

- Don't invent, exaggerate, or reword an achievement to sound more aligned
  with the posting than the source material supports.
- **Don't print a `self-assessment` as a claim.** It shapes emphasis and
  wording, nothing more. "Strong communicator" is not a resume bullet, it
  is an instruction to pick the bullet where communication is visible.
- **Don't print anything `derived`.** No confidence levels, no evidence
  counts, no computed anything.
- **Don't promote evidence to make a bullet land harder.** A
  `self-reported` number does not get stated as a measured result. If it
  needs to sound stronger, the fix is a document in `01_intake/`, not a
  rewrite here.
- Don't change the format per job. Content is tailored; format never is.
  If a job "would look better" with different styling, that instinct is
  wrong. The consistency is the product. A genuine format change belongs
  in `<data_dir>/_config/theme.css`, applied to all future resumes, not to one
  output.
- Don't dump the entire career database into one resume. Tailoring means
  selecting, not including everything "just in case."
- Don't write back to `career.yaml`. This skill reads it and never edits
  it. Gaps you find get reported, not patched.
