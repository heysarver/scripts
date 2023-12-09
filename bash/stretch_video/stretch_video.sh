#!/bin/bash

# Function to generate a random start time for a 5-minute clip
generate_random_start_time() {
    local duration=$1
    local max_start=$((duration - 300)) # 5 minutes in seconds
    if [ $max_start -le 0 ]; then
        echo 0
    else
        echo $((RANDOM % max_start))
    fi
}

# Check if ffmpeg is installed and supports NVIDIA hardware acceleration
if ! ffmpeg -hide_banner -hwaccels | grep -q "cuda"; then
    echo "ffmpeg does not support NVIDIA hardware acceleration or is not installed."
    exit 1
fi

# Initialize preview flag
preview=false

# Parse command line options
while getopts ":p" opt; do
    case $opt in
        p)
            preview=true
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

# Remove the parsed options from the positional parameters
shift $((OPTIND -1))

# Check the number of arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 [-p] <input_video> <desired_aspect_ratio> <output_filename>"
    exit 1
fi

input_video="$1"
desired_aspect_ratio="$2"
output_filename="$3"

# Extract the original width, height, and duration using ffprobe
width=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=p=0 "$input_video")
height=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=p=0 "$input_video")
duration=$(ffprobe -v error -select_streams v:0 -show_entries format=duration -of csv=p=0 "$input_video")
duration=${duration%.*} # Convert to integer

# Calculate the new width and height based on the desired aspect ratio
aspect_ratio=$(echo $desired_aspect_ratio | awk -F: '{print $1/$2}')
new_width=$(echo "$height * $aspect_ratio" | bc)
new_width=${new_width%.*} # Convert to integer

# Ensure new width is divisible by 2
if [ $((new_width%2)) -eq 1 ]; then
    new_width=$((new_width-1))
fi

# If preview is requested, generate a random start time and set the duration to 5 minutes
if [ "$preview" = true ]; then
    start_time=$(generate_random_start_time $duration)
    ffmpeg_cmd="ffmpeg -hwaccel cuda -hwaccel_output_format cuda -ss $start_time -t 300 -i"
else
    ffmpeg_cmd="ffmpeg -hwaccel cuda -hwaccel_output_format cuda -i"
fi

# Stretch the video to the new width and height using NVIDIA hardware acceleration with scale_npp
# The map option is used to ensure all audio tracks are copied
$ffmpeg_cmd "$input_video" \
    -vf "scale_npp=$new_width:$height" -c:v h264_nvenc \
    -map 0:v -map 0:a? -c:a copy "$output_filename"

echo "Video has been processed with NVIDIA CUDA and saved to '$output_filename'"
