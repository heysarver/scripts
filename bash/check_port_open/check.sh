#!/bin/bash

# Determine OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    echo -e "HTTP/1.1 200 OK\n\n Welcome to my dummy service" | nc -l -p $1 & 
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS\
    echo -e "HTTP/1.1 200 OK\n\n Welcome to my dummy service" | nc -l $1 & 
else
    # Other
    echo "Unsupported OS"
    exit 1
fi

echo "Checking..."

# Run curl command
output=$(curl -s -d port="$1" https://canyouseeme.org)

# Clear line and print result
printf "\r"
echo $output | grep -o 'Success\|Error'
