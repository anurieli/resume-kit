#!/usr/bin/env bash
# Scaffold a resume-kit data directory and point the global config at it.
# Usage: init.sh <data_dir>
set -euo pipefail

DATA_DIR="${1:?usage: init.sh <data_dir>}"
DATA_DIR="$(cd "$(dirname "$DATA_DIR")" 2>/dev/null && pwd)/$(basename "$DATA_DIR")" || DATA_DIR="$1"

CONFIG_DIR="$HOME/.config/resume-kit"
CONFIG_FILE="$CONFIG_DIR/config.yaml"

mkdir -p "$DATA_DIR/inbox" "$DATA_DIR/output"
mkdir -p "$CONFIG_DIR"

if [[ ! -f "$DATA_DIR/career.yaml" ]]; then
  cat > "$DATA_DIR/career.yaml" <<'EOF'
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
  echo "Created $DATA_DIR/career.yaml (empty scaffold)"
else
  echo "career.yaml already exists at $DATA_DIR, left untouched"
fi

if [[ ! -f "$DATA_DIR/inbox/README.md" ]]; then
  cat > "$DATA_DIR/inbox/README.md" <<'EOF'
# inbox

Drop raw material here for resume-ingest to process:
- old resumes (PDF, DOCX, TXT, MD)
- LinkedIn "Download your data" export
- cover letters
- job postings you've already applied to (useful context, even old ones)

Run the resume-ingest skill after adding files. Processed files are moved
to inbox/processed/ so re-runs don't re-ingest the same material.
EOF
fi

cat > "$CONFIG_FILE" <<EOF
data_dir: $DATA_DIR
EOF

echo "Config written: $CONFIG_FILE -> data_dir: $DATA_DIR"
