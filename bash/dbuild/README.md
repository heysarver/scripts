# dbuild - Docker Build Script

This script is a utility designed to streamline the use of common docker buildx commands. It's an effective tool in simplifying the process of building Docker images that are compatible with both amd64 and arm64 architectures, which is particularly useful for developers using Apple Silicon machines.

## Usage

The general usage of the script is as follows:

```bash
dbuild [--push] [--platform <platforms>] [<tag>]
```

## Parameters

- `--push`: This option will push the built image to the Docker registry after it's been created.
- `--platform <platforms>`: This option allows you to specify the target platforms for the build. The default value is 'linux/amd64,linux/arm64'.
- `<tag>`: This parameter sets the name (required) and tag for the built image. If not specified, the default tag is 'latest' which will always be published. (E.g. myimage (myimage:latest) or myimage:customtag)

## Examples

Build with default settings:

```bash
dbuild
```

Build and push an image with a specific tag:

```bash
dbuild --push my-image:v1.0
```

Build an image for a specific platform:

```bash
dbuild --platform linux/arm/v7 my-image:v1.0
```

## Disclaimer

This script was generated with the assistance of an AI. While every effort has been made to ensure accuracy and effectiveness, please review and test the code thoroughly before use.
