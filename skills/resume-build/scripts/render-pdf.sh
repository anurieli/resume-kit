#!/usr/bin/env bash
# Render a resume HTML file to PDF via headless Chrome. No npm deps.
# Usage: render-pdf.sh <input.html> <output.pdf>
#
# Headless Chrome (--headless=new) reliably writes the PDF but can hang
# around afterward instead of exiting on its own, so instead of waiting on
# the process we poll for the output file to appear and its size to settle,
# then kill Chrome ourselves. Caps at MAX_WAIT seconds either way.
set -euo pipefail

IN="${1:?usage: render-pdf.sh <input.html> <output.pdf>}"
OUT="${2:?usage: render-pdf.sh <input.html> <output.pdf>}"
IN_ABS="$(cd "$(dirname "$IN")" && pwd)/$(basename "$IN")"
MAX_WAIT="${MAX_WAIT:-20}"

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
rm -f "$OUT"

"$CHROME" \
  --headless=new --disable-gpu --no-pdf-header-footer \
  --virtual-time-budget=3000 \
  --user-data-dir="$PROF" \
  --print-to-pdf="$OUT" \
  "file://${IN_ABS}" >/dev/null 2>&1 &
CHROME_PID=$!
disown "$CHROME_PID" 2>/dev/null || true

# Poll for the PDF to appear and its size to stop changing (two consecutive
# equal reads), rather than waiting on the process to exit.
elapsed=0
last_size=-1
stable_size=-1
while (( elapsed < MAX_WAIT )); do
  sleep 1
  elapsed=$((elapsed + 1))
  if [[ -f "$OUT" ]]; then
    size=$(stat -f%z "$OUT" 2>/dev/null || stat -c%s "$OUT" 2>/dev/null || echo 0)
    if [[ "$size" == "$last_size" && "$size" -gt 0 ]]; then
      stable_size="$size"
      break
    fi
    last_size="$size"
  fi
done

# Clean up Chrome regardless of whether it exited on its own.
kill -9 "$CHROME_PID" 2>/dev/null || true
pkill -9 -f "user-data-dir=$PROF" 2>/dev/null || true
rm -rf "$PROF"

if [[ ! -f "$OUT" ]]; then
  echo "Render failed: no output produced within ${MAX_WAIT}s." >&2
  exit 1
fi

if command -v pdfinfo >/dev/null 2>&1; then
  echo "Rendered: $OUT"
  pdfinfo "$OUT" | grep -E "Pages|Page size"
else
  echo "Rendered: $OUT"
fi
