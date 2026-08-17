# resume-kit

A career database in one YAML file, plus three Claude Code skills that keep
it filled in and turn it into consistently formatted, tailored resumes on
demand.

The idea: stop rebuilding your resume from scratch (or from whatever old
copy you can find) every time you apply somewhere. Feed this tool your old
resumes, LinkedIn export, and cover letters once. It builds a structured
record of your career — every job, every achievement, tagged and sourced.
From then on, paste a job posting and get a tailored, well-formatted PDF in
one pass, pulling only what's actually relevant from your real history.

## How it's split

- **This repo (public):** the skills, the schema, the PDF template. No
  personal data. Safe to share, fork, or publish.
- **Your data (private, not in this repo):** a separate folder holding your
  actual `career.yaml`, an `inbox/` for raw material, and `output/` for
  generated resumes. You choose where this lives — a private notes vault,
  a private repo, anywhere. resume-kit points at it via a small config
  file, never hardcodes it.

## Setup

1. Clone this repo somewhere on your machine.
2. In Claude Code, symlink (or point your skills config at) the three
   skill folders under `skills/`:
   - `resume-kit-init`
   - `resume-ingest`
   - `resume-build`
3. Ask Claude to run `resume-kit-init`. Tell it where your private data
   folder should live (anywhere outside this repo). It scaffolds
   `career.yaml`, `inbox/`, and `output/` there, and writes
   `~/.config/resume-kit/config.yaml` pointing at it.

## Workflow

1. **Drop material into `<your-data-dir>/inbox/`**: old resumes (PDF,
   DOCX, TXT, MD), your LinkedIn data export, cover letters, even old job
   postings you applied to. See `<your-data-dir>/inbox/README.md`.
2. **Run `resume-ingest`.** It reads everything in the inbox, merges it
   into `career.yaml` — deduping the same job across multiple old resumes,
   tagging skills, tracking where every fact came from — and asks you
   questions when something's ambiguous instead of guessing. Re-run it any
   time you have new material.
3. **Run `resume-build`** with a job posting (paste the text, give it a
   URL, or point it at a file). It selects the relevant experience and
   skills from `career.yaml`, writes a resume, and renders a PDF to
   `<your-data-dir>/output/<company>-<role>-<date>/`.

Repeat step 3 for every application. Repeat step 2 whenever you have new
material (a new job, a role update, another old resume you found).

## Why a YAML database instead of just editing a resume file

- **One source of truth.** Your career history stops living fragmented
  across five differently-worded old resumes.
- **Provenance.** Every fact traces back to where it came from — no
  drifting claims that got embellished three resumes ago and nobody
  remembers if they're still true.
- **A skills picture that builds itself.** Tags on achievements roll up
  into a derived skills section — what you've actually used, how much
  evidence backs it, how recently — instead of a hand-maintained list that
  goes stale.
- **Consistent output, tailored content.** The format never changes
  between applications; only the selected, relevant content does.

## Schema

See `schema/career-schema.md` for the full shape of `career.yaml` and the
rules any skill must follow when writing to it (mainly: never fabricate,
always cite a source, ask when ambiguous).

## Requirements

- Claude Code.
- Google Chrome (for PDF rendering via headless mode) — falls back to
  `wkhtmltopdf` if Chrome isn't found.
- `pandoc`, if you want to ingest `.docx` files (optional; PDF/TXT/MD work
  without it).

## License

MIT. Fork it, rename it, point it at your own data. See `LICENSE`.
