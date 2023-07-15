# Directory Analyzer

This script is a directory analyzer that uses OpenAI's GPT-3.5-turbo model to analyze and provide suggestions on how to organize your files and directories.

## Requirements

- Python 3.x
- Docker (for building and running the docker image)

## Installation

Clone this repository to your local machine.

```bash
git clone <repo-url>
```

Navigate to the project directory.

```bash
cd <project-directory>
```

Install the required python packages.

```bash
pip install -r requirements.txt
```

## Usage

You can run the script with the following command:

```bash
python main.py [-f] [-p PATH] [-m MODEL]
```

### Arguments

- `-f, --files`: Include files in analysis.
- `-p, --path`: Path to analyze. Default is current directory ('.').
- `-m, --model`: OpenAI model to use. Default is 'gpt-3.5-turbo'.

## Docker

A Dockerfile is included in the project to build a Docker image.

### Building the Docker Image

To build the Docker image, navigate to the project directory and run the following command:

```bash
docker build -t directory-analyzer .
```

### Running the Docker Container

After building the image, you can run the Docker container with the following command:

```bash
docker run --rm -v /local/path/to/directory:/data:ro -e OPENAI_API_KEY=<your-api-key> -e OPENAI_MODEL=<model-name> directory-analyzer
```

## Environment Variables

The script uses the following environment variables:

- `OPENAI_API_KEY`: Your OpenAI API key.
- `OPENAI_MODEL`: The OpenAI model to use. If not set, the script will use the model specified by the `-m` argument.

Please make sure to set these environment variables before running the script or the Docker container.
