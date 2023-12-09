#!/bin/bash

# Function to detect OS family
detect_os_family() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if type lsb_release &> /dev/null; then
            os_family=$(lsb_release -is)
        elif [ -f /etc/os-release ]; then
            . /etc/os-release
            os_family=$ID
        else
            os_family="linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        os_family="macos"
    else
        os_family="unknown"
    fi
    echo $os_family
}

echo "Starting script..."

# Check if a command argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <command>"
    exit 1
fi

# The command to find
command_to_find=$1

echo "Command to find: $command_to_find"

# Detect the OS family
os_family=$(detect_os_family | tr '[:upper:]' '[:lower:]')
echo "Detected OS family: $os_family"

# URL of the command-not-found website
url="https://command-not-found.com/$command_to_find"
echo "Fetching data from URL: $url"

# Use curl to download the webpage
response=$(curl -s "$url")

# Debug: Print all possible installation commands using awk/sed
echo "All possible installation commands found:"
echo "$response" | awk '/sudo apt-get install|sudo dnf install|sudo pacman -S|brew install/ { print $0 }' | sed -n 's/.*<code>\(.*\)<\/code>.*/\1/p'

# Extract the installation command based on OS family
echo "Selecting appropriate installation command for OS family..."
case $os_family in
    ubuntu | debian | linux)
        install_command=$(echo "$response" | awk '/sudo apt-get install/ { print $0 }' | sed -n 's/.*<code>\(.*\)<\/code>.*/\1/p' | head -1)
        ;;
    fedora | centos | rhel)
        install_command=$(echo "$response" | awk '/sudo dnf install/ { print $0 }' | sed -n 's/.*<code>\(.*\)<\/code>.*/\1/p' | head -1)
        ;;
    arch | manjaro)
        install_command=$(echo "$response" | awk '/sudo pacman -S/ { print $0 }' | sed -n 's/.*<code>\(.*\)<\/code>.*/\1/p' | head -1)
        ;;
    macos)
        install_command=$(echo "$response" | awk '/brew install/ { print $0 }' | sed -n 's/.*<code>\(.*\)<\/code>.*/\1/p' | head -1)
        ;;
    *)
        echo "OS family '$os_family' not supported by this script."
        exit 1
        ;;
esac

# Check if an installation command was found
if [ -z "$install_command" ]; then
    echo "No installation command found for '$command_to_find' on OS family '$os_family'"
    exit 1
fi

# Output the installation command
echo "Installation command for '$command_to_find' on $os_family:"
echo "$install_command"
