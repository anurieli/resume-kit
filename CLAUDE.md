# CLAUDE.md

Instructions for agents working **on resume-kit itself**. Humans want
`README.md`. Agents working *inside a user's workspace* want the `CLAUDE.md`
in that workspace, not this file.

## What this repo is

The public half of resume-kit: skills, schema, templates, and the scaffold
script. It holds **no personal data** and must never accumulate any. A user's
career record lives in a separate private directory, located at runtime via
`data_dir` in `~/.config/resume-kit/config.yaml`.

```
schema/     career-schema.md (the v2 spine), interview-bank.md
templates/  theme.css, resume-template.html, life-log.md. DEFAULTS only.
skills/     resume-kit-init, career-ingest, career-enrich, career-target, resume-build
examples/   fictional data for demos and tests. Keep it fictional.
```

## The two rules most likely to be broken

**1. Templates here are seeds, not the live format.** `resume-kit-init`
copies `templates/theme.css`, `resume-template.html`, `life-log.md`, and the
schema into a workspace's `_config/` at scaffold time. From then on the
workspace copy is authoritative. Editing this repo does not change an
existing workspace, and that is deliberate: it keeps a workspace portable to
any surface, and lets two users of the same tool have different formats. When
you change a template here, say plainly that it only affects new workspaces.

**2. A skill and a stage contract must never disagree.** Each skill's work is
also described, in short form, by a `CONTEXT.md` that `init.sh` generates.
Change a path or a rule in one and you must change it in the other, in the
same commit. The contract is what governs when the two conflict, because it
is what a fresh agent reads.

## The integrity model, which is the point of the tool

Every claim in `career.yaml` carries an `evidence_type`: `documented`,
`self-reported`, `self-assessment`, or `derived`. Evidence is never promoted
between tiers without a new source document. Only `documented` and
`self-reported` may be printed on a resume; `self-assessment` shapes emphasis
and wording but never appears as a claim; `derived` is internal.

Do not weaken this to make output more impressive. A tool that launders
someone's self-image into apparent fact is worse than useless, because the
failure surfaces in an interview. Full table: `schema/career-schema.md`.

## Conventions

- **No em dashes or double-hyphens anywhere**, including in generated files
  and anything that renders onto a resume. Periods, commas, colons, or single
  hyphens.
- Avoid: delve, crucial, pivotal, tapestry, foundational, robust, seamless,
  landscape (metaphorical), realm. Avoid "Most people..." openers, negative
  parallelism as a hook, and grand pronouncements.
- Skill files follow one shape: frontmatter with `name` and a `description`
  carrying real trigger phrases, then purpose, `## Before starting`,
  `## Life-update check`, `## Workflow` (numbered, imperative), `## Don't`.
- Keep `CONTEXT.md` files terse. Layer 1 around 300 tokens, stage contracts
  200 to 500. Small context is the point of ICM, and a bloated contract
  defeats it.
- `init.sh` is idempotent and never overwrites an existing file. It also
  refuses to repoint an existing config at a different directory without
  `RESUME_KIT_FORCE_CONFIG=1`, because that config is the only pointer to
  someone's real career data. Do not weaken either property.

## Testing changes

Scaffold into a throwaway directory, back up `~/.config/resume-kit/config.yaml`
first and restore it after, since `init.sh` writes it. Verify the workspace is
self-contained: nothing in it should need a path back to this repo except
`render-pdf.sh`. Then render a resume end to end and look at the PDF, not just
the exit code.

`CHANGELOG.md` gets an entry for anything meaningful, newest at the top.
