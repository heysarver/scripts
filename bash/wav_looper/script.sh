#!/bin/bash

# /script.sh

# Function to display usage information
usage() {
    echo "Usage: $0 --input file1.wav file2.wav file3.wav --output output.wav --length 1 [--compress mp3]"
    exit 1
}

# Function to sanitize file paths
sanitize_path() {
    echo "$1" | sed 's/[^a-zA-Z0-9._-]/_/g'
}

# Parse command-line arguments
INPUT_FILES=()
OUTPUT_FILE=""
LENGTH=0
COMPRESS=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --input)
            shift
            while [[ "$#" -gt 0 && "$1" != --* ]]; do
                INPUT_FILES+=("$(sanitize_path "$1")")
                shift
            done
            ;;
        --output)
            OUTPUT_FILE=$(sanitize_path "$2")
            shift 2
            ;;
        --length)
            LENGTH=$2
            shift 2
            ;;
        --compress)
            COMPRESS=$2
            shift 2
            ;;
        *)
            usage
            ;;
    esac
done

# Validate input arguments
if [[ ${#INPUT_FILES[@]} -eq 0 || -z "$OUTPUT_FILE" || -z "$LENGTH" ]]; then
    usage
fi

# Convert length from minutes to seconds
LENGTH=$(echo "$LENGTH * 60" | bc)

# Create a temporary file to hold the concatenated audio
TEMP_FILE=$(mktemp /tmp/concatenated.XXXXXX.wav)

# Concatenate all input files into one temporary file
for file in "${INPUT_FILES[@]}"; do
    ffmpeg -y -i "$file" -c copy -f wav - | cat >> "$TEMP_FILE"
done

# Check if the concatenation was successful
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to concatenate input files."
    rm -f "$TEMP_FILE"
    exit 1
fi

# Calculate the duration of the concatenated file
DURATION=$(ffprobe -i "$TEMP_FILE" -show_entries format=duration -v quiet -of csv="p=0")

# Calculate the number of loops needed
LOOPS=$(echo "($LENGTH / $DURATION) + 1" | bc)

# Create a looped file
LOOPED_FILE=$(mktemp /tmp/looped.XXXXXX.wav)
ffmpeg -y -stream_loop "$LOOPS" -i "$TEMP_FILE" -c copy "$LOOPED_FILE"

# Check if looping was successful
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to loop the concatenated file."
    rm -f "$TEMP_FILE" "$LOOPED_FILE"
    exit 1
fi

# Determine output format
if [[ "$COMPRESS" == "mp3" ]]; then
    OUTPUT_FILE="${OUTPUT_FILE%.*}.mp3"
    ffmpeg -y -i "$LOOPED_FILE" -c:a libmp3lame -b:a 192k "$OUTPUT_FILE"
else
    ffmpeg -y -i "$LOOPED_FILE" -c copy "$OUTPUT_FILE"
fi

# Check if output file creation was successful
if [[ $? -ne 0 ]]; then
    echo "Error: Failed to create the output file."
    rm -f "$TEMP_FILE" "$LOOPED_FILE"
    exit 1
fi

# Clean up temporary files
rm -f "$TEMP_FILE" "$LOOPED_FILE"

echo "Output file created: $OUTPUT_FILE"
