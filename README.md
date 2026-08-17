# resume-kit

A career folder that produces resumes.

The durable thing here is the record of your working life: every job, what
you actually did there, what you are good at, tracked in one YAML file plus
a shelf of markdown reflections. A resume is one view of that record,
rendered for one company. Five Claude Code skills keep the record growing
and turn it into tailored, consistently formatted PDFs on demand.

The record is meant to last years. Most of what makes it valuable never
appeared on any resume you have written: why a project mattered, what was
broken when you arrived, what you started that nobody asked for, what you
are genuinely not good at. Documents do not hold that. Conversation does,
which is why the interview loop is the main event and ingestion is just the
bootstrap.

## How it's split

- **This repo (public):** the skills, the schema, the PDF template. No
  personal data. Safe to share, fork, or publish.
- **Your data (private, not in this repo):** a separate folder holding your
  career record, the raw material you feed it, and the resumes it produces.
  You choose where it lives: a private notes vault, a private repo,
  anywhere. resume-kit points at it via a small config file and never
  hardcodes it.

## The data directory is a pipeline

Your data directory is not a flat folder. It is an ICM workspace
(Interpretable Context Methodology): numbered stage folders where the
filesystem is the runtime. Each stage owns one job, carries a `CONTEXT.md`
contract stating its inputs, process, outputs, and checkpoints, and writes
its results into its own `output/`.

```
<your-data-dir>/
├── IDENTITY.md          what this workspace is
├── CONTEXT.md           routing: what you have -> which stage -> what you get
├── _config/             stable reference: schema rules, output format
│   ├── schema.md
│   └── format.md
├── 01_intake/           drop old resumes, LinkedIn export, performance reviews here
│   └── output/processed/    consumed originals, archived by filename
├── 02_career-db/
│   ├── career.yaml          the structured spine, grows over years
│   ├── self/reflections/    long-form rambles, referenced from career.yaml
│   └── output/              ingest and enrich reports
├── 03_target/
│   └── output/<slug>/       posting.md + brief.md
└── 04_deliverable/
    └── output/<YYYY-MM-DD>-<slug>/
                             positioning.md + resume.html + resume.pdf
```

Two things follow from this. Every intermediate is a file you can open,
read, and correct before the next stage runs, so you are never handed a
resume built on a merge you never saw. And if your data directory is under
git, `git log` is the audit trail of your own career record.

The `04_deliverable` folders carry a date prefix, so applying to the same
company twice leaves two folders instead of overwriting what you sent last
time.

## The skills

- **`resume-kit-init`** scaffolds the workspace and writes the config. Run
  once.
- **`career-ingest`** reads documents you already have into `career.yaml`:
  old resumes, LinkedIn exports, performance reviews, offer letters. It
  classifies everything in the intake folder, names what it skipped instead
  of silently dropping it, archives the originals, and tells you how thin
  the resulting record is.
- **`career-enrich`** is the interview loop. It finds the thinnest part of
  your record, asks three to five real questions, lets you ramble, saves
  the ramble in your own words as a markdown reflection, and extracts the
  facts back into `career.yaml` with the right evidence type. Run it
  repeatedly over months.
- **`career-target`** is the coach. Give it a posting and it tells you how
  you read for that role, which evidence to lead with, what is genuinely
  missing, concrete things you could do to close each gap, and whether to
  apply at all. Across several targets it also spots the requirement that
  keeps coming up, which is usually the ceiling on the roles you are drawn
  to rather than a one-off miss.
- **`resume-build`** renders the selected material into the fixed format
  and a PDF.

## Two ways to use it

**Call a skill.** The explicit path: name the skill you want.

**Or drop a file into a stage folder** and ask an agent to continue. It
reads that stage's `CONTEXT.md` and follows the contract. Put an old resume
in `01_intake/` and say "process this." Put a job posting in `03_target/`
and say "should I apply?" No skill name needed.

Both paths run the same contracts. The skills are the entry point most
people will use; the contracts are what actually governs.

## The loop

1. **Ingest, to bootstrap.** Drop material into
   `<your-data-dir>/01_intake/`: old resumes (PDF, DOCX, TXT, MD), your
   LinkedIn "Download your data" export, performance reviews, offer
   letters, cover letters, old postings you applied to. Run `career-ingest`.
   Performance reviews are worth digging out. They contain numbers you have
   forgotten and a manager's account of your scope that you would never
   claim about yourself.

   This gets you a skeleton: titles, dates, and whatever bullets survived
   your last resume rewrite. The skill will tell you how thin it is. That
   is the expected outcome, not a failure.

2. **Enrich, over time.** Run `career-enrich`. It reads the record, picks
   the weakest spot, and asks about it. Answer in whatever form is
   comfortable, including talking at length. Rambles get saved as
   reflections and mined for facts. Ten minutes here beats an hour of
   editing a resume, and it compounds: every session makes every future
   resume better. This never really finishes, and it is not supposed to.

3. **Target a role.** Run `career-target` with a posting. You get
   positioning, an honest gap list, specific tips, and a real
   recommendation. Deciding not to apply is a legitimate output, and one of
   the more useful ones.

4. **Build the resume.** Run `resume-build`. It reads the positioning brief,
   selects the relevant experience, and renders the PDF.

Repeat 3 and 4 per application. Repeat 2 whenever you have ten minutes.
Repeat 1 whenever new documents show up.

## The rule that keeps it honest

Every claim in `career.yaml` carries an `evidence_type`, and it decides what
is allowed onto a page:

| Type | Came from | On a resume? |
|---|---|---|
| `documented` | old resume, LinkedIn, performance review, offer letter | Yes |
| `self-reported` | a ramble or an interview answer | Yes, as experience. Never as a verified metric. |
| `self-assessment` | your own opinion of yourself | No. It shapes emphasis and wording only. |
| `derived` | computed by the tool | Internal only. |

A number from a performance review and "I'm good at stakeholder management"
are different kinds of data. Keeping them separate is what stops the record
drifting into things you cannot defend in an interview. Nothing may be
promoted up this ladder: stating something confidently does not make it
documented. Promotion requires a source document.

That last category is doing real work. Your opinion of yourself is
genuinely useful, it just belongs in choosing which experience to lead with,
not in a bullet claiming it as fact.

## Why a record instead of just editing a resume file

- **One source of truth.** Your history stops living fragmented across five
  differently-worded old resumes.
- **Provenance.** Every claim traces back to where it came from and how
  strongly it is evidenced. No drifting claims that got embellished three
  resumes ago and nobody remembers if they are still true.
- **It captures what a resume cannot hold.** Scope, initiative, what was
  broken when you got there, what you are working on. This is what makes a
  tailored resume read like a person instead of a job description, and it
  is what the coach needs to give advice worth having.
- **A skills picture that builds itself.** Tags roll up into a derived
  skills section: what you have actually used, how much evidence backs it,
  how recently, instead of a hand-maintained list that goes stale.
- **Consistent output, tailored content.** The format never changes between
  applications; only the selected content does.

## Setup

1. Clone this repo somewhere on your machine.
2. In Claude Code, symlink (or point your skills config at) the five skill
   folders under `skills/`:
   - `resume-kit-init`
   - `career-ingest`
   - `career-enrich`
   - `career-target`
   - `resume-build`
3. Ask Claude to run `resume-kit-init`. Tell it where your private data
   folder should live (anywhere outside this repo). It scaffolds the full
   workspace above and writes `~/.config/resume-kit/config.yaml` pointing at
   it.

The scaffold script is idempotent: it never overwrites an existing file, so
re-running it is safe and your edits to a contract survive. To regenerate a
contract from the current template, delete that file and run it again. If a
config already exists pointing somewhere else, the script scaffolds the new
workspace but refuses to repoint the config unless you re-run with
`RESUME_KIT_FORCE_CONFIG=1`, so an existing career record cannot be
stranded by accident.

If your data directory lives inside an Obsidian vault, set
`RESUME_KIT_VAULT_BREADCRUMB` to the parent index wikilink when you run the
script, and `IDENTITY.md` is written with vault frontmatter and a breadcrumb.

No documents to ingest? Skip step 1 of the loop entirely and start with
`career-enrich`. The record can be built by conversation alone; it just
takes a few sessions.

## Schema

See `schema/career-schema.md` for the full shape of `career.yaml` and the
rules any skill must follow when writing to it. `schema/interview-bank.md`
holds the questions `career-enrich` draws from, which is worth reading on
its own if you have ever struggled to describe your own work. Your workspace
carries a short pointer to both at `_config/schema.md`.

`examples/career.example.yaml` is a filled-in record for a fictional person,
and `examples/sample-ramble.md` shows the kind of raw input `career-enrich`
captures.

## Format

See `templates/README.md`. `templates/theme.css` is the format, and it is
meant to be edited: change it once and every future resume follows.
`resume-build` inlines it verbatim into each output and is forbidden from
restyling an individual resume, which is what keeps output consistent across
applications instead of drifting a little each time.

## Requirements

- Claude Code.
- Google Chrome (for PDF rendering via headless mode), falling back to
  `wkhtmltopdf` if Chrome isn't found. PDF rendering needs shell access; a
  surface without one can still produce `resume.html`.
- `pandoc`, if you want to ingest `.docx` files (optional; PDF, TXT, and MD
  work without it).

## License

MIT. Fork it, rename it, point it at your own data. See `LICENSE`.
