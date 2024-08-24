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

    # Normalize target_dir to an absolute path
    target_dir=$(cd "$target_dir" && pwd)

    # Construct the find command
    local find_excludes=()
    for exclude in "${excludes[@]}"; do
        find_excludes+=(-not -path "$exclude")
    done

    # Debug: Print target directory and find command
    echo "Target Directory: $target_dir"
    echo "Find Excludes: ${find_excludes[@]}"

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

# If the script is being run directly, call the function with the provided arguments
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    pycat_for_ai "$@"
fi
