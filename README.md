# resume-kit

A career database in one YAML file, plus three Claude Code skills that keep
it filled in and turn it into consistently formatted, tailored resumes on
demand.

The idea: stop rebuilding your resume from scratch (or from whatever old
copy you can find) every time you apply somewhere. Feed this tool your old
resumes, LinkedIn export, and cover letters once. It builds a structured
record of your career: every job, every achievement, tagged and sourced.
From then on, paste a job posting and get a tailored, well-formatted PDF in
one pass, pulling only what's actually relevant from your real history.

## How it's split

- **This repo (public):** the skills, the schema, the PDF template. No
  personal data. Safe to share, fork, or publish.
- **Your data (private, not in this repo):** a separate folder holding your
  actual career database, the raw material you feed it, and the resumes it
  produces. You choose where it lives: a private notes vault, a private
  repo, anywhere. resume-kit points at it via a small config file and never
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
├── 01_intake/           drop old resumes, LinkedIn export, cover letters here
│   └── output/processed/    consumed files land here
├── 02_career-db/
│   ├── career.yaml          THE database, grows over years
│   └── output/              ingestion reports
├── 03_target/           one job posting, captured and briefed
│   └── output/<slug>/       posting.md + brief.md
└── 04_deliverable/
    └── output/<slug>/       resume.html + resume.pdf
```

Two things follow from this. Every intermediate is a file you can open,
read, and correct before the next stage runs, so you are never handed a
resume built on a merge you never saw. And if your data directory is under
git, `git log` is the audit trail of your own career record.

## Two ways to use it

**Call a skill.** The explicit path:

- `resume-ingest` runs `01_intake` into `02_career-db`.
- `resume-build` runs `03_target` into `04_deliverable`.

**Or drop a file into a stage folder** and ask an agent to continue. It
reads that stage's `CONTEXT.md` and follows the contract. Put an old resume
in `01_intake/` and say "process this." Put a job posting in `03_target/`
and say "build it." No skill name needed.

Both paths run the same contracts. The skills are the entry point most
people will use; the contracts are what actually governs.

## Setup

1. Clone this repo somewhere on your machine.
2. In Claude Code, symlink (or point your skills config at) the three
   skill folders under `skills/`:
   - `resume-kit-init`
   - `resume-ingest`
   - `resume-build`
3. Ask Claude to run `resume-kit-init`. Tell it where your private data
   folder should live (anywhere outside this repo). It scaffolds the full
   workspace above and writes `~/.config/resume-kit/config.yaml` pointing at
   it.

The scaffold script is idempotent: it never overwrites an existing file, so
re-running it is safe and your edits to a contract survive. To regenerate a
contract from the current template, delete that file and run it again.

If your data directory lives inside an Obsidian vault, set
`RESUME_KIT_VAULT_BREADCRUMB` to the parent index wikilink when you run the
script, and `IDENTITY.md` is written with vault frontmatter and a breadcrumb.

## Workflow

1. **Drop material into `<your-data-dir>/01_intake/`**: old resumes (PDF,
   DOCX, TXT, MD), your LinkedIn "Download your data" export, cover letters,
   even old job postings you applied to.
2. **Run `resume-ingest`.** It reads everything in the intake folder, merges
   it into `02_career-db/career.yaml` (deduping the same job across multiple
   old resumes, tagging skills, tracking where every fact came from), and
   asks you questions when something's ambiguous instead of guessing.
   Consumed files move to `01_intake/output/processed/`. Re-run it any time
   you have new material.
3. **Run `resume-build`** with a job posting (paste the text, give it a URL,
   or point it at a file). It captures the posting to
   `03_target/output/<slug>/`, selects the relevant experience and skills
   from `career.yaml`, writes the resume, and renders a PDF to
   `04_deliverable/output/<slug>/`.

Repeat step 3 for every application. Repeat step 2 whenever you have new
material: a new job, a role update, another old resume you found.

## Why a YAML database instead of just editing a resume file

- **One source of truth.** Your career history stops living fragmented
  across five differently-worded old resumes.
- **Provenance.** Every fact traces back to where it came from. No drifting
  claims that got embellished three resumes ago and nobody remembers if
  they're still true.
- **A skills picture that builds itself.** Tags on achievements roll up
  into a derived skills section: what you've actually used, how much
  evidence backs it, how recently, instead of a hand-maintained list that
  goes stale.
- **Consistent output, tailored content.** The format never changes
  between applications; only the selected, relevant content does.

## Schema

See `schema/career-schema.md` for the full shape of `career.yaml` and the
rules any skill must follow when writing to it (mainly: never fabricate,
always cite a source, ask when ambiguous). Your workspace carries a short
pointer to it at `_config/schema.md`.

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
