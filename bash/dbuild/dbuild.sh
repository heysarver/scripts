#!/bin/bash

function dbuild() {
    local push=""
    local platform="linux/amd64,linux/arm64"
    local tag=""

    while (( "$#" )); do
        case "$1" in
            --push)
                push="--push"
                shift
                ;;
            --platform)
                platform="$2"
                shift 2
                ;;
            --help)
                echo "Usage: dbuild [--push] [--platform <platforms>] <tag>"
                echo ""
                echo "Parameters:"
                echo "--push           Push the built image to the Docker registry."
                echo "--platform       Specify the target platforms for the build. Default is 'linux/amd64,linux/arm64'."
                echo "<tag>            The tag for the built image. This parameter is mandatory."
                echo ""
                echo "Examples:"
                echo "dbuild my-image:v1.0                           # Build with default settings"
                echo "dbuild --push my-image:v1.0      # Build and push an image with a specific tag"
                echo "dbuild --platform linux/arm/v7 my-image:v1.0   # Build an image for a specific platform"
                return 0
                ;;
            *)
                if [ -z "$tag" ]; then
                    tag="$1"
                else
                    echo "Error: Multiple tags specified. Please specify only one tag."
                    return 1
                fi
                shift
                ;;
        esac
    done

    if [ -z "$tag" ]; then
        echo "Error: No tag specified. Please provide a tag for the image."
        return 1
    fi

    docker buildx build ${push} --platform ${platform} --tag ${tag} --tag ${tag%:*}:latest .
}
