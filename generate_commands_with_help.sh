#!/usr/bin/env bash
# Generate per-letter files with "command - short description"
# Uses `whatis` (same as `man -f`) and normalizes the format.

set -euo pipefail
export LC_ALL=C

OUTPUT_DIR="commands_with_help"
mkdir -p "$OUTPUT_DIR"

for L in {a..z}; do
  outfile="${OUTPUT_DIR}/commands_${L}.txt"
  : > "$outfile"   # truncate/create

  # List unique commands starting with $L, then get one-line help
  while IFS= read -r cmd; do
    if line=$(LANG=C whatis "$cmd" 2>/dev/null | head -n1); then
      # Normalize: drop section "(1)", "(8)", etc. → "cmd - description"
      echo "$line" | sed -E 's/ \([^)]*\) - / - /I' >> "$outfile"
    else
      echo "$cmd - (no manual entry)" >> "$outfile"
    fi
  done < <(compgen -c "$L" | sort -u)

  echo "Generated $outfile ($(wc -l < "$outfile") commands)"
done
