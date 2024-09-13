#!/bin/bash

# Script to create a bootable USB installer for macOS
# Usage: ./create_macos_usb.sh /path/to/macos-installer.iso

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 /path/to/macos-installer.iso"
    exit 1
fi

ISO_FILE="$1"

if [ ! -f "$ISO_FILE" ]; then
    echo "Error: ISO file '$ISO_FILE' not found."
    exit 1
fi

echo "-------------------------------------------"
echo "           macOS USB Creator               "
echo "-------------------------------------------"
echo

echo "Available disks:"
DISKS=($(diskutil list | grep '^/dev/disk' | awk '{print $1}'))

i=1
for disk in "${DISKS[@]}"; do
    disk_info=$(diskutil info "$disk" | grep -E 'Device / Media Name|Media Name|Volume Name|Disk Size' | awk -F': ' '{print $2}' | tr '\n' ' - ')
    echo "$i) $disk - $disk_info"
    ((i++))
done
echo

read -p "Enter the number of the disk to use as the USB installer: " selection

if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt "${#DISKS[@]}" ]; then
    echo "Invalid selection."
    exit 1
fi

selected_disk="${DISKS[$((selection-1))]}"

echo
echo "You have selected $selected_disk."
diskutil info "$selected_disk" | grep -E 'Device Identifier|Device Node|Media Name|Volume Name|Disk Size'

echo
echo "**** WARNING ****"
echo "All data on this disk will be erased!"
read -p "Are you sure you want to proceed? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Operation cancelled."
    exit 1
fi

echo
echo "Unmounting disk..."
diskutil unmountDisk "$selected_disk"

raw_disk=$(echo "$selected_disk" | sed 's/disk/rdisk/')

echo
echo "Writing ISO to USB drive. This may take some time..."
sudo dd if="$ISO_FILE" of="$raw_disk" bs=1m conv=sync status=progress

echo
echo "Ejecting disk..."
diskutil eject "$selected_disk"

echo
echo "-------------------------------------------"
echo "     Bootable macOS USB Installer Created  "
echo "-------------------------------------------"
echo "You can now use the USB drive to install macOS."
