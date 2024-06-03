#!/bin/bash
# /scripts/cleanup_resources.sh

set -e

# Constants
readonly FORCE_DELETE_FLAG="--force-delete"

# Function to sanitize user input
sanitize_input() {
    local input="$1"
    echo "$input" | sed 's/[^a-zA-Z0-9_\-\*\.]//g'
}

# Function to list all resources by type with pattern matching
list_resources() {
    local pattern="$1"
    local resources=()

    # List namespaced resources
    for type in $(kubectl api-resources --verbs=list --namespaced -o name); do
        local matches=$(kubectl get "$type" --all-namespaces -o json 2>/dev/null | \
                        jq -r --arg pattern "$pattern" '[ .items[] | select((.metadata.name | test($pattern; "i")) or 
                          (.metadata.namespace | test($pattern; "i"))) | 
                          {namespace: .metadata.namespace, name: .metadata.name, type: .kind} ] | 
                          .[] | "\(.namespace) \(.name) \(.type)"' || true)
        
        if [[ -n "$matches" ]]; then
            while read -r line; do
                resources+=("$line")
            done <<< "$matches"
        fi
    done
    
    # Specific search for non-namespaced resources
    for type in $(kubectl api-resources --verbs=list --namespaced=false -o name); do
        local matches=$(kubectl get "$type" -o json 2>/dev/null | \
                        jq -r --arg pattern "$pattern" '[ .items[] | select(.metadata.name | test($pattern; "i")) | 
                          {namespace: "", name: .metadata.name, type: .kind} ] | 
                          .[] | "\(.namespace) \(.name) \(.type)"' || true)
        
        if [[ -n "$matches" ]]; then
            while read -r line; do
                resources+=("$line")
            done <<< "$matches"
        fi
    done
    
    # Specific search for namespaces
    local ns_matches=$(kubectl get namespaces -o json 2>/dev/null | \
                       jq -r --arg pattern "$pattern" '[ .items[] | select(.metadata.name | test($pattern; "i")) | 
                       {namespace: .metadata.name, name: .metadata.name, type: "Namespace"} ] | 
                       .[] | "\(.namespace) \(.name) \(.type)"' || true)

    if [[ -n "$ns_matches" ]]; then
        while read -r line; do
            resources+=("$line")
        done <<< "$ns_matches"
    fi
    
    echo "${resources[@]}"
}

# Function to forcefully delete a resource
delete_resource() {
    local namespace="$1"
    local resource_name="$2"
    local resource_type="$3"
    local force="$4"
    
    if [[ "$resource_type" == "Namespace" ]]; then
        if [[ "$force" == "true" ]]; then
            kubectl delete namespace "$resource_name" --grace-period=0 --force
        else
            kubectl delete namespace "$resource_name"
        fi
    else
        if [[ "$force" == "true" ]]; then
            kubectl delete --grace-period=0 --force "$resource_type" "$resource_name" -n "$namespace"
        else
            kubectl delete "$resource_type" "$resource_name" -n "$namespace"
        fi
    fi
}

# Main function to find and delete resources
main() {
    if [[ $# -lt 1 ]]; then
        echo "Usage: $0 <resource-pattern> [$FORCE_DELETE_FLAG]"
        echo "Example: $0 myapp $FORCE_DELETE_FLAG"
        exit 1
    fi

    local pattern="$1"
    local force_delete="false"

    if [[ "$2" == "$FORCE_DELETE_FLAG" ]]; then
        force_delete="true"
    fi

    local sanitized_pattern
    sanitized_pattern=$(sanitize_input "$pattern")

    echo "Searching for resources matching pattern: *$sanitized_pattern*"

    IFS=$'\n' read -d '' -r -a resources < <(list_resources "$sanitized_pattern")

    if [[ ${#resources[@]} -eq 0 ]]; then
        echo "No resources found matching pattern: *$sanitized_pattern*"
        exit 0
    fi

    echo "Found resources:"
    for resource in "${resources[@]}"; do
        IFS=' ' read -r namespace resource_name resource_type <<< "$resource"
        if [[ -n "$namespace" && -n "$resource_name" && -n "$resource_type" ]]; then
            echo "- Namespace: $namespace, Name: $resource_name, Type: $resource_type"
        fi
    done
    
    read -p "Do you want to delete all the found resources? (y/n): " confirm_delete

    if [[ "$confirm_delete" =~ ^[Yy]$ ]]; then
        echo "Deleting resources..."
        for resource in "${resources[@]}"; do
            IFS=' ' read -r namespace resource_name resource_type <<< "$resource"
            if [[ -n "$namespace" && -n "$resource_name" && -n "$resource_type" ]]; then
                delete_resource "$namespace" "$resource_name" "$resource_type" "$force_delete"
            fi
        done
        echo "Resources deleted."
    else
        echo "Deletion aborted."
        exit 0
    fi
}

main "$@"
