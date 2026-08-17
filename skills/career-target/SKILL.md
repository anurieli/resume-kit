---
name: career-target
description: "Analyze a job posting against the resume-kit career database and produce honest positioning, a plain gap analysis, concrete tips to close the gaps, and a real apply-or-not recommendation. Captures the posting and a structured brief, then writes positioning.md. Also detects patterns across past targets, so a requirement that keeps showing up gets named as a ceiling rather than a one-off miss. Runs before resume-build, and can be run instead of it when the question is whether to apply at all. Use when the user says 'should I apply to this', 'how do I position for this role', 'what are my gaps for this job', 'analyze this posting', 'coach me on this application', or pastes a posting and asks what they think."
---

# career-target

The coaching half of resume-kit. `resume-build` answers "what document do I
send". This answers the questions that come first: is this role worth the
application, what is the honest angle on this person for this job, what is
genuinely missing, and what would close it.

A person can run this and stop. Deciding not to apply, with a clear reason
and a list of what to do about it, is a legitimate output.

This skill runs stage `03_target` and the positioning half of
`04_deliverable` in the resume-kit ICM workspace. The stage contracts at
`<data_dir>/03_target/CONTEXT.md` and `<data_dir>/04_deliverable/CONTEXT.md`
say the same thing in short form, so the user can also drop a posting into
`03_target/` and ask an agent to continue without naming this skill. Keep
the two in sync: if you change a rule here, change it in the contract too.
`resume-build` shares stage `03_target` and reads the same `posting.md` and
`brief.md`, so when both run for one job they use one slug and one brief.

## Before starting

Read `~/.config/resume-kit/config.yaml` for `data_dir`. If it is missing,
tell the user to run `resume-kit-init` first and stop.

Read `<data_dir>/02_career-db/career.yaml` in full, plus
`<data_dir>/_config/career-schema-full.md` (repo copy: `../../schema/career-schema.md`, in the resume-kit
repo) for the `evidence_type` rules that govern what you may state as fact.
Read any reflections under `<data_dir>/02_career-db/self/reflections/` that
belong to experiences relevant to this posting. The reflections are where
the honest angle usually comes from, since they hold the parts of a job
that never made it onto a resume.

If `career.yaml` has no `experiences:`, tell the user to run
`career-ingest` first and stop.

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

1. **Capture the posting (stage `03_target`).** Accept pasted text, a URL
   (fetch it), or a file path. Build the slug `<company>-<role>`, lowercase
   and hyphenated, and use that same slug through stage 04.
   - Write the posting verbatim to
     `<data_dir>/03_target/output/<slug>/posting.md`. Do not summarize at
     this step. Postings get taken down within weeks and the raw text is the
     record, both for this session and for the pattern detection in step 4.
   - If a fetched page came back partial or paywalled, say so and ask the
     user to paste the text rather than working from a fragment.
2. **Write the brief** to `<data_dir>/03_target/output/<slug>/brief.md`:
   target title, company, emphasized skills and technologies, key
   responsibilities, seniority signals (years asked for, scope of ownership,
   who the role reports to, whether it names leading or mentoring). Stick to
   the posting's own claims. Do not infer what the company "really wants",
   and do not import what you know about the company from elsewhere. Note
   which requirements the posting repeats or lists first, since repetition
   is the clearest signal a posting gives about what it actually screens
   for. If `brief.md` already exists for this slug from a `resume-build`
   run, update it rather than replacing it, and keep the same structure.
3. **Check the record is strong enough to position from.** Before writing
   anything in stage 04, judge whether `career.yaml` can support real
   advice for this posting. It cannot when the relevant experiences carry no
   metrics and no context, when `self_assessment` is empty, or when the only
   material is achievement bullets lifted from an old resume. If that is the
   case, say so plainly, name what is missing, and recommend running
   `career-enrich` on the specific roles that matter for this posting before
   continuing. Offer to write the brief and stop there. Do not produce a
   thin positioning document and hope it reads as insight. A confident
   analysis of an empty record is worse than no analysis, because the person
   will act on it.
4. **Detect cross-application patterns.** Read every past brief at
   `<data_dir>/03_target/output/*/brief.md`, excluding this one.
   - With **three or more** past targets, look for requirements that appear
     across multiple briefs and are absent from `career.yaml`. When one
     recurs, name it as a pattern with the count and the target names, for
     example "four of your last five targets named Kubernetes; that is not
     a one-off gap for this job, it is the ceiling on the roles you are
     drawn to." Also surface the inverse when it is true: a strength the
     person keeps having that these postings keep asking for, which is
     worth leading with every time.
   - With **fewer than three** past targets, say the sample is too small to
     call a pattern and move on. Do not manufacture a trend from two
     postings, and do not present a single repeat as a pattern.
   - Only count a requirement as a gap here if `career.yaml` genuinely does
     not cover it. Check tags, achievements, and reflections before
     concluding something is missing.
5. **Write positioning** to
   `<data_dir>/04_deliverable/output/<YYYY-MM-DD>-<slug>/positioning.md`,
   with these five sections in this order:
   1. **How you read for this role.** The honest angle. What story does
      this record tell a screener looking at it through this posting? Lead
      with the strongest genuine asset for this specific job, which is
      often not the most prominent line on the resume. A backend engineer
      applying to a platform team may have the migration nobody wanted to
      own as their real asset, not the title. Say what a screener will
      notice first, and say whether that is the thing you want them to
      notice.
   2. **Strongest evidence.** The three to five specific achievements to
      lead with, each with the reason it lands for this posting. Cite them
      as they exist in `career.yaml`, with their real evidence type. A
      `documented` metric can be stated as fact. A `self-reported` account
      is experience, not a verified number, and should be described that
      way so the person knows what they can put in writing and what they
      can only say in conversation.
   3. **Gaps.** What the posting asks for that the record does not have.
      State each one plainly and do not rank a real gap below a soft one to
      make the list feel better. Distinguish a hard gap (named as a
      requirement, repeated, tied to the core of the role) from a soft one
      (listed under nice-to-have, or adjacent to something the person has).
      Never suggest wording that implies experience the record does not
      support, and never tell someone a gap will not be noticed.
   4. **Tips to close the gaps.** Concrete, specific, and sized to the gap.
      Each one names an actual action with a realistic time cost and,
      where possible, a linkable artifact at the end of it. The right
      altitude: "the posting names OpenTelemetry twice and you have
      observability work but nothing citable; one merged PR to an OTel
      instrumentation library is a weekend and gives you a link." For a
      research-oriented role it might be reading two named papers and
      writing a public response, or reproducing a specific result. For a
      management role it might be a written artifact about a team decision
      already made. Say which tips are worth doing before this application
      and which are longer plays for the pattern in step 4. Never write
      generic advice like "learn Kubernetes" or "build your network"; if
      you cannot name the specific thing to do, say the gap cannot be
      closed quickly and treat it as an input to the recommendation.
   5. **Should you apply?** A real answer, not a hedge. Yes, yes with
      conditions, or probably not. When it is probably not, say what would
      change it and roughly how long that takes. When it is yes, say what
      the application has to do well to survive a screen. Weigh the pattern
      from step 4 here: a gap that has blocked four applications is a
      different decision than one that turned up today.
6. **Use `self_assessment` to shape, never to assert.** What the person
   says they are good at should influence which achievements you lead with,
   how you describe the fit, and which environments you flag as a mismatch.
   It never appears in the document as a claim about them. Write "your
   record shows you keep ending up owning the thing nobody else will",
   grounded in logged experiences, not "you are excellent at ownership"
   because they said so. `self_assessment.working_on` and `prefers` are
   inputs to the gap list and the recommendation: a role that is a skill
   fit and an environment mismatch should say that out loud.
7. **Report to the user in a few lines**: the angle, the top one or two
   gaps, any cross-target pattern, the recommendation, and the paths to
   `brief.md` and `positioning.md`. Then say whether the next step is
   `resume-build`, `career-enrich`, or nothing.

## Don't

- Don't soften a gap, bury it under strengths, or imply it can be worded
  around. The value of this document is that it tells the person what a
  screener will see.
- Don't suggest phrasing that stretches a `self-reported` account into a
  documented result, and don't recommend claiming exposure to something the
  record does not contain.
- Don't print a `self-assessment` as a verified fact, in the positioning
  document or in your summary.
- Don't invent a pattern from fewer than three past targets, and don't
  inflate a single recurrence into a trend. Say the sample is small.
- Don't give tips that could have been written without reading the posting.
  "Get certified", "practice system design", "improve your resume" are not
  tips, they are filler.
- Don't recommend applying to everything. A recommendation that is always
  yes carries no information, and the person will stop reading it.
- Don't summarize the posting in `posting.md`. That file is the verbatim
  record; analysis belongs in `brief.md` and `positioning.md`.
- Don't build a resume here. If the person wants the document, hand off to
  `resume-build`, which reads the same slug and brief.
