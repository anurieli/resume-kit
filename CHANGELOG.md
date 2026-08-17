# Changelog

## 2026-08-17 13:45 - Reframed from resume generator to career folder: schema v2, interview loop, and a coaching layer
The tool treated ingestion as the main event, which capped it at reformatting whatever
a previous resume already said. Reframed around the durable asset: a career record that
grows over years through conversation, with a resume as one rendered view of it.

Schema v2 adds an `evidence_type` on every claim (`documented`, `self-reported`,
`self-assessment`, `derived`) with a rule that evidence is never promoted without a new
source document. This is the integrity mechanism: a metric from a performance review and
"I'm good at stakeholder management" are different kinds of data, and only the first two
tiers may ever be printed on a resume. Self-assessment shapes emphasis and wording but
is never stated as a claim about the person. Also added per-role `context` (scope, team
size, whether the work was unprompted) and `reflections` pointing at markdown files,
since multi-paragraph prose in YAML is unreadable and unedittable.

Two new skills. `career-enrich` is the interview loop: it reads the record, reports
honestly which roles are thin, asks three to five targeted questions from a new
interview bank, captures free-form rambles as markdown reflections in the person's own
words, and extracts structured data back with correct evidence types. `career-target` is
the coach: it positions the person for a specific role, gives a plain gap analysis that
distinguishes hard gaps from soft ones, writes concrete tips with a named action and a
linkable artifact rather than advice like "learn Kubernetes", and returns a real
apply-or-not recommendation. It also reads every past brief in `03_target/output/`, so a
requirement that keeps recurring across applications gets named as a ceiling instead of
a one-off miss. It requires 3 past targets before claiming a pattern.

`resume-ingest` became `career-ingest` (it takes performance reviews, offer letters, and
LinkedIn exports, not just resumes), now classifies and reports skipped files by name
rather than silently swallowing the junk users drop in, and never deletes an original.
Deliverable folders gained a date prefix. Also fixed em dashes that were rendering onto
the resume itself: the title/company separator is now a middot matching the contact
line, and dates print human-readably ("Mar 2021 to present") instead of in career.yaml's
storage format. Verified: fresh scaffold produces the v2 starter with self_assessment and
a reflections shelf, the config guard still holds, end-to-end render is clean at one page,
and no file references the old flat paths or undated deliverable folders.
Files: schema/career-schema.md, schema/interview-bank.md, skills/career-enrich/SKILL.md,
skills/career-target/SKILL.md, skills/career-ingest/SKILL.md, skills/resume-build/SKILL.md,
skills/resume-kit-init/SKILL.md, skills/resume-kit-init/scripts/init.sh, README.md,
templates/resume-template.html, templates/README.md, examples/career.example.yaml,
examples/sample-ramble.md.

## 2026-08-17 12:52 - Data directory restructured as an ICM workspace, plus a config-clobbering fix
The data directory was a flat folder (career.yaml, inbox/, output/), which meant the
only way to use the tool was to name a skill: an agent landing in the folder cold had
nothing telling it what to do. Restructured it into an ICM (Interpretable Context
Methodology) workspace: IDENTITY.md and a routing CONTEXT.md at the root, `_config/`
for stable reference, and four numbered stages (01_intake, 02_career-db, 03_target,
04_deliverable) each carrying a CONTEXT.md contract. That adds a second activation
path: drop a file into a stage folder and any agent can read the contract and continue,
no skill call and no memory of prior sessions needed. The three skills stay as the
explicit-call path and now reference the stage paths; init.sh scaffolds the whole
structure so the public repo ships it.

Fixed a footgun found while testing: init.sh unconditionally rewrote
~/.config/resume-kit/config.yaml, so running it against a second directory silently
repointed the tool away from a user's real career data. The "ask first" guard existed
only in the skill's prose, not the script. It now refuses to repoint an existing config
at a different directory unless RESUME_KIT_FORCE_CONFIG=1, while still scaffolding the
requested workspace. Verified: fresh scaffold produces 8 files, re-runs preserve a
filled career.yaml and hand-edited contracts, the config guard holds in both directions,
and every path referenced by a contract or skill exists.
Files: skills/resume-kit-init/scripts/init.sh, skills/resume-kit-init/SKILL.md,
skills/resume-ingest/SKILL.md, skills/resume-build/SKILL.md, schema/career-schema.md,
README.md.

## 2026-08-17 12:38 - The format is now an editable template, not a thing the model redraws (57aa365)
resume-build was told to use the template as a "structural/style reference," which meant
it regenerated CSS from scratch each run and formatting could drift between resumes.
Extracted the CSS into templates/theme.css as the single source of truth, moved templates/
to the repo root where it is discoverable, and changed the skill's contract to require
inlining theme.css verbatim with an explicit ban on per-job restyling. Added
templates/README.md documenting which file to edit for which change. Verified by
rendering through the new path and diffing extracted text against the original: identical.
Files: templates/theme.css, templates/resume-template.html, templates/README.md,
skills/resume-build/SKILL.md.

## 2026-08-17 12:24 - render-pdf.sh no longer hangs after a successful render (dbfca39)
Headless Chrome (`--headless=new`) writes the PDF correctly but does not reliably exit
the process afterward on macOS, so the original script's `wait`-on-exit approach hung
indefinitely (had to be backgrounded past a 120s tool timeout during testing, even
though the PDF was already written within a few seconds). Rewrote it to run Chrome in
the background, poll the output file until its size stabilizes, then kill the Chrome
process and its user-data-dir directly instead of waiting on exit. Verified with a
full render of the example career data: 1-page PDF in ~4s, clean exit code 0, no
leftover Chrome processes. Files: skills/resume-build/scripts/render-pdf.sh.

## 2026-08-17 12:19 - Initial resume-kit: schema, init/ingest/build skills, PDF template (cc409ef)
Built resume-kit from scratch: a portable career database (career.yaml) plus three
Claude Code skills (resume-kit-init, resume-ingest, resume-build) that scaffold a
private data directory, absorb raw material (old resumes, LinkedIn exports, cover
letters) into the database with provenance tracking and dedup, and render a tailored
resume PDF from a job posting via headless Chrome. Public tool repo is deliberately
separate from any personal data; a config file at ~/.config/resume-kit/config.yaml
points at wherever the user's private data directory lives. Includes a fictional
example dataset (Jordan Rivera) and sample job posting for demoing without real
personal data. Files: README.md, LICENSE, schema/career-schema.md,
skills/resume-kit-init/SKILL.md, skills/resume-kit-init/scripts/init.sh,
skills/resume-ingest/SKILL.md, skills/resume-build/SKILL.md,
skills/resume-build/scripts/render-pdf.sh,
skills/resume-build/templates/resume-template.html,
examples/career.example.yaml, examples/sample-job-posting.txt.
