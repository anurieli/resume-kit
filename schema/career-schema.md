# career.yaml schema

This is the one file that holds your entire career database. Every other
skill in resume-kit reads from it and writes back to it. It is meant to grow
over years, not get rebuilt per application.

## Top-level shape

```yaml
person:
  name: "Jane Doe"
  headline: "Product engineer who ships"       # optional, one line
  location: "Brooklyn, NY"
  email: "jane@example.com"
  phone: "+1 555 555 5555"
  links:
    - label: "LinkedIn"
      url: "https://linkedin.com/in/janedoe"
    - label: "GitHub"
      url: "https://github.com/janedoe"
  summary: >
    2-4 sentence professional summary. Written once, refined over time,
    NOT regenerated fresh per application (resume-build may trim/reorder
    it, but the source of truth lives here).

experiences:
  - id: exp-acme-2021              # stable id, never reused for a different job
    company: "Acme Corp"
    title: "Senior Backend Engineer"
    location: "Remote"
    start: "2021-03"                # YYYY-MM
    end: "2023-08"                  # YYYY-MM or "present"
    tags: [python, distributed-systems, leadership]
    achievements:
      - text: "Led migration of the billing pipeline to event-driven architecture, cutting reconciliation errors 40%."
        tags: [python, distributed-systems, leadership]
        metric: "40% error reduction"          # optional, pulled out for easy scanning
        source: "01_intake/old-resume-2022.pdf"  # provenance: where this fact came from
      - text: "..."
        tags: [...]
        source: "..."

education:
  - id: edu-university-name
    institution: "State University"
    degree: "B.S. Computer Science"
    start: "2013-09"
    end: "2017-05"
    tags: [cs-fundamentals]
    source: "01_intake/old-resume-2022.pdf"

projects:
  - id: proj-side-thing
    name: "Side Thing"
    description: "One-line description."
    tags: [react, side-project]
    url: "https://..."
    source: "..."

certifications:
  - id: cert-aws-saa
    name: "AWS Solutions Architect Associate"
    issuer: "AWS"
    date: "2022-06"
    source: "..."

skills:
  # This section is DERIVED, not hand-authored. resume-ingest maintains it
  # by aggregating tags across experiences/projects/achievements: how many
  # entries reference a skill, over what date range, how recently. It is
  # the "what am I actually strong at" view, built up over time instead of
  # guessed fresh in each session.
  - name: python
    first_used: "2018-01"
    last_used: "2023-08"
    evidence_count: 7          # number of achievements/experiences tagging this
    confidence: high           # high / medium / low, set by resume-ingest based on evidence_count + recency

meta:
  schema_version: 1
  last_ingested: "2026-08-17"   # date resume-ingest last ran
```

## Rules for anything that writes to this file

1. **Never fabricate.** Every fact traces back to a `source:`: a file in
   `01_intake/`, or a direct answer the user gave when asked a clarifying
   question (in which case `source: "user-confirmed 2026-08-17"`).
2. **Dedupe by (company, title, overlapping dates), not by exact text
   match.** The same job described differently across two old resumes is
   ONE experience entry with a merged, deduplicated achievement list, not
   two entries.
3. **When something doesn't fit the schema or is ambiguous** (conflicting
   dates for the same job, a title that doesn't map cleanly, an achievement
   that might belong to two different jobs), stop and ask the user. Don't
   force it into a field and don't drop it silently.
4. **`skills:` is always regenerated from tags**, never hand-edited by an
   ingestion pass. If tags change, recompute the whole section.
5. **IDs are stable.** Once `exp-acme-2021` exists, later ingestion runs
   update that entry in place rather than creating a duplicate with a new
   id.
