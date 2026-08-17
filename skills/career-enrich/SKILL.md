---
name: career-enrich
description: "Interview the user about their working life and turn a thin career.yaml into a rich one. Assesses which roles lack metrics, context, or reflections, asks three to five targeted questions drawn from the interview bank, captures long-form rambles as markdown reflections, and extracts structured data back into career.yaml with correct evidence types. Use when the user says 'enrich my career record', 'interview me about my jobs', 'I want to add detail about a role', 'let me tell you about what I did at X', 'what's missing from my career record', 'add a reflection', or when a resume came out generic because the database is thin."
---

# career-enrich

The interview loop. Ingestion gets titles and dates out of old documents.
This is where the record picks up scope, numbers, initiative, and the
person's own read on what they are good at. A career database that only
holds what a previous resume already said cannot produce anything better
than that resume.

This skill runs stage `02_career-db` of the resume-kit ICM workspace, the
`self/` shelf in particular. The stage contract at
`<data_dir>/02_career-db/CONTEXT.md` says the same thing in short form, so
the user can also drop a written ramble into `02_career-db/self/` and ask an
agent to continue without naming this skill. Keep the two in sync: if you
change a rule here, change it in the contract too.

## Before starting

Read `~/.config/resume-kit/config.yaml` for `data_dir`. If it is missing,
tell the user to run `resume-kit-init` first and stop.

Read, in this order, and do not start asking until you have:

1. `<data_dir>/02_career-db/career.yaml`. The whole file, not a skim. Every
   question you ask has to be informed by it.
2. `<data_dir>/_config/career-schema-full.md`. The `evidence_type` table
   there governs everything you write. (The repo copy at
   `../../schema/career-schema.md` is the same file; prefer the workspace
   one so this works when the repo is not reachable.)
3. `<data_dir>/_config/interview-bank.md`. This is where your questions
   come from. (Repo copy: `../../schema/interview-bank.md`.)
4. Any existing files under `<data_dir>/02_career-db/self/reflections/`, so
   you do not ask about ground the person has already covered.

If `career.yaml` has no `experiences:` at all, there is nothing to enrich
around. Tell the user to run `career-ingest` first so the interview has
something to attach to, and stop. If they have no documents to ingest, you
can proceed, but say plainly that you are building the record from scratch
by interview and it will take several sessions.

## Workflow

1. **Assess the record and say what you find, honestly.** Walk
   `career.yaml` and produce a short read before asking anything:
   - Which experiences have no `metric` on any achievement.
   - Which have no `context:` block (no scope, no team size, no
     `initiative`).
   - Which have an empty `reflections:` list, weighted toward the recent and
     senior roles, since those are the ones a target role will care about.
   - Whether `self_assessment` is empty or nearly so, and which of its four
     parts (`strengths`, `people_come_to_me_for`, `working_on`, `prefers`)
     are missing.
   - Any experience whose achievements all came from one old resume, which
     usually means the record is that resume rather than the job.
   Report this in four or five lines and name the record as thin, partial,
   or rich. Do not soften it. If the record would produce a generic resume,
   say so, and say which role is doing the most damage.
2. **Pick the thinnest target.** One area per session. Usually the most
   recent substantial role with no metrics and no reflection, or an empty
   `self_assessment` when every role is already covered. If
   `meta.enrichment_gaps` already names a target from a previous session,
   start there instead. Tell the user which area you picked and why, in one
   sentence.
3. **Ask three to five questions.** Draw them from
   `<data_dir>/_config/interview-bank.md`, chosen for the target area, never read
   top to bottom. Rules that matter more than the question list:
   - Never ask something `career.yaml` already answers. If three
     achievements are logged for Acme, do not ask what they did at Acme, ask
     what they did there that never made it onto the resume.
   - Ask open questions and then stop talking. Do not suggest an answer, do
     not offer multiple choice, do not ask "would you say you're good at
     leadership".
   - Follow the thread. If an answer opens something up, chase it and drop a
     scripted question rather than working through your list.
   - Ask for numbers once, gently, and only where a number plausibly exists.
     Check `01_intake/output/processed/` first: performance reviews often
     hold numbers the person has forgotten, and citing one back to them is a
     better prompt than asking cold.
4. **Let rambles run.** When the user talks at length rather than answering
   the question asked, do not interrupt to structure it and do not
   redirect. When they finish:
   - Write the raw account to
     `<data_dir>/02_career-db/self/reflections/<slug>.md`, where `<slug>` is
     lowercase hyphenated and names the subject, for example
     `acme-billing-migration.md`. Create the directory if it does not exist.
   - Keep their words. Light cleanup only: remove filler, fix obvious
     transcription noise, add paragraph breaks and a heading. Do not
     rewrite their phrasing into yours, do not make it sound more
     professional, and do not add a conclusion they did not reach. Their
     phrasing is usually better than a polished version, and it is the raw
     material a future session reads.
   - Head the file with the date captured and what prompted it.
5. **Extract into `career.yaml`, classifying every piece correctly.** This
   is the step where the tool stays honest or stops being useful:
   - A concrete event or fact the person reports about their work becomes an
     achievement or a `context:` block, `evidence_type: self-reported`,
     `source: "user-ramble <YYYY-MM-DD>"` or `"user-interview <YYYY-MM-DD>"`.
   - An opinion the person holds about themselves goes to
     `self_assessment` (`strengths`, `people_come_to_me_for`, `working_on`,
     `prefers`), `evidence_type: self-assessment`. Back a strength with
     `backed_by:` experience IDs only where a logged achievement actually
     supports it. An empty `backed_by:` is a valid and useful answer.
   - **Never upgrade evidence.** "I helped with the migration" is
     `self-reported` help, not leading it. "I think I'm good at X" is
     `self-assessment` no matter how certain they sound. "We cut it roughly
     in half" is a self-reported approximation, not a `documented` 50%.
     Promotion to `documented` requires a source file, never a confident
     tone.
   - Record a number only as the person gave it. If they say they do not
     know, log the achievement with no `metric`. An invented number is
     worse than a missing one, and it is the failure mode that gets someone
     caught in an interview.
   - Attach `context.initiative` (`unprompted`, `assigned`, or `inherited`)
     only when the person said which it was. This field is what separates
     someone who was handed a project from someone who started it, so do
     not guess it.
   - Tag new material using tag names already present in `career.yaml`
     rather than near-duplicates.
6. **Link the reflection.** Add an entry to the relevant experience's
   `reflections:` list with `path` (relative to `02_career-db/`), `captured`
   (today), and a one-line `summary`. If a ramble covers several jobs, link
   it from each experience it substantively covers, not from all of them.
7. **Read back only the extracted facts.** Show the user the achievements,
   metrics, and context you wrote as fact, and ask if you got it right. Do
   not read back the reflection file, do not read back the
   `self_assessment` entries as if they need approving as claims, and do
   not paste the YAML. Correct whatever they push back on before writing.
8. **Regenerate `skills:` if any tags changed.** Rebuild the whole section
   from current tags across experiences, projects, and achievements, never
   incrementally: `first_used` and `last_used` from the date range of
   entries carrying the tag, `evidence_count` from how many entries carry
   it, `confidence` as high (5+ entries or used in the last 2 years),
   medium (2-4, or used 3-5 years ago), low (1 entry, or not used in 5+
   years). If no tags changed, leave the section alone.
9. **Update `meta`.** Set `meta.last_enriched` to today. Rewrite
   `meta.enrichment_gaps` to reflect what is still thin after this session,
   including anything this session opened up but did not finish. Remove
   gaps this session closed. The list is what stops the next session from
   asking at random, so write it as specific pointers
   (`"exp-fernhill-2018 has no metrics and no reflection"`), not as themes.
10. **Write a session report** to
    `<data_dir>/02_career-db/output/<YYYY-MM-DD>-enrich.md`: the assessment
    from step 1, which area you targeted, the questions you asked, what got
    written where (achievements added, context blocks filled, reflections
    created with their paths, self-assessment entries added), and the
    updated gap list. If the same file already exists from an earlier
    session today, append a new section rather than overwriting it.
11. **Report to the user in a few lines**, matching the written report:
    what the record gained, what is still thin, and the report path. If the
    record is now rich enough that a tailored resume would read like a
    person, say so. If it is still thin, say what one more session on which
    role would fix.

## Don't

- Don't run twenty questions in a row. Three to five, then write, then
  stop. The answers after the first ten minutes get worse, and an
  unfinished interview with everything captured beats a complete one you
  never wrote down.
- Don't ask generic questions. "Tell me about your time at Acme" when the
  record already holds three Acme bullets tells the person you did not read
  their file, and you get back the same bullets reworded.
- Don't suggest answers to fill a silence. A leading question gets you a
  yes and teaches you nothing.
- Don't rewrite a ramble into your own voice before saving it. You are
  keeping their account, not producing a draft.
- Don't move anything up the evidence ladder. No `self-assessment` becomes
  `self-reported` because it was stated firmly, and no `self-reported`
  becomes `documented` because it was stated precisely.
- Don't invent a number, round one up, or turn "a lot faster" into a
  percentage.
- Don't skip the `working_on` and "what are you not good at" territory
  because it feels awkward. A record listing only strengths cannot warn
  someone off a bad-fit role, and `career-target` needs the honest gaps to
  give advice worth having.
- Don't write multi-paragraph prose into `career.yaml`. Long-form goes to a
  markdown reflection and gets referenced by path.
