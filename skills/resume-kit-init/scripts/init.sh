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
  "$DATA_DIR/02_career-db/output" \
  "$DATA_DIR/03_target/output" \
  "$DATA_DIR/04_deliverable/output" \
  "$CONFIG_DIR"

for d in 01_intake/output 01_intake/output/processed 02_career-db/output 03_target/output 04_deliverable/output; do
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

A career database and a tailored resume builder, run as an ICM pipeline.
The filesystem is the runtime: each numbered folder is one stage, each
stage's `CONTEXT.md` is its contract, and every intermediate is a file you
can open and edit.

This directory holds the private half of resume-kit: real career data,
real job postings, real resumes. The tool itself (skills, schema, PDF
template) lives separately at `@@REPO_DIR@@` and is meant to be public.
Nothing personal belongs there.

Owner: whoever runs this workspace. One person, one career database.

## Layout

```
IDENTITY.md        you are here. Layer 0.
CONTEXT.md         Layer 1: routing. Which stage handles what.
_config/           Layer 3: stable reference (schema rules, output format).
01_intake/         raw material lands here.
02_career-db/      career.yaml, the durable database.
03_target/         one job posting, captured and briefed.
04_deliverable/    the tailored resume, HTML and PDF.
```

Stages 01 and 02 grow the database over years. Stages 03 and 04 run once
per application and leave a folder behind per job.

## Two ways to run a stage

1. **Call a skill.** `resume-ingest` walks 01 into 02. `resume-build`
   walks 03 into 04. Both read `~/.config/resume-kit/config.yaml` to find
   this directory.
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

- Never fabricate. Every fact in `career.yaml` carries a `source:`.
- Ask when ambiguous rather than guessing, and batch the questions.
- Content is tailored per job. Format never is: `theme.css` is inlined
  verbatim into every resume.
- `career.yaml` is the only durable artifact here. Everything under an
  `output/` folder is reproducible from it plus a job posting.
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

| You have | Stage | Output |
|---|---|---|
| An old resume, LinkedIn export, cover letter, past posting | `01_intake/` | file consumed, moved to `01_intake/output/processed/` |
| Intake material just consumed | `02_career-db/` | updated `career.yaml` plus an ingest report |
| A job posting (pasted text, URL, or file) | `03_target/` | `output/<slug>/posting.md` and `brief.md` |
| A captured target plus a filled `career.yaml` | `04_deliverable/` | `output/<slug>/resume.html` and `resume.pdf` |

Two activation paths, same contracts:

- **Call a skill.** `resume-ingest` runs 01 into 02. `resume-build` runs 03
  into 04.
- **Drop a file into a stage folder** and ask an agent to continue. It reads
  that stage's `CONTEXT.md`.

Passes:

- **Ingest pass:** 01 then 02. Run it whenever new material shows up.
- **Application pass:** 03 then 04. Run it once per job. It needs `02` filled
  but does not need a fresh `01`.

`<slug>` is `<company>-<role>`, lowercase and hyphenated, and it is the same
string in 03 and 04. Do not rename it between stages.

New here? Read `IDENTITY.md` first.
EOF

# ---------------------------------------------------------------- Layer 3

write_if_absent "$DATA_DIR/_config/schema.md" <<'EOF'
# career.yaml schema

Full schema: `@@REPO_DIR@@/schema/career-schema.md`. Read it before writing
to `02_career-db/career.yaml`. Summary of the shape and the hard rules:

**Shape.** Top-level keys: `person`, `experiences`, `education`, `projects`,
`certifications`, `skills`, `meta`. An experience carries a stable `id`,
`company`, `title`, `location`, `start`, `end` (`YYYY-MM` or `present`),
`tags`, and a list of `achievements`, each with `text`, `tags`, an optional
`metric`, and a `source`.

**The rules any writer must follow:**

1. **Never fabricate.** Every fact traces to a `source:`, either the intake
   file it came from or `user-confirmed <YYYY-MM-DD>` when the person
   answered a question directly.
2. **Dedupe by company plus overlapping dates**, not by matching text. One
   job described two ways across two old resumes is one entry with a unioned
   achievement list.
3. **Ask when it does not fit.** Conflicting dates, a title that does not map,
   an achievement that could belong to two roles: stop and ask. Do not force
   it into a field and do not drop it.
4. **`skills:` is derived.** Regenerate the whole section from tags on every
   ingestion run. Never hand-edit it incrementally.
5. **IDs are stable.** Once `exp-acme-2021` exists, later runs update it in
   place instead of creating a second entry.
EOF

write_if_absent "$DATA_DIR/_config/format.md" <<'EOF'
# Output format

The format lives in `@@REPO_DIR@@/templates/`, and it is meant to be edited.

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
EOF

# ---------------------------------------------------------------- Layer 2

write_if_absent "$DATA_DIR/01_intake/CONTEXT.md" <<'EOF'
# 01_intake

Raw career material lands in this folder's root: old resumes (PDF, DOCX,
TXT, MD), a LinkedIn "Download your data" export, cover letters, job
postings already applied to.

## Inputs
- Files dropped in `01_intake/` root (everything except `CONTEXT.md` and `output/`)
- Layer 3: `../_config/schema.md`

## Process
1. List the files in this folder's root. If there are none, say so and stop.
2. Run the `resume-ingest` skill, or follow it by hand: this stage extracts,
   `02_career-db` merges.
3. Extract text per type. PDF, TXT, MD: read directly. DOCX:
   `pandoc "<file>" -t markdown`. LinkedIn export: parse `Positions.csv`,
   `Education.csv`, `Skills.csv` as structured data, not as prose. They are
   the most reliable source for exact dates and titles.
4. Treat cover letters and old job postings as context only. They never
   become experience or education entries. A cover letter can confirm
   phrasing the person likes; an old posting shows what roles they target.
5. Hand the extracted candidate entries to `02_career-db`, each carrying a
   `source:` naming the file it came from.
6. Move every consumed file to `output/processed/`, keeping its filename, so
   a re-run does not ingest it twice.

## Outputs
- Consumed source files -> `output/processed/`

## Checkpoints
- A file still sitting in the root after a run was skipped. Say which and why.
- Confirm every file moved to `output/processed/` was actually read, not just
  moved.
EOF

write_if_absent "$DATA_DIR/02_career-db/CONTEXT.md" <<'EOF'
# 02_career-db

`career.yaml` lives here. It is the one durable artifact in this workspace
and it is meant to grow over years, not be rebuilt per application.

## Inputs
- Layer 4: `../01_intake/output/processed/` (what was just consumed)
- Layer 3: `../_config/schema.md`
- `career.yaml` in this folder, the current state of the database

## Process
1. Read `career.yaml` first. You are merging into it, never starting over.
2. Match experiences by company plus overlapping dates, not by title text.
   The same job titled two ways across two resumes is one entry with a
   unioned achievement list. Dedupe reworded duplicates of the same fact;
   keep genuinely distinct achievements.
3. Give a new role a stable id: `exp-<company-slug>-<start-year>`. Never
   reuse or renumber an existing id.
4. Give every fact a `source:`. Use the intake filename, or
   `user-confirmed <YYYY-MM-DD>` when the person answered directly. An
   unsourced fact does not go in the file.
5. Tag every achievement with the skills, technologies, and themes it
   demonstrates. Reuse tag names already in the file: `python`, not `Python3`.
6. Batch every ambiguity into one set of questions at the end of the pass:
   conflicting dates or titles, unclear attribution, a block that does not
   map onto the schema. Ask, do not guess, and do not silently drop it.
7. Regenerate the whole `skills:` section from tags. `first_used` and
   `last_used` from the date range of entries carrying the tag,
   `evidence_count` from how many carry it, `confidence` high (5+ entries or
   used within 2 years), medium (2 to 4, or 3 to 5 years ago), low (1 entry,
   or not used in 5+ years).
8. Bump `meta.last_ingested` to today.
9. Write an ingestion report to `output/<YYYY-MM-DD>-ingest.md`: entries
   added, entries merged into existing ones, skills now tracked, questions
   asked and how they were answered.

## Outputs
- `career.yaml` (updated in place)
- `<YYYY-MM-DD>-ingest.md` -> `output/`

## Checkpoints
- Read the ingestion report before building anything from this database.
- Spot-check by hand any experience the report flags as merged from two
  sources. Merges are where the wrong dates get in.
EOF

write_if_absent "$DATA_DIR/03_target/CONTEXT.md" <<'EOF'
# 03_target

One job posting, captured verbatim and reduced to a brief. This stage
records what the job wants. It does not decide what to say about it.

## Inputs
- A job posting: pasted text, a URL, or a file dropped in `03_target/`
- Layer 4: `../02_career-db/career.yaml` (only to confirm the database is
  filled before an application pass starts)

## Process
1. Build the slug: `<company>-<role>`, lowercase and hyphenated. Create
   `output/<slug>/`. This exact slug is reused in `04_deliverable`.
2. Write the posting verbatim to `output/<slug>/posting.md`. Fetch the URL if
   given one. Do not summarize or trim here. The raw text is the record, and
   postings get taken down.
3. Write `output/<slug>/brief.md` with four sections and nothing else:
   - **Target title**
   - **Company**
   - **Emphasized skills and technologies**, as a list, in the posting's own
     words
   - **Key responsibilities**, as a list
4. Keep `brief.md` to the posting's own claims. Do not compare it against
   `career.yaml` here. Selection happens in `04_deliverable`.
5. If the posting arrived as a file dropped in this folder, move it into
   `output/<slug>/` once captured.

## Outputs
- `posting.md`, `brief.md` -> `output/<slug>/`

## Checkpoints
- Read `brief.md` before running `04_deliverable`. It is the tailoring
  instruction: a wrong target title or a missed skill propagates straight
  into the resume.
EOF

write_if_absent "$DATA_DIR/04_deliverable/CONTEXT.md" <<'EOF'
# 04_deliverable

The tailored resume. Content is selected per job. Format is identical every
time.

## Inputs
- Layer 4: `../03_target/output/<slug>/brief.md` and `posting.md`
- Layer 4: `../02_career-db/career.yaml`
- Layer 3: `../_config/format.md`

## Process
1. Run the `resume-build` skill for `<slug>`, or follow these steps by hand.
   Use the same `<slug>` that `03_target` created.
2. Rank experiences by tag overlap with `brief.md` plus recency. Do not bury
   a highly relevant older role under a less relevant recent one, and do not
   resurrect a decade-stale role over recent equivalent experience.
3. Within a selected role, include the most relevant achievements first, not
   every achievement logged for it. Selecting is what makes it tailored.
4. Every fact comes from `career.yaml` verbatim, or reworded without changing
   its meaning. Never invent to close a gap the posting opens. Leave it out
   and report the gap instead.
5. Write a 2 to 3 sentence summary grounded in `person.summary`, angled at
   this posting, claiming nothing unsupported elsewhere in `career.yaml`.
6. Write `output/<slug>/resume.html`. Inline `templates/theme.css` verbatim
   into the `<style>` block and follow `resume-template.html` for section
   order and class names. If those files have been edited, the edits are the
   format now. See `../_config/format.md`.
7. Render the PDF:
   ```bash
   @@REPO_DIR@@/skills/resume-build/scripts/render-pdf.sh \
     "output/<slug>/resume.html" "output/<slug>/resume.pdf"
   ```
   This step needs shell access, since it drives headless Chrome. A surface
   without a shell stops after `resume.html` and reports the PDF as pending.
8. Verify the PDF exists and runs 1 to 2 pages. If `pdftoppm` is available,
   render a PNG and look at it: check nothing overflows or reads cramped.

## Outputs
- `resume.html`, `resume.pdf` -> `output/<slug>/`

## Checkpoints
- Look at the PDF before sending it anywhere. Page count, overflow, spacing.
- Any gap between `brief.md` and `career.yaml` is material for the next
  `01_intake` run. Write it down rather than forgetting it.
EOF

# ---------------------------------------------------------- career database

if [[ ! -f "$DATA_DIR/02_career-db/career.yaml" ]]; then
  cat > "$DATA_DIR/02_career-db/career.yaml" <<'EOF'
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
skills: []

meta:
  schema_version: 1
  last_ingested: null
EOF
  echo "Created $DATA_DIR/02_career-db/career.yaml (empty scaffold)"
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
