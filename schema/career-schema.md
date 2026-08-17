# career.yaml schema (v2)

The durable record of one person's working life. Every other part of
resume-kit reads from it and writes back to it. It is meant to grow over
years, not get rebuilt per application.

A resume is one *output* of this file. The file itself is the asset.

## The integrity rule that governs everything

Every claim carries an `evidence_type`. This is not bookkeeping, it is what
keeps the tool honest:

| `evidence_type` | Means | Came from | May a resume state it as fact? |
|---|---|---|---|
| `documented` | Written down somewhere verifiable | old resume, LinkedIn, performance review, offer letter | Yes |
| `self-reported` | The person's own account | a ramble, an interview answer | Yes, as experience. Never as a verified metric. |
| `self-assessment` | The person's opinion of themselves | "what am I good at" questions | **No.** Shapes emphasis and wording. Never printed as a claim. |
| `derived` | Computed by the tool | tag aggregation | Internal only. Never printed. |

A metric from a performance review (`documented`) and "I'm good at
stakeholder management" (`self-assessment`) are different kinds of data.
Mixing them is how a resume becomes a lie. Keep them separate.

## Top-level shape

```yaml
person:
  name: "Jane Doe"
  headline: "Product engineer who ships"
  location: "Brooklyn, NY"
  email: "jane@example.com"
  phone: "+1 555 555 5555"
  links:
    - label: "LinkedIn"
      url: "https://linkedin.com/in/janedoe"
  summary: >
    2-4 sentence professional summary. Written once, refined over time.
    resume-build may trim or re-angle it per job, but the source lives here.

experiences:
  - id: exp-acme-2021              # stable, never reused for a different job
    company: "Acme Corp"
    title: "Senior Backend Engineer"
    location: "Remote"
    start: "2021-03"               # YYYY-MM
    end: "2023-08"                 # YYYY-MM or "present"
    tags: [python, distributed-systems, leadership]

    achievements:
      - text: "Led migration of the billing pipeline to event-driven architecture, cutting reconciliation errors 40%."
        tags: [python, distributed-systems, kafka]
        metric: "40% error reduction"
        evidence_type: documented
        source: "01_intake/output/processed/perf-review-2023-H2.pdf"

    # Everything below is optional and gets filled in by career-enrich over
    # time. An experience with only achievements is valid, just thin.

    context:                       # scope and circumstance, from rambles
      team_size: 3
      scope: "Owned the pipeline end to end for 4 months."
      initiative: unprompted       # unprompted | assigned | inherited
      evidence_type: self-reported
      source: "user-ramble 2026-08-17"

    reflections:                   # long-form lives in markdown, not YAML
      - path: "self/reflections/acme-billing-migration.md"
        captured: "2026-08-17"
        summary: "What actually happened on the migration and what it taught."

education:
  - id: edu-state-university
    institution: "State University"
    degree: "B.S. Computer Science"
    start: "2013-09"
    end: "2017-05"
    tags: [cs-fundamentals]
    evidence_type: documented
    source: "..."

projects:
  - id: proj-queuewatch
    name: "QueueWatch"
    description: "One line."
    tags: [kafka, open-source]
    url: "https://..."
    evidence_type: documented
    source: "..."

certifications:
  - id: cert-aws-saa
    name: "AWS Solutions Architect Associate"
    issuer: "AWS"
    date: "2022-06"
    evidence_type: documented
    source: "..."

# ---- DERIVED. Never hand-edited. Regenerated from tags on every write. ----
skills:
  - name: python
    first_used: "2018-01"
    last_used: "2023-08"
    evidence_count: 7              # entries carrying this tag
    confidence: high               # high | medium | low
    evidence_type: derived

# ---- SELF-ASSESSMENT. The person's own view. Never printed as fact. ----
self_assessment:
  strengths:
    - claim: "Getting non-technical stakeholders to accept technical risk."
      backed_by: [exp-acme-2021]   # experiences that support it, may be empty
      confidence: high             # how sure THEY are, not how sure we are
      source: "user-ramble 2026-08-17"
  people_come_to_me_for:
    - "Untangling things nobody wants to own."
    - "Writing the doc when there isn't one."
  working_on:                      # known weak spots, honestly held
    - claim: "Kubernetes. Can read it, cannot design it."
      source: "user-interview 2026-08-17"
  prefers:                         # environment, not skill
    - "Small teams, high autonomy."

meta:
  schema_version: 2
  last_ingested: "2026-08-17"
  last_enriched: "2026-08-17"

  presentation_preferences:        # optional. How this person wants the
    - "Lead with systems design, not a language list."   # record framed.

  enrichment_gaps:                 # what career-enrich should ask about next
    - "exp-fernhill-2018 has no reflections and no metrics."
```

`presentation_preferences` is the one place a person's opinion about their
own field gets to shape output. Conventions differ by industry and they
change, so a person saying "listing languages reads as dated where I work"
is information the tool does not otherwise have. `resume-build` follows it.

It governs framing and ordering only. It cannot promote a skill no role or
project carries, and it cannot suppress something a posting explicitly
requires: that conflict gets named to the user, not quietly resolved. Write
entries here only when the person states the preference; never infer one.

## Rules for anything that writes to this file

1. **Never fabricate.** Every claim carries an `evidence_type` and a
   `source`. A `source` is either a file under
   `01_intake/output/processed/`, or `user-ramble <date>` /
   `user-interview <date>` when it came from the person directly.
2. **Never promote evidence.** A `self-assessment` does not become
   `self-reported` because it sounds confident, and `self-reported` does not
   become `documented` because it sounds specific. Promotion requires a new
   source document.
3. **Dedupe by (company, overlapping dates), not by text.** The same job
   described differently across two old resumes is ONE entry with a merged,
   deduplicated achievement list.
4. **`skills:` is always regenerated** from tags, never incrementally
   hand-edited.
5. **IDs are stable.** Once `exp-acme-2021` exists, later runs update it in
   place.
6. **Long-form goes to markdown, not YAML.** Rambles, reflections, and
   stories live as files under `02_career-db/self/reflections/` and are
   referenced by path. Multi-paragraph text inside YAML is unreadable and
   unedittable. YAML holds structure; markdown holds prose.
7. **When something is ambiguous, ask.** Conflicting dates, unclear
   attribution, a format that doesn't map. Batch the questions, don't
   interrogate one at a time.
8. **Keep `meta.enrichment_gaps` current.** It is how the tool knows what to
   ask about next time instead of asking at random.

## What a thin record looks like versus a rich one

Thin (right after ingestion): titles, dates, a handful of achievement bullets
lifted from old resumes, no context, no reflections, empty self-assessment.
Usable, produces a generic resume.

Rich (after a few enrichment passes): every role has scope and initiative,
the big ones have reflections, metrics came out of performance reviews, and
self-assessment says what the person is actually good at and what they are
not. This is what produces a resume that sounds like a person instead of a
job description.

The tool should always know which one it is holding, and say so.
