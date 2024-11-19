#!/usr/bin/env bash

# This script generates a CODEOWNERS file from meta.yml files
# It extracts the "authors" array from each meta.yml file and
# formats it into the CODEOWNERS file for use in a GitHub repository.

# Function to log messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Get all of the meta.yml files
log "Searching for meta.yml files..."
METAS=$(fdfind meta.yml)

if [ -z "$METAS" ]; then
    log "No meta.yml files found."
    exit 1
else
    log "Found the following meta.yml files:"
    echo "$METAS"
fi

# Define the output file path
output_file=".github/CODEOWNERS-tmp"

# Check if the output file already exists before attempting to remove it
if [ -f "$output_file" ]; then
    log "Removing existing temporary output file: $output_file"
    rm "$output_file"
fi

# Use yq to extract the "authors" array and convert it to a .gitignore format
for file in $METAS; do
    log "Processing file: $file"

    # Print the directory the file is in first
    path=$(echo "$file" | sed 's/\/meta.yml//')
    # Add a double star to the end of the path
    path="$path/**"

    # Extract authors from the YAML file
    authors=$(yq '.authors | .[]' "$file" | sed 's/^//')

    # Remove quotes from authors
    authors=$(echo "$authors" | sed 's/"//g')

    # Append the path and authors to the output file
    if [ -n "$authors" ]; then
        log "Adding to output: $path $authors"
        echo "$path $authors" >> "$output_file"
    else
        log "No authors found in $file."
    fi
done

# Generate the CODEOWNERS file from a manual template
log "Generating CODEOWNERS file from manual template..."
if [ -f ".github/manual_CODEOWNERS" ]; then
    cat ".github/manual_CODEOWNERS" > ".github/CODEOWNERS"
    log "Manual CODEOWNERS template successfully included."
else
    log "Warning: .github/manual_CODEOWNERS file not found."
fi

# Remove duplicate lines, sort, and append to the CODEOWNERS file
if [ -f "$output_file" ]; then
    log "Processing temporary output file to remove duplicates..."
    cat "$output_file" | sort | uniq >> ".github/CODEOWNERS"
    log "Duplicates removed and appended to CODEOWNERS file."
else
    log "No temporary output file found to process."
fi

# Clean up by removing the temporary output file if it exists
if [ -f "$output_file" ]; then
    log "Cleaning up: removing temporary output file."
    rm "$output_file"
else
    log "Temporary output file not found; nothing to clean up."
fi

log "CODEOWNERS file generation completed."
