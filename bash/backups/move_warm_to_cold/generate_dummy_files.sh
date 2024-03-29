#!/bin/bash

# Usage: ./generate_dummy_files.sh [<output_directory>]

OUTPUT_DIRECTORY="${1:-./src}"

mkdir -p "$OUTPUT_DIRECTORY"

for month in {01..12}; do
    for year in {2021..2023}; do
        filename="${OUTPUT_DIRECTORY}/${year}-${month}.txt"
        touch "$filename"
        timestamp="${year}-${month}-01 00:00:00"
        touch -t $(date -j -f "%Y-%m-%d %H:%M:%S" "$timestamp" +"%Y%m%d%H%M.%S") "$filename"
    done
done
