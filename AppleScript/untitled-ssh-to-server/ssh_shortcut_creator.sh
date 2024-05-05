#!/bin/bash

# Configuration
appName="" # Leave empty, will be set based on hostname
appDir="/Applications"
iconPath="" # Optional: Default path to an icon file (.icns) to use for all shortcuts
addToDock=1 # Optional: Set to 1 to add the shortcut to the Dock

# Function to check if dockutil is installed
check_dockutil() {
    if ! command -v dockutil &> /dev/null; then
        echo "dockutil could not be found, installing it now..."
        brew install dockutil
    fi
}

# Function to display usage
usage() {
    echo "Usage: $0 -h <hostname> [-u <username>] [-i <icon path>] [-d]"
    echo "  -h <hostname>   Specify the hostname for the SSH connection."
    echo "  -u <username>   Specify the username for the SSH connection. Optional."
    echo "  -i <icon path>  Specify a custom icon for the shortcut. Optional."
    echo "  -d              Delete the specified shortcut. Optional."
    exit 1
}

# Function to parse command line options
parse_options() {
    while (( "$#" )); do
        case "$1" in
            -h|--hostname)
                hostname=$2
                appName="SSH to ${hostname}.app"
                shift 2
                ;;
            -u|--username)
                username=$2
                shift 2
                ;;
            --no-dock)
                addToDock=0
                shift
                ;;
            -i|--icon)
                iconPath=$2
                shift 2
                ;;
            -d|--delete)
                deleteMode=1
                shift
                ;;
            -*|--*=) # unsupported flags
                echo "Error: Unsupported flag $1" >&2
                exit 1
                ;;
            *) # preserve positional arguments
                PARAMS="$PARAMS $1"
                shift
                ;;
        esac
    done
    # Check required arguments
    if [ -z "${hostname}" ]; then
        usage
    fi
}

# Function to add the app to the Dock
addToDock() {
    local appPath="$1"
    # Convert to absolute path if necessary
    if [[ ! "$appPath" = /* ]]; then
        appPath="$PWD/$appPath"
    fi
    # Use dockutil to add the app to the Dock at position 1
    dockutil --add "$appPath" --position 1 --no-restart
    # Restart the Dock to apply changes
    killall Dock
}

# Function to delete the shortcut
delete_shortcut() {
    echo "Deleting shortcut for ${hostname}..."
    rm -rf "${appDir}/${appName}"
    echo "Shortcut deleted."
}

# Function to create or update the shortcut
create_update_shortcut() {
    echo "Creating/updating shortcut for ${hostname}..."
    
    # Generate AppleScript content
    scriptContent="tell application \"iTerm\"
    create window with default profile command \"ssh ${username:+$username@}${hostname}\"
    activate
    end tell"

    # Write the script to a temporary file
    scriptFile=$(mktemp)
    echo "${scriptContent}" > "${scriptFile}"

    # Compile the AppleScript into an application
    osacompile -o "${appDir}/${appName}" "${scriptFile}"

    # Set a custom icon if specified
    if [ -n "${iconPath}" ] && [ -f "${iconPath}" ]; then
        cp "${iconPath}" "${appDir}/${appName}/Contents/Resources/applet.icns"
    else
        echo "Icon path is invalid or not specified. Skipping icon customization."
    fi

    # Check if addToDock flag is set and call the function
    if [ "${addToDock}" ]; then
        addToDock "${appDir}/${appName}"
    fi

    echo "Shortcut created/updated at ${appDir}/${appName}"
}

# Main logic
check_dockutil
parse_options "$@"
if [ "${deleteMode}" ]; then
    delete_shortcut
else
    create_update_shortcut
fi
