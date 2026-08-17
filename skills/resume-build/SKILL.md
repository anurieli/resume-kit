---
name: resume-build
description: "Build a tailored resume PDF for a specific job from the resume-kit career database. Takes a job posting (pasted text, URL, or file), reads career.yaml, selects and orders the relevant experience/achievements/skills for that role, writes a resume HTML from the template, and renders it to a consistently formatted PDF. Use when the user pastes/links a job posting and wants a resume, or says 'build me a resume for this job', 'tailor my resume to this posting', 'make a resume for the X role at Y'."
---

# resume-build

Turns a job posting plus the career database into one tailored, consistently
formatted resume PDF. Every run produces the same visual format — what
changes is which experience gets selected and how it's emphasized, never the
layout.

## Before starting

Read `~/.config/resume-kit/config.yaml` for `data_dir`. If missing, tell the
user to run `resume-kit-init` first and stop. Read `<data_dir>/career.yaml`.
If it's empty or has no `experiences:`, tell the user to run `resume-ingest`
first.

## Workflow

1. **Get the job posting.** Accept pasted text, a URL (fetch it), or a file
   path. Extract: target title, company, key responsibilities, and the
   skills/technologies it emphasizes.
2. **Select relevant material from `career.yaml`:**
   - Rank experiences by relevance to the posting (tag overlap with the
     posting's emphasized skills, plus recency — don't bury a highly
     relevant older role under a less relevant recent one, but don't
     resurrect something a decade stale over recent equivalent experience).
   - Within a selected experience, include the achievements most relevant
     to the posting first. Don't include every achievement ever logged for
     a role — that's what makes it "tailored" rather than a dump of the
     full database.
   - Pull skills for the Skills section from `career.yaml skills:`,
     prioritized by relevance to the posting, not just by `confidence`.
   - **Every fact used must come from `career.yaml` verbatim or a light
     rewording that doesn't change its meaning.** This skill selects and
     orders; it does not invent achievements, dates, or skills to better
     match the posting. If the posting wants something genuinely missing
     from the database, leave it out — don't fabricate it — and mention
     the gap to the user in your summary at the end.
3. **Write a tailored summary** (2-3 sentences) grounded in
   `person.summary`, angled toward this posting, without inventing claims
   not supported elsewhere in `career.yaml`.
4. **Build the HTML.** Use `templates/resume-template.html` as the
   structural/style reference — same fonts, spacing, section order, and
   CSS — and write a fresh, fully-populated HTML file (not the template
   itself) to
   `<data_dir>/output/<company-slug>-<role-slug>-<YYYY-MM-DD>/resume.html`.
   Keep it to one page unless the person has substantial (12+ years)
   directly relevant experience.
5. **Render to PDF:**
   ```bash
   ~/Desktop/resume-kit/skills/resume-build/scripts/render-pdf.sh \
     "<data_dir>/output/<slug>/resume.html" \
     "<data_dir>/output/<slug>/resume.pdf"
   ```
   (Adjust the repo path to wherever resume-kit was cloned.)
6. **Verify.** Confirm the PDF exists and is a single reasonable page count
   (1-2 pages). If `pdftoppm` is available, spot-check by rendering to PNG
   and reading it — confirm nothing overflows or looks cramped.
7. **Report to the user**: which experiences/achievements were selected and
   why, any gap between what the posting wants and what's in the database
   (don't paper over this — it's useful signal for what to add next time),
   and the output path.

## Don't

- Don't invent, exaggerate, or reword an achievement to sound more aligned
  with the posting than the source material supports.
- Don't change the visual template per job — the whole point is that every
  resume this produces looks consistently like the same person's resume,
  just with different selected content.
- Don't dump the entire career database into one resume. Tailoring means
  selecting, not including everything "just in case."
