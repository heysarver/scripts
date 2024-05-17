#!/bin/bash

# Function to check if command exists
command_exists () {
    type "$1" &> /dev/null ;
}

# Function to generate bcrypt hash
generate_bcrypt_hash() {
    local password=$1
    if command_exists htpasswd; then
        # Hash the password with bcrypt using the htpasswd utility
        # The username is set to 'user' but it doesn't affect the hash
        hash=$(echo -n "$password" | htpasswd -inB user)
        # Remove the 'user:' prefix from the output
        echo "${hash#*:}"
    else
        return 1
    fi
}

# Prompt user for password
echo "Enter your password:"
IFS= read -r -s password
echo  # Add a newline since the user's input doesn't end with a new line

# Generate bcrypt hash from the password
hash=$(generate_bcrypt_hash "$password")

# Check if bcrypt hash was generated successfully
if [ $? -eq 1 ]; then
    echo "Error: bcrypt is not installed. Please install bcrypt and try again."
    exit 1
fi

# Check OS and connection method
if [[ "$OSTYPE" == "darwin"* && -z "$SSH_CLIENT" && -z "$SSH_TTY" ]]; then
    # Running locally on macOS
    if command_exists pbcopy; then
        echo "$hash" | pbcopy
        echo "The bcrypt hash has been copied to your clipboard."
    else
        echo "pbcopy not found, falling back to terminal output:"
        echo -e "\n$hash\n"
    fi
else
    # Non-macOS platforms or being accessed via SSH
    echo -e "\n$hash\n"
fi
