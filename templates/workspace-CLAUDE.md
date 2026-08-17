# CLAUDE.md

Instructions for any agent working in this folder. Humans want `README.md`.

This is a **resume-kit workspace**: one person's career record, plus the
machinery to turn it into tailored resumes. It runs as an ICM pipeline, so
the filesystem is the runtime and each numbered folder is a stage with a
`CONTEXT.md` contract.

## Read in this order, and no further

1. `IDENTITY.md`, what this workspace is.
2. `CONTEXT.md`, the routing table: which stage handles what.
3. Only the `CONTEXT.md` of the stage you are actually running.

Do not load the whole workspace. Small context is the point of the structure.
`_config/` holds the reference material, and a stage contract names the parts
of it you need.

## Before any task, check the life log

Read `02_career-db/self/life-log.md`. If the top entry is 2 months old or
more, or the log is empty, ask this before doing the work you were called
for:

> What are you up to right now, or what have you been up to?

Write the answer as a new dated entry at the top, then file what it contains
per the evidence rules below. One question, not an interview.

## The rules that hold everywhere in here

1. **Never fabricate.** Every claim in `career.yaml` carries an
   `evidence_type` and a `source`.
2. **Never promote evidence.** Confidence does not turn an opinion into a
   fact. The tiers are `documented`, `self-reported`, `self-assessment`, and
   `derived`. Moving up a tier requires a new source document, not better
   phrasing. Full table in `_config/schema.md`.
3. **Only `documented` and `self-reported` may be printed on a resume.**
   `self-assessment` shapes which experience gets chosen and how it is
   worded, and never appears as a claim about the person. `derived` is
   internal.
4. **Ask when it does not fit.** Conflicting dates, an unclear attribution, a
   document that does not map onto the schema. Batch the questions and ask.
   Do not force it into a field and do not drop it silently.
5. **Content is tailored per job. Format never is.** `_config/theme.css` is
   inlined verbatim into every resume. Restyling one output is the error
   case, not a feature.
6. **Long-form prose goes to `02_career-db/self/reflections/`,** referenced
   from `career.yaml` by path. YAML holds structure, markdown holds prose.
7. **Never delete a source document.** Consumed intake is archived to
   `01_intake/output/processed/`, not removed.
8. **Write only into the stage you are running.** Never write upstream.

## What is durable and what is disposable

`career.yaml`, `self/reflections/`, and `self/life-log.md` are the asset.
Everything under any `output/` folder is reproducible from them plus a job
posting, so it can be regenerated or thrown away without loss.

## Skills, when they are available

`career-ingest` (bootstrap from documents), `career-enrich` (the interview),
`career-target` (positioning and gaps), `resume-build` (render the PDF). They
are Claude Code skills and may not exist on every surface. They are a
convenience: the stage contracts describe the same work, so you can do any of
it by reading `CONTEXT.md` and following it. If a skill and a contract ever
disagree, that is a bug worth reporting, and the contract is what governs.

Rendering the PDF shells out to headless Chrome. Without a shell, stop at
`resume.html`, which is already print-ready, and tell the user to print it
from a browser. Do not call the deliverable done until a PDF exists.
