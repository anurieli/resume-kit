# resume-kit

**A career kit. An AI that remembers your career and handles your applications
for you.**

Drop in a link to a job you are considering. It goes through everything you
have ever done, pulls out the parts that actually matter for that role,
assembles them into a resume aimed at it, researches the company so the cover
letter is written for them rather than at them, and hands you a list of
things you could go do to make yourself a stronger candidate.

Then it tells you, honestly, whether you should apply at all. Sometimes the
answer is no.

---

**Why it works this way: your career keeps growing and your resume keeps
shrinking.**

Every year you pick up skills, finish projects, fix things nobody else wanted
to touch, build something on the side. All of it is you. None of it is written
down anywhere except in one document you rewrite from scratch every time you
apply somewhere, by opening the last version and cutting whatever does not fit
the new job.

So the pile grows and the document shrinks, and you end up staring at last
year's resume trying to remember what the most important thing about you is
supposed to be.

This fixes the order. You keep the record, and the record keeps growing. The
resume is generated out of it in about a minute, aimed at one job, and you
never rewrite anything by hand again.

Runs inside Claude Code, or any AI assistant that can read a folder. You do
not need to know how to code.

---

## Start here: copy this and give it to Claude

Open Claude Code and paste this in. That is the whole setup.

```
I want to set up resume-kit, a tool that keeps a record of my career and
writes tailored resumes from it. Please do this end to end and ask me
whenever you need a decision from me.

1. Clone https://github.com/anurieli/resume-kit into ~/code/resume-kit.
   Create the folder if it does not exist.
2. Make its skills available to you: create ~/.claude/skills/ if it does not
   exist, then symlink each folder inside ~/code/resume-kit/skills/ into it.
3. Ask me where my private career record should live. If I have no
   preference, suggest ~/resume-kit-data. It must NOT be inside the cloned
   repo, because that repo is public and my record is not.
4. Run: ~/code/resume-kit/skills/resume-kit-init/scripts/init.sh "<the
   folder I picked>"
5. Tell me in plain language what was created and where, then ask me whether
   I have any old resumes, performance reviews, or a LinkedIn export lying
   around, and tell me what to do next based on my answer.

Then stop and wait for me.
```

That is it. Nothing to install, nothing to configure, no account.

## Then just talk to it

Four things to say, in this order. Say them in your own words, these are not
commands.

**"Here are my old documents, ingest them."** Put whatever you have into the
`01_intake` folder first. Old resumes, cover letters, your LinkedIn data
export, and above all any performance reviews. Reviews are the single most
valuable thing on that list, because they are full of numbers about you that
somebody else wrote down and you have since forgotten.

**"Interview me."** It looks at your record, finds the thin parts, and asks
you a few questions. Ten honest minutes beats an hour of filling in forms. Do
this every couple of months, not all at once. This is the step that makes the
whole thing worth having.

**"Here's a job I'm looking at. Should I apply?"** Give it the link, or paste
the posting. Before it answers, it sends a researcher off to read up on the
company: what they actually do, how they make money, what they say they
value, how they talk, and what has happened there lately. Every fact it
brings back carries the link it came from.

Then you get how you read to a screener, what to lead with, what is honestly
missing, what you could do about it, and a straight answer. Sometimes the
answer is no.

It also asks you a few things it cannot look up. Whether you know anybody
there. Whether the way they say they work is a way you want to work. Whether
a value they list is one you could speak to honestly. Those answers make the
cover letter, and they get filed, so the next application inherits them.

**"Build it."** You get a resume, and a cover letter if the application takes
one, written for that specific job, as a PDF, in a dated folder with the
posting saved next to it.

## What it will not do

It will not lie for you.

Every fact it stores is tagged with where it came from: a document you gave
it, something you told it, or your own opinion of yourself. Your opinions
change what gets chosen and how it gets worded. They never get printed as
though they were verified facts. If a job wants something you do not have, it
says so instead of quietly inflating a bullet to cover the hole.

That is not politeness. An inflated bullet survives the screen and then dies
in the interview, out loud, in front of a person.

## What it notices that you cannot

It keeps every posting you have ever pointed it at. After a handful of
applications it can tell you something like: four of your last five targets
wanted the same thing you do not have.

You experience applications one at a time, weeks apart, each ending in
silence. So every rejection reads as its own small event. Read across them
instead and a repeated gap stops being a gap and becomes a ceiling, which is
the only version of that information you can actually act on.

## Your record is yours, and it stays private

**Nothing personal ever goes in this repo.** This repo is the tool, and it is
public on purpose. Your history goes in a separate folder you pick: a private
notes vault, a private repo, anywhere. Fork this, publish it, nothing of
yours comes along.

Every file in your folder is plain text. Open it, read it, correct it by
hand. Nothing is locked inside a database or an app, and if you put your
folder under git you get a full history of your own career record.

---

## A walkthrough, start to finish

There's a fictional person in `examples/` (Jordan Rivera, backend engineer)
so you can see the shape of every artifact before you put your own life in
one. Here's the whole loop.

**1. Bootstrap from what you already have.**

> **You:** *drops three old resumes and a 2023 performance review into
> `01_intake/`* "Ingest these."
>
> **It:** Read 4 files. Found 2 roles, 9 achievements, 1 degree. The same
> Northwind role appeared in all three resumes with different wording, kept
> the longest version. Two achievements carry numbers, both from the
> performance review, both marked `documented`. The Fernhill role has no
> context and no numbers. Archived all 4 originals to
> `01_intake/output/processed/`. This record is thin on purpose. Run
> `career-enrich` next.

Every claim it wrote looks like this in `career.yaml`:

```yaml
- text: "Led migration of the billing reconciliation pipeline to an
    event-driven architecture, cutting reconciliation errors 40% and
    processing time from 6 hours to 20 minutes."
  tags: [python, distributed-systems, kafka]
  evidence_type: documented
  source: "2023-perf-review.pdf, p2"
```

`evidence_type` is the whole point. `documented` came from a file.
`self-reported` is something you told it. `self-assessment` is your opinion
of yourself, and it never gets printed as a fact about you.

**2. Talk to it, occasionally.**

> **You:** "Interview me."
>
> **It:** Your Fernhill role is two bullets with no numbers, and it's the
> one a platform job would care about. Three questions. What was the team
> size and who did you report to? What broke most often? Was there anything
> you started that nobody asked you to start?

Ramble for four minutes and it saves the whole account in your own words to
`02_career-db/self/reflections/`, then files the extractable facts into
`career.yaml` with a link back to the reflection. See
`examples/sample-ramble.md` for what one looks like: why the project
existed, who fought it, what was actually hard. None of that fits on a
resume and all of it decides how the resume gets written.

**3. Point it at a job.**

> **You:** *pastes the Delta Freight posting* "Should I apply?"
>
> **It:** Apply. Strong match, one real gap.
>
> Lead with the Northwind billing migration. They want Kafka, measurable
> reliability work, and mentoring, and you have documented numbers for the
> first two. Your 40% error reduction is the strongest single line you own.
>
> The gap is on-call. They want someone who has established on-call
> practice, and your record has you inside a rotation, not designing one.
> Don't claim it. Say what you did build: the runbook that didn't exist.
>
> Kubernetes came up again. That's four of your last five targets. This is
> not a one-off gap anymore, it's your ceiling on this class of role.

**4. Get the documents.**

> **You:** "Build it."

You get `04_deliverable/output/2026-08-18-delta-freight/` holding the
resume as a PDF named the way the employer will see it, the HTML it
rendered from, the posting, the positioning read, and a submission kit
telling you what to upload. If the application takes a cover letter or has
mandatory essay fields, those land in the same folder. Sent applications
freeze, so a year from now you can still answer "what exactly did I tell
them?"

## What's in `examples/`

| File | What it shows |
|---|---|
| `career.example.yaml` | A full record after one ingest and two interviews: mixed evidence types, a role that's still thin and flagged for it, derived skills, and the self-assessment block that never gets printed |
| `sample-ramble.md` | A captured reflection, in the person's own words, with a note on which parts became facts and which didn't |
| `sample-job-posting.txt` | The posting used in step 3 above, so you can run the targeting step end to end |

Copy the shape, not the content.

## Two ways to run it

**Say what you want.** "Ingest these." "Interview me." "Should I apply to
this?" "Build me a resume."

**Or just drop a file in a folder.** Every stage folder carries a
`CONTEXT.md` explaining what that stage does. Drop a posting into
`03_target/`, open the folder in a fresh chat, and say "continue." It works
with no memory of any earlier conversation and no skills installed, which is
why this also works outside Claude Code.

## What's in your folder

```
01_intake/        drop your documents here
02_career-db/
  career.yaml     your history. The part worth keeping.
  self/           your reflections and your life log
03_target/        postings you've considered
04_deliverable/   generated resumes, one dated folder per application
_config/          the schema, the interview questions, your resume's format
```

`career.yaml`, your reflections, and your life log are the asset. Everything
under an `output/` folder can be regenerated and thrown away.

## Changing how your resume looks

Edit `_config/theme.css` inside **your** folder, not this repo. Fonts, sizes,
spacing, margins, colors. Change it once and every future resume follows. The
copies here are only what a new workspace starts from.

## Requirements

- Claude Code, or another AI assistant that can read and write a folder.
- Google Chrome, to turn the resume into a PDF (falls back to
  `wkhtmltopdf`). Without either you still get a print-ready HTML file that
  saves to PDF from your browser in two keystrokes.
- `pandoc`, only if you want to feed it `.docx` files.

## The design, briefly

Your folder is an ICM workspace (Interpretable Context Methodology): numbered
stage folders where the filesystem is the runtime, each stage owning one job
and carrying a contract stating its inputs, process, outputs, and
checkpoints. Two things follow. Every intermediate is a file you can inspect
and correct before the next stage runs, so you're never handed a resume built
on a merge you never saw. And any agent can pick up the work by reading the
contract, with no memory and no installed skills.

The five skills: `resume-kit-init` (setup, run once), `career-ingest`
(bootstrap from documents), `career-enrich` (the interview loop),
`career-target` (positioning and gaps), `resume-build` (render the PDF).

**For AI agents:** read `CLAUDE.md` here, and the `CLAUDE.md` inside any
workspace. This README is written for humans.

## License

MIT. Fork it, rename it, make it yours.
