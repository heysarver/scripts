#!/bin/bash

# macOS only

# Initialize the disk variable
disk=""

# Parse command-line options
while getopts "d:" opt; do
  case ${opt} in
    d)
      disk=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" 1>&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." 1>&2
      exit 1
      ;;
  esac
done

# If no disk is specified, find the device node for the CD-ROM
if [[ -z $disk ]]; then
  disk=$(diskutil list | grep -o '/dev/disk[[:digit:]]*s[[:digit:]]*(CDROM|DVD)')
fi

# If the device node is not found, exit the script
if [[ -z $disk ]]; then
    echo "No disk found."
    exit 1
fi

# Get the volume name of the disk
volume_name=$(diskutil info $disk | awk '/Volume Name/ {print substr($0, index($0,$3))}')

# If the volume name is not found, use a default name for the ISO
if [[ -z $volume_name ]]; then
    volume_name="Untitled"
fi

# Replace spaces with underscores in the volume name for the ISO file name
iso_name="${volume_name// /_}"

# Unmount the disk
diskutil unmountDisk $disk

# Create an ISO image on the Desktop with the same name as the disk label
output_path="${HOME}/Desktop/${iso_name}.iso"
dd if=$disk of="$output_path" bs=2048

echo "ISO image created at $output_path"
