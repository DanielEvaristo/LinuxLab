#!/usr/bin/env bash
# Generate files with commands beginning with each letter (a..z)
# Use compgen -c <prefix> and save in commands_starting_with_<letter>.txt

set -euo pipefail
export LC_ALL=C

# Folder where all the files will be stored
OUTPUT_DIR="commands_by_letter"

# Create the folder
mkdir -p "$OUTPUT_DIR"

for L in {a..z}; do
  outfile="${OUTPUT_DIR}/commands_starting_with_${L}.txt"  # English file name

  # List all the commands known to the shell that start with $L, then sort & deduplicate.
  # Includes PATH executables, builtins, functions, and aliases.
  compgen -c "$L" | sort -u > "$outfile"

  # Print a short summary: number of lines and the file name.
  printf "%5d %s\n" "$(wc -l < "$outfile")" "$outfile"
done
