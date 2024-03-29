#!/bin/bash

extract_and_compress() {
    local initial_file=$1
    local temp_dir=$(mktemp -d)

    extract_file() {
        local file=$1
        local destination=$2

        case $file in
            *.zip)
                unzip -q "$file" -d "$destination"
                ;;
            *.tar.gz)
                tar -xzf "$file" -C "$destination"
                ;;
            *.gz)
                local out_file=$(basename "${file%.gz}")
                gunzip -c "$file" > "$destination/$out_file"
                ;;
            *.tar)
                tar -xf "$file" -C "$destination"
                ;;
            *)
                echo "Cannot extract $file: Unknown type"
                return
                ;;
        esac

        local nested_files=$(find "$destination" \( -name '*.zip' -o -name '*.tar.gz' -o -name '*.gz' -o -name '*.tar' \))

        for nested_file in $nested_files; do
            extract_file "$nested_file" "$(dirname "$nested_file")"
            rm "$nested_file"
        done
    }

    extract_file "$initial_file" "$temp_dir"
    zip -qr "${initial_file%.*}_recompressed.zip" "$temp_dir"
    rm -r "$temp_dir"
}
