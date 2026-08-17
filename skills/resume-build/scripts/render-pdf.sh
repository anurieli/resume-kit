#!/usr/bin/env bash
# Render a resume HTML file to PDF via headless Chrome. No npm deps.
# Usage: render-pdf.sh <input.html> <output.pdf>
set -euo pipefail

IN="${1:?usage: render-pdf.sh <input.html> <output.pdf>}"
OUT="${2:?usage: render-pdf.sh <input.html> <output.pdf>}"
IN_ABS="$(cd "$(dirname "$IN")" && pwd)/$(basename "$IN")"

CHROME="${CHROME:-}"
if [[ -z "$CHROME" ]]; then
  for candidate in \
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
    "/snap/bin/chromium" \
    "/usr/bin/google-chrome" \
    "/usr/bin/chromium" \
    "/usr/bin/chromium-browser"; do
    if [[ -x "$candidate" ]]; then CHROME="$candidate"; break; fi
  done
fi

if [[ -z "$CHROME" ]]; then
  echo "No Chrome/Chromium found. Install Chrome, or set CHROME=/path/to/browser." >&2
  echo "Falling back to wkhtmltopdf if available..." >&2
  if command -v wkhtmltopdf >/dev/null 2>&1; then
    wkhtmltopdf --margin-top 15mm --margin-bottom 15mm --margin-left 15mm --margin-right 15mm "$IN_ABS" "$OUT"
    echo "Rendered (wkhtmltopdf): $OUT"
    exit 0
  fi
  exit 127
fi

PROF="$(mktemp -d /tmp/resume-kit-pdf.XXXXXX)"
trap 'rm -rf "$PROF"' EXIT

"$CHROME" \
  --headless=new --disable-gpu --no-pdf-header-footer \
  --virtual-time-budget=3000 \
  --user-data-dir="$PROF" \
  --print-to-pdf="$OUT" \
  "file://${IN_ABS}" >/dev/null 2>&1

if command -v pdfinfo >/dev/null 2>&1; then
  echo "Rendered: $OUT"
  pdfinfo "$OUT" | grep -E "Pages|Page size"
else
  echo "Rendered: $OUT"
fi
