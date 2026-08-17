# templates — the format

This folder defines what every resume this tool produces looks like. It is
meant to be edited. Change it once, and every future resume follows.

## The two files

**`theme.css`** — the format itself: fonts, sizes, colors, spacing, page
margins, section rules. **This is the file you edit** to change how resumes
look. `resume-build` copies it verbatim into every generated resume and is
explicitly forbidden from restyling individual outputs. That rule is the
whole reason output stays consistent across applications instead of drifting
a little each time.

**`resume-template.html`** — the structure: which sections exist, in what
order, and the exact markup (class names) each one uses. Edit this to change
section order, rename a section, or add one. `resume-build` follows this
structure and fills it with content selected from `career.yaml`.

## Common edits

| You want | Edit |
|---|---|
| Different font | `theme.css`, `body { font-family }` |
| Tighter / looser page | `theme.css`, `@page { margin }` and `body { line-height }` |
| A colored resume | `theme.css`, set `--accent` and use it in `h1` / `h2` |
| Smaller text to fit more | `theme.css`, `body { font-size }` (don't go below 10pt) |
| Reorder sections | `resume-template.html`, move the `<h2>` blocks |
| Add a "Certifications" section | `resume-template.html`, copy an existing `<h2>` + `.entry` block |

## One theme, for now

resume-kit currently ships a single, deliberately plain theme: neutral,
ATS-safe, no columns or graphics that parsers choke on. Multiple selectable
themes are a later addition. If you want a different look now, edit
`theme.css` directly, or fork the repo and keep your own.

## The rule that keeps it consistent

`resume-build` selects and orders *content* per job. It never changes
*format* per job. If two resumes from this tool look different from each
other, something is wrong: check that `theme.css` was inlined verbatim
rather than regenerated.
