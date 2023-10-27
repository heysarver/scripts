#!/bin/bash

# Variables
CREDENTIALS_FILE="credentials.txt"
FOLDER_PATH="/Volumes/$(awk 'NR==4{print $1}' $CREDENTIALS_FILE)"
SERVER_URL="smb://$(awk 'NR==3{print $1}' $CREDENTIALS_FILE)/$(awk 'NR==4{print $1}' $CREDENTIALS_FILE)"
MAX_ATTEMPTS=3
WAIT_TIME=3600 # 1 hour in seconds

# Function to check if folder is mounted
is_mounted() {
    [[ $(mount | grep "on ${FOLDER_PATH}") == *"${FOLDER_PATH}"* ]]
}

# Function to mount folder
mount_folder() {
    USERNAME=$(awk 'NR==1{print $1}' $CREDENTIALS_FILE)
    PASSWORD=$(awk 'NR==2{print $1}' $CREDENTIALS_FILE)
    SERVER=$(awk 'NR==3{print $1}' $CREDENTIALS_FILE)
    FOLDER=$(awk 'NR==4{print $1}' $CREDENTIALS_FILE)
    open -a Finder "smb://$USERNAME:$PASSWORD@$SERVER/$FOLDER"
}

# Main loop
while true; do
    if ! is_mounted; then
        echo "Folder is not mounted. Trying to mount..."
        ATTEMPTS=0

        until is_mounted || [ $ATTEMPTS -eq $MAX_ATTEMPTS ]; do
            let ATTEMPTS++
            echo "Attempt $ATTEMPTS..."
            mount_folder
            sleep 5 # Wait for a while before checking again
        done

        if ! is_mounted; then
            echo "Failed to mount folder after $MAX_ATTEMPTS attempts. Waiting for $WAIT_TIME seconds before trying again..."
        fi
    fi

    sleep $WAIT_TIME
done
