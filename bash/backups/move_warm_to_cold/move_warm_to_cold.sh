#!/bin/bash

# Usage: ./script.sh [<source_dir> <destination_dir> [<days>]]

SOURCE_DIR="${1:-$SOURCE_DIR}"
DESTINATION_DIR="${2:-$DESTINATION_DIR}"
DAYS="${3:-${DAYS:-365}}"

if [ -z "$ " ]; then
    echo "Error: source_dir is not set. Please set it as an argument or as an environment variable."
    exit 1
fi

if [ -z "$DESTINATION_DIR" ]; then
    echo "Error: destination_dir is not set. Please set it as an argument or as an environment variable."
    exit 1
fi

SOURCE_DIR=$(echo "$SOURCE_DIR" | sed "s/'/'\"'\"'/g")
DESTINATION_DIR=$(echo "$DESTINATION_DIR" | sed "s/'/'\"'\"'/g")

find "$SOURCE_DIR" -type f -atime +"$DAYS" -exec mv {} "$DESTINATION_DIR" \;
