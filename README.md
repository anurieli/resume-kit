# resume-kit

**Stop rebuilding your resume from scratch every time you apply somewhere.**

This is a folder that remembers your career. You feed it the resumes you
already have, it asks you questions over time, and when a job comes up it
writes you a tailored resume in about a minute. It also tells you, honestly,
whether you should bother applying.

Runs inside Claude Code, or any AI assistant that can read a folder.

---

## What it does for you

**It remembers, so you don't have to.** Most people rebuild their history
from whatever old resume they can find, which makes every version a copy of a
copy. Here your history lives in one file that only gets more complete. The
resume is generated from it, so the resume is never the thing you maintain.

**It asks you good questions.** What makes a resume land is almost never
written down anywhere: the scope of what you owned, the number you moved, the
thing you started that nobody asked you to start. So it interviews you, a few
questions at a time, and files what you say. You can also just talk at it
about a job and let it sort out what matters.

**It won't lie for you.** Every fact it stores is tagged with where it came
from: a document, something you told it, or your own opinion of yourself.
Your opinions shape how things get worded, but they never get printed as
though they were verified facts. If a job wants something you don't have, it
says so instead of quietly inflating a bullet.

**It tells you where you stand.** Paste a posting and you get a read on how
you'd look to a screener, which experience to lead with, what's missing,
specific things you could do about it, and a straight answer on whether to
apply. Sometimes the answer is no.

**It notices patterns you can't.** It keeps every posting you've pointed it
at. After a handful of applications it can tell you something like "four of
your last five targets wanted Kubernetes, that's not a one-off gap, that's
your ceiling." No single application shows you that.

**It checks in on you.** If it's been a couple of months, it asks what you've
been up to before doing anything else, and files the answer. That's what
keeps the record from quietly going stale while you're busy actually working.

**Every resume looks the same.** Same fonts, spacing, and layout, every time.
Only the content changes. The format is one CSS file you can edit, so if you
want a different look, change it once and everything after follows.

---

## Getting set up

1. Clone this repo somewhere.
2. Point your AI assistant's skills at the folders under `skills/`.
3. Say "set up resume-kit." It asks where your private career data should
   live and builds the folder.

**Your data never lives in this repo.** This repo is the tool and it's meant
to be public. Your history goes in a separate folder you pick: a private
notes vault, a private repo, anywhere. Fork this and publish it and nothing
personal comes along.

---

## Using it

**First, feed it what you have.** Drop old resumes, your LinkedIn data
export, cover letters, and especially old performance reviews into
`01_intake/`. Any format. Then say "ingest these." Performance reviews are
the most valuable thing in that list, because they're full of numbers you've
forgotten you earned.

It dedupes the same job showing up across three old resumes, tells you which
files it skipped and why, and never deletes an original.

**Then talk to it now and then.** Say "interview me." It tells you which
parts of your record are thin and asks a few questions. Do this occasionally
rather than all at once. Ten honest minutes beats an hour of form-filling.

**Then, when a job comes up.** Paste the posting and ask what it thinks. If
you want the document, say "build the resume." You get a PDF in a dated
folder with the posting saved next to it, so in three months you'll still
know exactly what you sent and what they asked for.

---

## Two ways to run it

**Say what you want.** "Ingest these." "Interview me." "Should I apply to
this?" "Build me a resume."

**Or just drop a file in a folder.** Every stage folder carries a
`CONTEXT.md` explaining what that stage does. Drop a posting into
`03_target/`, open the folder in a fresh chat, and say "continue." It works
with no memory of any earlier conversation and no skills installed, which is
why this also works outside Claude Code.

---

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

Every one of those is a plain text file. Open any of it, read it, correct it
by hand. Nothing is locked inside a database, and if your folder is under
git, you get a full history of your own career record.

`career.yaml`, your reflections, and your life log are the asset. Everything
under an `output/` folder can be regenerated and thrown away.

---

## Changing how your resume looks

Edit `_config/theme.css` inside **your** folder, not this repo. Fonts, sizes,
spacing, margins, colors. Change it once and every future resume follows. The
copies here are only what a new workspace starts from.

---

## Requirements

- Claude Code, or another AI assistant that can read and write a folder.
- Google Chrome, to turn the resume into a PDF (falls back to
  `wkhtmltopdf`). Without either you still get a print-ready HTML file that
  saves to PDF from your browser in two keystrokes.
- `pandoc`, only if you want to feed it `.docx` files.

---

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
