#!/bin/bash

# Constants for the vendor IDs for NVIDIA and AMD
VENDOR_NVIDIA="10de"
VENDOR_AMD="1002"

# Function to bind GPU and its audio device to vfio-pci
bind_to_vfio() {
    local gpu_id="$1"
    local audio_id="${gpu_id%.*}.1" # Assuming the audio device is at the next function number
    local vendor_id="$2"

    # Unbind the GPU from the current driver
    echo "$gpu_id" > /sys/bus/pci/devices/"$gpu_id"/driver/unbind
    # Unbind the audio device from the current driver
    echo "$audio_id" > /sys/bus/pci/devices/"$audio_id"/driver/unbind

    # Bind the GPU to vfio-pci
    echo "$vendor_id" "$gpu_id" > /sys/bus/pci/drivers/vfio-pci/new_id
    # Bind the audio device to vfio-pci
    echo "$vendor_id" "$audio_id" > /sys/bus/pci/drivers/vfio-pci/new_id
}

# Function to rebind GPU and its audio device to their original drivers
rebind_to_host() {
    local gpu_id="$1"
    local audio_id="${gpu_id%.*}.1" # Assuming the audio device is at the next function number
    local driver="$2"

    # Unbind the GPU from vfio-pci
    echo "$gpu_id" > /sys/bus/pci/drivers/vfio-pci/unbind
    # Unbind the audio device from vfio-pci
    echo "$audio_id" > /sys/bus/pci/drivers/vfio-pci/unbind

    # Rebind the GPU to the original driver
    echo "$gpu_id" > /sys/bus/pci/drivers/"$driver"/bind
    # Attempt to rebind the audio device to snd_hda_intel
    echo "$audio_id" > /sys/bus/pci/drivers/snd_hda_intel/bind
}

# Check for root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

# Check for arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 {--bind|--unbind} <GPU_PCI_ID>"
    exit 1
fi

# Parse arguments
ACTION="$1"
GPU_PCI_ID="$2"

# Detect the vendor ID and appropriate driver for the GPU
VENDOR_ID=$(lspci -n -s "$GPU_PCI_ID" | awk '{print $3}' | cut -d ':' -f 1)
DRIVER=""
case "$VENDOR_ID" in
    "$VENDOR_NVIDIA")
        DRIVER="nvidia"
        ;;
    "$VENDOR_AMD")
        DRIVER=$(lspci -k -s "$GPU_PCI_ID" | grep 'Kernel driver in use' | awk '{print $5}')
        if [ "$DRIVER" != "amdgpu" ] && [ "$DRIVER" != "radeon" ]; then
            echo "Unsupported AMD driver: $DRIVER"
            exit 1
        fi
        ;;
    *)
        echo "Unsupported GPU vendor ID: $VENDOR_ID"
        exit 1
        ;;
esac

# Perform the action
case "$ACTION" in
    --bind)
        bind_to_vfio "$GPU_PCI_ID" "$VENDOR_ID"
        ;;
    --unbind)
        rebind_to_host "$GPU_PCI_ID" "$DRIVER"
        ;;
    *)
        echo "Invalid action: $ACTION"
        echo "Usage: $0 {--bind|--unbind} <GPU_PCI_ID>"
        exit 1
        ;;
esac

echo "Operation completed successfully."
