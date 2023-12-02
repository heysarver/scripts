#!/bin/sh

# Check if URL is provided
if [ -z "$1" ]
then
    echo "No URL provided. Usage: ./wget_download.sh <url>"
    exit 1
fi

# Download file from provided URL
wget --content-disposition "$1"
