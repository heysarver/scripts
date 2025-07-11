#!/bin/bash

# Update this to be parameterized

# DNS Record Cleanup Script for DigitalOcean
# This script identifies and removes duplicate DNS records

DOMAIN="sarvent.net"
DRY_RUN=false  # Set to false to actually delete records

echo "=== DNS Record Cleanup for $DOMAIN ==="
echo "DRY_RUN mode: $DRY_RUN"
echo ""

# Function to delete a record
delete_record() {
    local record_id=$1
    local record_name=$2
    local record_type=$3
    local record_data=$4
    
    if [ "$DRY_RUN" = true ]; then
        echo "DRY RUN: Would delete record ID $record_id ($record_type $record_name -> $record_data)"
    else
        echo "Deleting record ID $record_id ($record_type $record_name -> $record_data)"
        doctl compute domain records delete $DOMAIN $record_id --force
        if [ $? -eq 0 ]; then
            echo "✓ Successfully deleted record $record_id"
        else
            echo "✗ Failed to delete record $record_id"
        fi
    fi
}

# Get all records and save to temp file
echo "Fetching current DNS records..."
doctl compute domain records list $DOMAIN --format ID,Type,Name,Data,TTL --no-header > /tmp/dns_records.txt

# Find duplicate home records (keeping the first one of each type)
echo ""
echo "=== Analyzing 'home' A records ==="
home_records=$(grep -E "^\s*[0-9]+\s+A\s+home\s+98\.163\.9\.172" /tmp/dns_records.txt)
if [ ! -z "$home_records" ]; then
    echo "Found home A records:"
    echo "$home_records"
    echo ""
    
    # Keep the first record, delete the rest
    first_record=true
    while IFS= read -r line; do
        if [ ! -z "$line" ]; then
            record_id=$(echo "$line" | awk '{print $1}')
            record_type=$(echo "$line" | awk '{print $2}')
            record_name=$(echo "$line" | awk '{print $3}')
            record_data=$(echo "$line" | awk '{print $4}')
            
            if [ "$first_record" = true ]; then
                echo "KEEPING: Record ID $record_id ($record_type $record_name -> $record_data)"
                first_record=false
            else
                delete_record "$record_id" "$record_name" "$record_type" "$record_data"
            fi
        fi
    done <<< "$home_records"
fi

echo ""
echo "=== Analyzing '*.home' A records ==="
wildcard_home_records=$(grep -E "^\s*[0-9]+\s+A\s+\*\.home\s+98\.163\.9\.172" /tmp/dns_records.txt)
if [ ! -z "$wildcard_home_records" ]; then
    echo "Found *.home A records:"
    echo "$wildcard_home_records"
    echo ""
    
    # Keep the first record, delete the rest
    first_record=true
    while IFS= read -r line; do
        if [ ! -z "$line" ]; then
            record_id=$(echo "$line" | awk '{print $1}')
            record_type=$(echo "$line" | awk '{print $2}')
            record_name=$(echo "$line" | awk '{print $3}')
            record_data=$(echo "$line" | awk '{print $4}')
            
            if [ "$first_record" = true ]; then
                echo "KEEPING: Record ID $record_id ($record_type $record_name -> $record_data)"
                first_record=false
            else
                delete_record "$record_id" "$record_name" "$record_type" "$record_data"
            fi
        fi
    done <<< "$wildcard_home_records"
fi

# Look for other potential duplicates
echo ""
echo "=== Checking for other duplicate records ==="

# Group records by type, name, and data to find duplicates
awk '{print $2 " " $3 " " $4}' /tmp/dns_records.txt | sort | uniq -d > /tmp/duplicate_patterns.txt

if [ -s /tmp/duplicate_patterns.txt ]; then
    echo "Found other duplicate patterns:"
    cat /tmp/duplicate_patterns.txt
    echo ""
    
    while IFS= read -r pattern; do
        if [ ! -z "$pattern" ]; then
            record_type=$(echo "$pattern" | awk '{print $1}')
            record_name=$(echo "$pattern" | awk '{print $2}')
            record_data=$(echo "$pattern" | awk '{print $3}')
            
            # Skip home records as we already handled them
            if [[ "$record_name" == "home" || "$record_name" == "*.home" ]]; then
                continue
            fi
            
            echo "Duplicate pattern found: $record_type $record_name -> $record_data"
            
            # Find all records matching this pattern
            matching_records=$(grep -E "^\s*[0-9]+\s+$record_type\s+$record_name\s+$record_data" /tmp/dns_records.txt)
            
            # Keep the first, delete the rest
            first_record=true
            while IFS= read -r line; do
                if [ ! -z "$line" ]; then
                    record_id=$(echo "$line" | awk '{print $1}')
                    
                    if [ "$first_record" = true ]; then
                        echo "KEEPING: Record ID $record_id"
                        first_record=false
                    else
                        delete_record "$record_id" "$record_name" "$record_type" "$record_data"
                    fi
                fi
            done <<< "$matching_records"
            echo ""
        fi
    done < /tmp/duplicate_patterns.txt
else
    echo "No other duplicate patterns found."
fi

# Cleanup temp files
rm -f /tmp/dns_records.txt /tmp/duplicate_patterns.txt

echo ""
echo "=== Summary ==="
if [ "$DRY_RUN" = true ]; then
    echo "This was a DRY RUN. No records were actually deleted."
    echo "To actually delete the duplicate records, set DRY_RUN=false in the script."
else
    echo "Cleanup completed. Run 'doctl compute domain records list $DOMAIN' to verify."
fi

echo ""
echo "Script completed!"
