# Changelog

## 2026-08-17 12:24 - render-pdf.sh no longer hangs after a successful render (dbfca39)
Headless Chrome (`--headless=new`) writes the PDF correctly but does not reliably exit
the process afterward on macOS, so the original script's `wait`-on-exit approach hung
indefinitely (had to be backgrounded past a 120s tool timeout during testing, even
though the PDF was already written within a few seconds). Rewrote it to run Chrome in
the background, poll the output file until its size stabilizes, then kill the Chrome
process and its user-data-dir directly instead of waiting on exit. Verified with a
full render of the example career data: 1-page PDF in ~4s, clean exit code 0, no
leftover Chrome processes. Files: skills/resume-build/scripts/render-pdf.sh.

## 2026-08-17 12:19 - Initial resume-kit: schema, init/ingest/build skills, PDF template (cc409ef)
Built resume-kit from scratch: a portable career database (career.yaml) plus three
Claude Code skills (resume-kit-init, resume-ingest, resume-build) that scaffold a
private data directory, absorb raw material (old resumes, LinkedIn exports, cover
letters) into the database with provenance tracking and dedup, and render a tailored
resume PDF from a job posting via headless Chrome. Public tool repo is deliberately
separate from any personal data; a config file at ~/.config/resume-kit/config.yaml
points at wherever the user's private data directory lives. Includes a fictional
example dataset (Jordan Rivera) and sample job posting for demoing without real
personal data. Files: README.md, LICENSE, schema/career-schema.md,
skills/resume-kit-init/SKILL.md, skills/resume-kit-init/scripts/init.sh,
skills/resume-ingest/SKILL.md, skills/resume-build/SKILL.md,
skills/resume-build/scripts/render-pdf.sh,
skills/resume-build/templates/resume-template.html,
examples/career.example.yaml, examples/sample-job-posting.txt.
