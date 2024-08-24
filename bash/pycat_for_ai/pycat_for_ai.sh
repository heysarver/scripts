#!/bin/bash

pycat_for_ai () {

    local target_dir="${1:-$(pwd)}"
    shift
    local excludes=(
        '*/.git/*'
        '*/venv/*'
        '*/.venv/*'
        '*.env'
        '*/__pycache__/*'
        '*.pyc'
        '*/repos/*'
        '*/.*/*'
        '.*'
    )

    # Read excludes from environment variable PYCAT_EXCLUDE
    if [ -n "$PYCAT_EXCLUDE" ]; then
        IFS=',' read -ra env_excludes <<< "$PYCAT_EXCLUDE"
        excludes+=("${env_excludes[@]}")
    fi

    # Process additional excludes from command-line arguments
    while [[ "$1" =~ ^(-e|--exclude)$ ]]; do
        shift
        excludes+=("$1")
        shift
    done

    # Construct the find command
    local find_excludes=()
    for exclude in "${excludes[@]}"; do
        find_excludes+=(! -path "$exclude")
    done

    echo "\n---\n"
    find "$target_dir" -type f "${find_excludes[@]}" -exec sh -c '
        for file; do
            if ! file --mime "$file" | grep -q "binary"; then
                echo "==> $file <==\n"
                cat "$file"
                echo "\n---\n"
            fi
        done
    ' sh {} +
}
