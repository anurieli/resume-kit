# Changelog

## 2026-08-18 14:32 - Sent resumes are frozen, the newest one is CURRENT-RESUME (8fb7145)
Every build landed in a dated folder and stopped there, so "give me my resume" meant knowing
which folder was newest, and nothing stopped an agent from re-rendering a resume that had
already gone out. Added step 10 to resume-build and to the 04_deliverable contract generated
by init.sh: copy the finished PDF and HTML to `<data_dir>/CURRENT-RESUME.pdf` and `.html`, and
add a row to the archive ledger at `04_deliverable/output/index.md`. Copies rather than
symlinks, so the file survives being emailed or moved. A build that has been sent is frozen:
it is the record of what that company actually received, and it is the only way to answer
"what did I tell them?" later. A newer finalized build becomes current; the old one keeps its
folder and its row, so archiving is just no longer being the newest row. Skill and generated
contract changed in the same commit, per the parity rule.
Files: skills/resume-build/SKILL.md, skills/resume-kit-init/scripts/init.sh, CHANGELOG.md.

## 2026-08-17 16:05 - A person's field conventions can now shape output (8c45db0)
resume-build could only rank skills by tag relevance and confidence, so it rendered a flat
comma-separated list of tool names. That is the weakest version of the section, and in some
fields a programming-language list actively reads as dated, but the record had nowhere to
carry that judgment. Added an optional `meta.presentation_preferences` list: framing and
ordering only, so it can never promote a skill that no role or project carries, and never
suppress something a posting explicitly requires. That conflict gets named to the user
instead of resolved silently. Preferences are recorded only when the person states one,
never inferred. Documented in the schema, honored in resume-build, and mirrored into the
04_deliverable contract inside init.sh so the skill and the contract cannot drift.
Files: schema/career-schema.md, skills/resume-build/SKILL.md, skills/resume-kit-init/scripts/init.sh.

## 2026-08-17 14:22 - Life-update log, and docs split into human-facing and agent-facing
A career record goes stale quietly: someone changes roles or ships something big and none
of it reaches career.yaml because nobody sat down to do an interview. Added a life log at
`02_career-db/self/life-log.md` that answers one recurring question, "What are you up to
right now, or what have you been up to?", as dated entries in the person's own words. All
four working skills now check it before doing anything else: under two months old they say
nothing, at two months or older (or empty) they ask the question first, write the answer,
and file what it contains by evidence type. One question, not an interview; if the answer
opens up more, the skill points at career-enrich rather than expanding the check-in.

Split the documentation by audience. README.md is now written for humans and leads with
what the tool does for you rather than how it is built, with the architecture condensed
into one section at the bottom. Two CLAUDE.md files carry the agent-facing rules: one at
the repo root for agents working on the tool (templates are seeds not live format, skills
and contracts must never disagree, the evidence model and why not to weaken it), and one
seeded into every workspace so an agent that opens a career folder gets the read order,
the life-log check, and the eight standing rules without being told. That second one
matters most on surfaces where the skills are not installed, since CLAUDE.md auto-loads
from a working directory. Verified a fresh scaffold now produces both the life log and the
workspace CLAUDE.md.
Files: templates/life-log.md, templates/workspace-CLAUDE.md, CLAUDE.md, README.md,
skills/resume-kit-init/scripts/init.sh, skills/career-ingest/SKILL.md,
skills/career-enrich/SKILL.md, skills/career-target/SKILL.md, skills/resume-build/SKILL.md.

## 2026-08-17 13:58 - Workspace is now self-contained, so it works on surfaces that cannot reach the repo
The workspace pointed at `~/Desktop/resume-kit` by absolute path for `theme.css`,
`resume-template.html`, and `interview-bank.md`. Opening the data folder on a surface
that can only see that folder (Claude Desktop, a synced folder on another machine) meant
an unstyled resume and an interview with no question bank. It also contradicted the
original intent that the format be editable inside the folder structure.

`resume-kit-init` now seeds copies of the theme, the template, the interview bank, and
the full schema into the workspace's `_config/`, and the workspace copy is authoritative
from then on. The repo versions are what a NEW workspace starts from; editing them does
not change an existing workspace, and two people can run the same tool with different
formats. All five skills and every stage contract now read the workspace copies rather
than repo paths. The one remaining outward reference is `render-pdf.sh`, which genuinely
needs a shell; the deliverable contract now says a shell-less surface should stop at the
print-ready `resume.html` and have the user print to PDF from a browser, and must not
report the deliverable complete until a PDF exists either way.

Verified by scaffolding a fresh workspace and confirming it carries everything needed to
produce a formatted resume with no path back to the repo: theme present, template
placeholders intact, 19 interview questions, evidence table in the schema copy.
Files: skills/resume-kit-init/scripts/init.sh, skills/resume-build/SKILL.md,
skills/career-enrich/SKILL.md, skills/career-target/SKILL.md, skills/career-ingest/SKILL.md,
templates/README.md.

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
