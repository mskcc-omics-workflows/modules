#!/usr/bin/env bash

# This script generates a CODEOWNERS file from meta.yml files
# It extracts the "authors" array from each meta.yml file and
# formats it into the CODEOWNERS file for use in a GitHub repository.

# Get all of the meta.yml files
METAS=$(fdfind meta.yml)

# Define the output file path
output_file=".github/CODEOWNERS-tmp"

# Check if the output file already exists before attempting to remove it
if [ -f "$output_file" ]; then
    rm "$output_file"
fi

# Use yq to extract the "authors" array and convert it to a .gitignore format
for file in $METAS; do
    # Print the directory the file is in first
    path=$(echo "$file" | sed 's/\/meta.yml//')
    # Add a double star to the end of the path
    path="$path/**"

    # Extract authors from the YAML file
    authors=$(yq '.authors | .[]' "$file" | sed 's/^//')

    # Remove quotes from authors
    authors=$(echo "$authors" | sed 's/"//g')

    # Append the path and authors to the output file
    echo "$path $authors" >> "$output_file"
done

# Generate the CODEOWNERS file from a manual template
if [ -f ".github/manual_CODEOWNERS" ]; then
    cat ".github/manual_CODEOWNERS" > ".github/CODEOWNERS"
else
    echo "Warning: .github/manual_CODEOWNERS file not found."
fi

# Remove duplicate lines, sort, and append to the CODEOWNERS file
if [ -f "$output_file" ]; then
    cat "$output_file" | sort | uniq >> ".github/CODEOWNERS"
fi

# Clean up by removing the temporary output file if it exists
if [ -f "$output_file" ]; then
    rm "$output_file"
fi
