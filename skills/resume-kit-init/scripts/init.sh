#!/usr/bin/env bash
# Scaffold a resume-kit ICM workspace and point the global config at it.
#
# Usage: init.sh <data_dir>
#
# The data directory is an ICM (Interpretable Context Methodology) workspace:
# numbered stage folders, each carrying a CONTEXT.md contract, with the
# filesystem itself acting as the runtime. Layers:
#   0  IDENTITY.md          what this workspace is
#   1  CONTEXT.md           routing: trigger -> stage -> output
#   2  NN_<stage>/CONTEXT.md  stage contract (Inputs / Process / Outputs / Checkpoints)
#   3  _config/             stable reference
#   4  NN_<stage>/output/   per-run artifacts
#
# Idempotent: an existing file is never overwritten, so hand-tuned contracts
# and a filled-in career.yaml both survive a re-run. To refresh a generated
# file, delete it and run this again.
#
# Optional env var:
#   RESUME_KIT_VAULT_BREADCRUMB   an Obsidian wikilink, e.g. "[[06-Personal/index|Personal]]".
#                                 When set, IDENTITY.md is written with vault
#                                 frontmatter and a breadcrumb to that parent index.
set -euo pipefail

DATA_DIR="${1:?usage: init.sh <data_dir>}"
DATA_DIR="$(cd "$(dirname "$DATA_DIR")" 2>/dev/null && pwd)/$(basename "$DATA_DIR")" || DATA_DIR="$1"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

CONFIG_DIR="$HOME/.config/resume-kit"
CONFIG_FILE="$CONFIG_DIR/config.yaml"
TODAY="$(date +%Y-%m-%d)"

CREATED=0
SKIPPED=0

# write_if_absent <path>  (content on stdin)
# Placeholders substituted: @@REPO_DIR@@, @@TODAY@@
write_if_absent() {
  local target="$1"
  if [[ -e "$target" ]]; then
    SKIPPED=$((SKIPPED + 1))
    return 0
  fi
  mkdir -p "$(dirname "$target")"
  sed -e "s|@@REPO_DIR@@|$REPO_DIR|g" -e "s|@@TODAY@@|$TODAY|g" > "$target"
  CREATED=$((CREATED + 1))
}

mkdir -p \
  "$DATA_DIR/_config" \
  "$DATA_DIR/01_intake/output/processed" \
  "$DATA_DIR/02_career-db/self/reflections" \
  "$DATA_DIR/02_career-db/output" \
  "$DATA_DIR/03_target/output" \
  "$DATA_DIR/04_deliverable/output" \
  "$CONFIG_DIR"

for d in 01_intake/output 01_intake/output/processed 02_career-db/self/reflections 02_career-db/output 03_target/output 04_deliverable/output; do
  [[ -e "$DATA_DIR/$d/.gitkeep" ]] || touch "$DATA_DIR/$d/.gitkeep"
done

# ---------------------------------------------------------------- Layer 0

if [[ -n "${RESUME_KIT_VAULT_BREADCRUMB:-}" ]]; then
  write_if_absent "$DATA_DIR/IDENTITY.md" <<EOF
---
type: note
status: active
date: $TODAY
tags:
  - personal/career
  - icm
---

> [!nav] ← $RESUME_KIT_VAULT_BREADCRUMB

EOF
  IDENTITY_MODE="append"
else
  IDENTITY_MODE="create"
fi

identity_body() {
  cat <<'EOF'
# resume-kit workspace

A career folder that produces resumes. The durable asset is the record of
one person's working life; a resume is one view of it, rendered for one
company. The record is meant to grow over years.

Run as an ICM pipeline: the filesystem is the runtime, each numbered folder
is one stage, each stage's `CONTEXT.md` is its contract, and every
intermediate is a file you can open and edit.

This directory holds the private half of resume-kit: real career data, real
job postings, real resumes. The tool itself (skills, schema, PDF template)
lives separately at `@@REPO_DIR@@` and is meant to be public. Nothing
personal belongs there.

Owner: whoever runs this workspace. One person, one career record.

## Layout

```
IDENTITY.md              you are here. Layer 0.
CONTEXT.md               Layer 1: routing. Which stage handles what.
_config/                 Layer 3: schema rules, interview bank, theme.css,
                         resume template. This workspace's own copies.
01_intake/               raw documents land here.
02_career-db/
  career.yaml            the structured spine.
  self/reflections/      long-form rambles, referenced from career.yaml.
  output/                ingest and enrich reports.
03_target/output/<slug>/ posting.md, brief.md.
04_deliverable/output/<YYYY-MM-DD>-<slug>/
                         positioning.md, resume.html, resume.pdf.
```

Stages 01 and 02 grow the record over years. Stages 03 and 04 run once per
application and leave a dated folder behind per job.

## The loop

1. **Ingest to bootstrap.** `career-ingest` reads documents you already
   have and gets titles, dates, and old bullets into `career.yaml`. This is
   the start, not the point. It produces a thin record.
2. **Enrich over time.** `career-enrich` interviews you, captures rambles as
   reflections, and fills in scope, numbers, initiative, and what you are
   actually good at. This is what makes the record worth having, and it
   never really finishes.
3. **Target a role.** `career-target` reads a posting against the record and
   gives you positioning, honest gaps, concrete tips, and a real answer on
   whether to apply. You can stop here.
4. **Build the resume.** `resume-build` renders the selected material into
   the fixed format.

## Two ways to run a stage

1. **Call a skill.** `career-ingest`, `career-enrich`, `career-target`,
   `resume-build`. All read `~/.config/resume-kit/config.yaml` to find this
   directory.
2. **Drop a file into a stage folder** and ask an agent to continue. It
   reads that stage's `CONTEXT.md` and follows the contract. Same result,
   no skill call needed.

Either way the contract in `CONTEXT.md` is what governs. If a skill and a
contract disagree, that is a bug: fix both in the same change.

## How to run a stage

1. Read this file, then the root `CONTEXT.md`, then only the target
   stage's `CONTEXT.md`. Do not load the whole workspace. Small context is
   the point of the structure.
2. Follow the contract's Process steps in order.
3. Write results into that stage's `output/`. Never write into a stage
   upstream of the one you are running.
4. Stop at the Checkpoints and let a human look before the next stage runs.

## Rules that hold across every stage

- Never fabricate. Every claim in `career.yaml` carries an `evidence_type`
  and a `source:`.
- Never promote evidence. A `self-assessment` does not become
  `self-reported` because it sounds confident. Promotion needs a document.
- Only `documented` and `self-reported` material may be printed on a
  resume. `self-assessment` shapes emphasis and wording. `derived` is
  internal.
- Ask when ambiguous rather than guessing, and batch the questions.
- Long-form prose goes to `02_career-db/self/reflections/`, not into YAML.
- Content is tailored per job. Format never is: `theme.css` is inlined
  verbatim into every resume.
- `career.yaml` plus `self/reflections/` is the durable asset here.
  Everything under an `output/` folder is reproducible from it.
EOF
}

if [[ "$IDENTITY_MODE" == "append" ]]; then
  # Frontmatter was just written (or the file already existed and was kept).
  if ! grep -q '^# resume-kit workspace' "$DATA_DIR/IDENTITY.md" 2>/dev/null; then
    identity_body | sed -e "s|@@REPO_DIR@@|$REPO_DIR|g" >> "$DATA_DIR/IDENTITY.md"
    CREATED=$((CREATED + 1))
  fi
else
  identity_body > "$DATA_DIR/.identity.tmp"
  write_if_absent "$DATA_DIR/IDENTITY.md" < "$DATA_DIR/.identity.tmp"
  rm -f "$DATA_DIR/.identity.tmp"
fi

# ---------------------------------------------------------------- Layer 1

write_if_absent "$DATA_DIR/CONTEXT.md" <<'EOF'
# Routing

A career folder that produces resumes. The record is the asset; a resume is
one view of it.

| You have | Stage | Skill | Output |
|---|---|---|---|
| Old resumes, LinkedIn export, performance reviews, offer letters | `01_intake/` | `career-ingest` | files consumed into `01_intake/output/processed/` |
| Documents just consumed, or something to say about a job | `02_career-db/` | `career-ingest`, `career-enrich` | updated `career.yaml`, reflections, a run report |
| A job posting, and the question of whether to apply | `03_target/` | `career-target` | `output/<slug>/posting.md` and `brief.md` |
| A captured target plus a filled `career.yaml` | `04_deliverable/` | `career-target`, `resume-build` | `output/<YYYY-MM-DD>-<slug>/positioning.md`, `resume.html`, `resume.pdf` |

Two activation paths, same contracts:

- **Call a skill.**
- **Drop a file into a stage folder** and ask an agent to continue. It reads
  that stage's `CONTEXT.md`.

Passes:

- **Bootstrap pass:** 01 then 02, via `career-ingest`. Run it whenever new
  documents show up. It produces a thin record on purpose.
- **Enrichment pass:** 02 only, via `career-enrich`. The interview loop.
  Run it repeatedly over months. This is what makes the record good.
- **Application pass:** 03 then 04, via `career-target` then `resume-build`.
  Run it once per job. It needs 02 filled but not a fresh 01. Stopping after
  `career-target` is a legitimate outcome: deciding not to apply is an
  answer.

`<slug>` is `<company>-<role>`, lowercase and hyphenated, the same string in
03 and 04. Do not rename it between stages. The 04 folder additionally
carries a `<YYYY-MM-DD>-` prefix, so applying to the same company twice
leaves two folders rather than overwriting the first.

New here? Read `IDENTITY.md` first.
EOF

# ---------------------------------------------------------------- Layer 3
#
# Seed the workspace's own copies of the format and reference files. These are
# copies on purpose, not links: a workspace that carries its own theme, its own
# template, and its own schema can be opened anywhere by any agent that can read
# files, with no path back to this repo. The repo versions are the defaults a
# NEW workspace starts from. Once seeded, the workspace copy is authoritative
# and is never overwritten by a re-run.

seed_from_repo() {
  local src="$1" dest="$2"
  if [[ -e "$dest" ]]; then
    SKIPPED=$((SKIPPED + 1))
  elif [[ -f "$src" ]]; then
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    CREATED=$((CREATED + 1))
  else
    echo "WARNING: expected repo file missing, not seeded: $src" >&2
  fi
}

seed_from_repo "$REPO_DIR/templates/theme.css"            "$DATA_DIR/_config/theme.css"
seed_from_repo "$REPO_DIR/templates/resume-template.html" "$DATA_DIR/_config/resume-template.html"
seed_from_repo "$REPO_DIR/schema/interview-bank.md"       "$DATA_DIR/_config/interview-bank.md"
seed_from_repo "$REPO_DIR/schema/career-schema.md"        "$DATA_DIR/_config/career-schema-full.md"
seed_from_repo "$REPO_DIR/templates/life-log.md"           "$DATA_DIR/02_career-db/self/life-log.md"
seed_from_repo "$REPO_DIR/templates/workspace-CLAUDE.md"   "$DATA_DIR/CLAUDE.md"

write_if_absent "$DATA_DIR/_config/schema.md" <<'EOF'
# career.yaml schema (v2)

Full schema: `_config/career-schema-full.md`, in this workspace. Read it before writing
to `02_career-db/career.yaml`. Summary of the shape and the hard rules:

**Shape.** Top-level keys: `person`, `experiences`, `education`, `projects`,
`certifications`, `skills`, `self_assessment`, `meta`. An experience carries
a stable `id`, `company`, `title`, `location`, `start`, `end` (`YYYY-MM` or
`present`), `tags`, a list of `achievements` (each with `text`, `tags`, an
optional `metric`, an `evidence_type`, and a `source`), plus optional
`context:` (team size, scope, whether the work was `unprompted`, `assigned`,
or `inherited`) and `reflections:` (paths to markdown under
`self/reflections/`).

**The evidence rule, which governs everything else.** Every claim carries an
`evidence_type`:

| Type | Came from | May a resume state it? |
|---|---|---|
| `documented` | old resume, LinkedIn, performance review, offer letter | Yes |
| `self-reported` | a ramble or interview answer | Yes, as experience. Never as a verified metric. |
| `self-assessment` | their opinion of themselves | **No.** Shapes emphasis and wording only. |
| `derived` | computed by the tool (`skills:`) | Internal only. |

**The rules any writer must follow:**

1. **Never fabricate.** Every claim carries an `evidence_type` and a
   `source:`: an intake filename, or `user-ramble <YYYY-MM-DD>` /
   `user-interview <YYYY-MM-DD>` when it came from the person directly.
2. **Never promote evidence.** Confidence does not turn a `self-assessment`
   into a `self-reported` fact, and precision does not turn a
   `self-reported` account into a `documented` one. Promotion requires a
   new source document.
3. **Dedupe by company plus overlapping dates**, not by matching text. One
   job described two ways across two old resumes is one entry with a unioned
   achievement list.
4. **Ask when it does not fit.** Conflicting dates, a title that does not
   map, an achievement that could belong to two roles: stop and ask. Do not
   force it into a field and do not drop it.
5. **`skills:` is derived.** Regenerate the whole section from tags on every
   write. Never hand-edit it incrementally.
6. **IDs are stable.** Once `exp-acme-2021` exists, later runs update it in
   place instead of creating a second entry.
7. **Long-form goes to markdown.** Rambles and reflections live under
   `self/reflections/` and are referenced by path. YAML holds structure,
   markdown holds prose.
8. **Keep `meta.enrichment_gaps` current.** It is how the next session knows
   what to ask about instead of asking at random.
EOF

write_if_absent "$DATA_DIR/_config/format.md" <<'EOF'
# Output format

The format lives HERE, in this workspace, and it is meant to be edited.

- **`theme.css`** is the format: fonts, sizes, spacing, page margins, section
  rules. Edit this file to change how every future resume looks.
- **`resume-template.html`** is the structure: which sections exist, in what
  order, and the class names each uses (`.entry`, `.entry-head`,
  `.entry-title`, `.entry-org`, `.entry-dates`, `.entry-loc`, `ul.bullets`,
  `.skills-list`).

**The rule that keeps output consistent:** `04_deliverable` inlines
`theme.css` into each generated resume verbatim. It does not rewrite,
reformat, tune, or extend it, and it adds no styles of its own. Content is
tailored per job. Format never is.

If two resumes out of this workspace look different from each other,
something went wrong: check that `theme.css` was inlined rather than
regenerated.

Want a different look? Edit `theme.css` once. Every future resume follows.
Changing the styling of a single output is the error case, not the feature.

## What may be printed

Format consistency is one half. The other is what is allowed onto the page
at all, which `evidence_type` decides (see `schema.md`):

- `documented` and `self-reported` material may appear.
- `self-assessment` never appears as a claim. It decides which experience
  gets selected and how it is worded, nothing more.
- `derived` never appears. Skill names may be listed; confidence levels and
  evidence counts stay internal.

A resume that prints someone's opinion of themselves as a fact is the
failure this rule exists to prevent.

## Where deliverables land

`04_deliverable/output/<YYYY-MM-DD>-<slug>/`, holding `positioning.md` from
`career-target` and `resume.html` plus `resume.pdf` from `resume-build`. The
date prefix means applying to the same company twice leaves a history rather
than an overwrite.
EOF

# ---------------------------------------------------------------- Layer 2

write_if_absent "$DATA_DIR/01_intake/CONTEXT.md" <<'EOF'
# 01_intake

Raw career documents land in this folder's root: old resumes (PDF, DOCX,
TXT, MD), a LinkedIn "Download your data" export, performance reviews, offer
and promotion letters, cover letters, job postings already applied to.

This stage is bootstrap. Documents hold titles, dates, and old bullets. They
do not hold scope or judgment. That comes from `career-enrich` in stage 02.

## Inputs
- Files dropped in `01_intake/` root (everything except `CONTEXT.md` and `output/`)
- Layer 3: `../_config/schema.md`

## Process
1. List the files in this folder's root. **If there are none, do not just
   report an empty folder.** Say what to drop in: old resumes in any format,
   a LinkedIn data export, performance reviews, offer letters, cover letters.
   Add that someone with no documents can skip this stage and run
   `career-enrich` instead, which builds the record by asking.
2. Run the `career-ingest` skill, or follow it by hand: this stage extracts,
   `02_career-db` merges.
3. Classify every file: usable career material, context only (cover letters,
   old postings, recommendation letters), or not relevant (screenshots, tax
   documents, whatever got dragged in). **Name every skipped file and say
   why.** Never delete anything, junk included. Ask when you cannot tell.
4. Extract text per type. PDF, TXT, MD: read directly. DOCX:
   `pandoc "<file>" -t markdown`. LinkedIn export: parse `Positions.csv`,
   `Education.csv`, `Skills.csv` as structured data, not as prose. They are
   the most reliable source for exact dates and titles.
5. **Read performance reviews closely.** They are the highest-value document
   here: they carry hard numbers the person has forgotten, and a manager's
   account of scope. A metric from a review is the strongest evidence in the
   record.
6. Treat cover letters and old job postings as context only. They never
   become experience or education entries.
7. Hand extracted entries to `02_career-db`, each carrying
   `evidence_type: documented` and a `source:` naming the file.
8. Move every consumed file to `output/processed/`, keeping its filename
   exactly so every `source:` still resolves. Move, never copy, never delete.

## Outputs
- Consumed source files -> `output/processed/`

## Checkpoints
- A file still sitting in the root after a run was skipped. Say which and why.
- Confirm every file moved to `output/processed/` was actually read, not just
  moved.
EOF

write_if_absent "$DATA_DIR/02_career-db/CONTEXT.md" <<'EOF'
# 02_career-db

The durable asset. `career.yaml` is the structured spine;
`self/reflections/` holds the long-form prose it references. Both are meant
to grow over years, not be rebuilt per application.

Two skills write here. `career-ingest` merges documents in (bootstrap).
`career-enrich` interviews the person and fills in what documents never
held (the loop that actually matters). A ramble dropped into `self/` is a
valid trigger for the second.

## Inputs
- Layer 4: `../01_intake/output/processed/` (what was just consumed)
- Layer 3: `../_config/schema.md`
- `career.yaml` and `self/reflections/` in this folder, the current record
- `../_config/interview-bank.md`, for enrichment sessions

## Process
1. Read `career.yaml` in full first. You merge into it, never start over.
   Read existing reflections before interviewing.
2. Every claim gets an `evidence_type` and a `source:`. Documents produce
   `documented`. What the person tells you is `self-reported` (events) or
   `self-assessment` (their opinion of themselves). Never promote one to
   another, however confidently it was said.
3. Match experiences by company plus overlapping dates, not title text.
   Union achievement lists, dedupe reworded duplicates, keep distinct ones.
   New roles get a stable id `exp-<company-slug>-<start-year>`, never reused.
   Tag everything, reusing tag names already in the file: `python`, not
   `Python3`.
4. **Enrichment:** find the thinnest area (no metrics, no `context:`, no
   reflections, or an empty `self_assessment`), ask three to five questions
   from the interview bank, then stop. Never ask what the record answers,
   never suggest an answer to fill a silence.
5. **Rambles go to `self/reflections/<slug>.md`**, lightly cleaned but in
   the person's words, headed with the capture date. Extract facts into
   `career.yaml`, link the file from that experience's `reflections:` list.
   Multi-paragraph prose never goes into YAML.
6. Never invent or round a number. If they do not know, log no `metric`. Set
   `context.initiative` only when they said which it was. Batch every
   ambiguity into one set of questions: ask, do not guess, do not drop.
7. Regenerate `skills:` wholly from tags: `first_used`/`last_used` from the
   date range carrying the tag, `evidence_count` from how many carry it,
   `confidence` high (5+ entries or used within 2 years), medium (2 to 4, or
   3 to 5 years ago), low (1 entry, or 5+ years stale). All `derived`.
8. Bump `meta.last_ingested` or `meta.last_enriched`, and rewrite
   `meta.enrichment_gaps` as specific pointers, for example
   `"exp-fernhill-2018 has no metrics and no reflection"`.
9. Write a report to `output/<YYYY-MM-DD>-ingest.md` or `-enrich.md`: what
   was added or merged, files skipped and why, questions and answers, and
   the updated gap list.
10. **Say how thin the record is.** Count roles lacking metrics, `context:`,
    and reflections, and whether `self_assessment` is empty. After an ingest
    run, recommend `career-enrich` and name what it should ask first. A thin
    record produces a resume that reads like a job description.

## Outputs
- `career.yaml` (updated in place)
- `self/reflections/<slug>.md` (new reflections)
- `<YYYY-MM-DD>-ingest.md` / `-enrich.md` -> `output/`

## Checkpoints
- Read the run report before building anything from this record.
- Spot-check any experience merged from two sources. Merges are where the
  wrong dates get in.
- Check nothing the person merely believes about themselves got written as
  a `documented` fact.
EOF

write_if_absent "$DATA_DIR/03_target/CONTEXT.md" <<'EOF'
# 03_target

One job posting, captured verbatim and reduced to a brief. This stage
records what the job wants. Deciding what to say about it happens in
`04_deliverable`.

## Inputs
- A job posting: pasted text, a URL, or a file dropped in `03_target/`
- Layer 4: `../02_career-db/career.yaml` (to confirm the record is filled
  enough before an application pass starts)

## Process
1. Build the slug: `<company>-<role>`, lowercase and hyphenated. Create
   `output/<slug>/`. This exact slug is reused in `04_deliverable`.
2. Write the posting verbatim to `output/<slug>/posting.md`. Fetch the URL if
   given one. Do not summarize or trim here. The raw text is the record, and
   postings get taken down within weeks. If a fetch came back partial or
   paywalled, say so and ask for the pasted text.
3. Write `output/<slug>/brief.md` with these sections and nothing else:
   - **Target title**
   - **Company**
   - **Emphasized skills and technologies**, as a list, in the posting's own
     words
   - **Key responsibilities**, as a list
   - **Seniority signals**: years asked for, scope of ownership, who the role
     reports to, whether it names leading or mentoring
   Note which requirements the posting repeats or lists first. Repetition is
   the clearest signal a posting gives about what it screens for.
4. Keep `brief.md` to the posting's own claims. Do not infer what the company
   "really wants" and do not import outside knowledge of it. Comparison
   against `career.yaml` happens in `04_deliverable`.
5. Past briefs in `output/*/brief.md` are the pattern-detection input for
   `career-target`. Leave them in place; they are why a recurring gap can be
   named as a ceiling rather than a one-off.
6. If the posting arrived as a file dropped in this folder, move it into
   `output/<slug>/` once captured.

## Outputs
- `posting.md`, `brief.md` -> `output/<slug>/`

## Checkpoints
- Read `brief.md` before running `04_deliverable`. It is the tailoring
  instruction: a wrong target title or a missed skill propagates straight
  into the positioning and the resume.
EOF

write_if_absent "$DATA_DIR/04_deliverable/CONTEXT.md" <<'EOF'
# 04_deliverable

Two artifacts per application, in one dated folder:
`output/<YYYY-MM-DD>-<slug>/`. `career-target` writes `positioning.md`
(the coaching half). `resume-build` writes `resume.html` and `resume.pdf`
(the document half). The date prefix means a second application to the same
company leaves a history rather than an overwrite.

Stopping after `positioning.md` is a legitimate outcome. Deciding not to
apply, with a reason and a list of what would change it, is an answer.

## Inputs
- Layer 4: `../03_target/output/<slug>/brief.md` and `posting.md`
- Layer 4: `../02_career-db/career.yaml` and `../02_career-db/self/reflections/`
- Layer 3: `../_config/format.md`

## Process
1. Run `career-target` for `<slug>`, then `resume-build`, or do it by hand.
   Reuse the slug `03_target` created and keep both artifacts in one dated
   folder.
2. **Positioning first.** `positioning.md` covers: how the person reads for
   this role, the strongest evidence to lead with, the honest gaps, concrete
   tips sized to each gap, and a real apply-or-not call. With three or more
   past briefs at `../03_target/output/*/brief.md`, name any recurring
   requirement as a pattern. Fewer than three is too small a sample.
3. **Check the record can support advice.** If the relevant roles carry no
   metrics and no context and `self_assessment` is empty, say so, write the
   brief, and recommend `career-enrich` first. A confident analysis of an
   empty record is worse than none, because the person will act on it.
4. **Then the resume.** Rank by tag overlap with `brief.md` plus recency,
   following `positioning.md` where it exists. Do not bury a relevant older
   role under a less relevant recent one, and do not resurrect a decade-stale
   role over recent equivalent experience. Include the most relevant
   achievements per role, not every one logged. Prefer `documented` ones
   carrying a `metric`.
5. **Honor `meta.presentation_preferences`** if `career.yaml` carries any.
   That is the person's own judgment about conventions in their field, so it
   governs framing and ordering. It cannot promote a skill no role or project
   carries, and it cannot suppress something the posting explicitly requires:
   name that conflict rather than resolving it silently. A skills line of
   bare tool names is the weakest version of that section; group by
   capability and put the tools inside the groups.
6. **What may be printed** (see `../_config/format.md`): `documented` and
   `self-reported` may appear. `self-assessment` shapes selection and wording
   and is never printed as a claim. `derived` is internal; skill names may be
   listed, confidence levels and evidence counts may not.
7. Every fact comes from `career.yaml` verbatim or reworded without changing
   its meaning. Never invent to close a gap, never promote evidence to make a
   bullet land harder. Leave it out and report the gap.
8. Write `resume.html` into the dated folder, opening with a 2 to 3 sentence
   summary grounded in `person.summary` and angled at this posting. Inline
   `theme.css` verbatim into the `<style>` block and follow
   `resume-template.html` for section order and class names. Edits to those
   files are the format now.
9. Render the PDF with
   `@@REPO_DIR@@/skills/resume-build/scripts/render-pdf.sh <html> <pdf>`. It
   drives headless Chrome, so a surface without a shell stops after
   `resume.html` and reports the PDF as pending. Verify the result runs 1 to
   2 pages with nothing overflowing.
10. **Build the submission kit.** In the dated folder, write
    `SUBMISSION-KIT.md` plus a `submission/` subfolder holding the
    send-ready file named as the employer will see it,
    `<Name> - Resume.pdf`. The working `resume.html` and `resume.pdf` stay
    in the dated folder. `SUBMISSION-KIT.md` covers what to send, what is
    here for you rather than the employer, how the resume was angled, the
    known risk, and what to do once it is sent.
11. **Promote it, and log it.** Copy the finished PDF and HTML to
    `../CURRENT-RESUME.pdf` and `../CURRENT-RESUME.html` at the workspace
    root, and add a row to `output/index.md` naming the date and what it was
    built for. `CURRENT-RESUME.pdf` is what anyone takes when they just need
    "the resume". A build that has been sent is frozen: never edit,
    re-render, or overwrite a dated folder after the fact, because it is the
    record of what that company actually received. A newer build becomes
    current; the old one keeps its folder and its row. Only the user
    overrides this. Every resume here is tailored to one posting, so the
    current one is not a general resume: keep `../CURRENT-RESUME.md`
    accurate about what it was built for.

## Outputs
- `positioning.md`, `resume.html`, `resume.pdf` -> `output/<YYYY-MM-DD>-<slug>/`
- `SUBMISSION-KIT.md` and `submission/<Name> - Resume.pdf` -> the dated folder
- a copy of the finished resume -> `../CURRENT-RESUME.pdf` and `.html`
- `../CURRENT-RESUME.md` updated with what it was built for
- a row in `output/index.md`

## Checkpoints
- Read `positioning.md` before sending anything. The gap list is the part
  worth acting on, and the recommendation may be "do not apply".
- Look at the PDF. Page count, overflow, spacing.
- Any gap between `brief.md` and `career.yaml` is material for the next
  `career-enrich` session. Write it into `meta.enrichment_gaps` rather than
  forgetting it.
- Nothing on the page should trace back to a `self-assessment`.
EOF

# ---------------------------------------------------------- career database

if [[ ! -f "$DATA_DIR/02_career-db/career.yaml" ]]; then
  cat > "$DATA_DIR/02_career-db/career.yaml" <<'EOF'
# The durable record of one working life. Grows over years.
# Every claim carries an evidence_type and a source. See _config/schema.md.

person:
  name: ""
  headline: ""
  location: ""
  email: ""
  phone: ""
  links: []
  summary: ""

experiences: []
education: []
projects: []
certifications: []

# DERIVED. Regenerated from tags on every write, never hand-edited.
skills: []

# SELF-ASSESSMENT. The person's own view. Never printed on a resume as fact.
# Filled in by career-enrich, by asking. Documents rarely contain this.
self_assessment:
  strengths: []
  people_come_to_me_for: []
  working_on: []
  prefers: []

meta:
  schema_version: 2
  last_ingested: null
  last_enriched: null
  enrichment_gaps: []
EOF
  echo "Created $DATA_DIR/02_career-db/career.yaml (empty v2 scaffold)"
else
  echo "career.yaml already exists at $DATA_DIR/02_career-db/, left untouched"
fi

# ----------------------------------------------------------------- config
#
# The config is the pointer to a user's real career data. Silently repointing
# it strands an existing workspace, so an existing config that names a
# DIFFERENT directory is never overwritten without RESUME_KIT_FORCE_CONFIG=1.

echo "Scaffolded ICM workspace at $DATA_DIR ($CREATED files created, $SKIPPED left untouched)"

EXISTING_DATA_DIR=""
if [[ -f "$CONFIG_FILE" ]]; then
  EXISTING_DATA_DIR="$(sed -n 's/^data_dir:[[:space:]]*//p' "$CONFIG_FILE" | head -1)"
fi

if [[ -n "$EXISTING_DATA_DIR" && "$EXISTING_DATA_DIR" != "$DATA_DIR" && "${RESUME_KIT_FORCE_CONFIG:-}" != "1" ]]; then
  echo ""
  echo "WARNING: config was NOT changed."
  echo "  $CONFIG_FILE already points at:"
  echo "    $EXISTING_DATA_DIR"
  echo "  The workspace above was still created, but the skills will keep"
  echo "  reading the existing directory."
  echo ""
  echo "  To repoint resume-kit at the new directory, re-run with:"
  echo "    RESUME_KIT_FORCE_CONFIG=1 $0 \"$DATA_DIR\""
  exit 0
fi

cat > "$CONFIG_FILE" <<EOF
data_dir: $DATA_DIR
repo_dir: $REPO_DIR
EOF

echo "Config written: $CONFIG_FILE -> data_dir: $DATA_DIR"
