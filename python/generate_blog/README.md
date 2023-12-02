
# Copy Generator

This script uses OpenAI's GPT-3 model to generate blog copy based on a given prompt. It allows you to specify various parameters for the generation process, such as the model to use, the sampling temperature, the maximum number of tokens to generate, and more.

## Requirements

- Python 3.6 or higher
- `openai` Python package
- `python-dotenv` Python package

## Installation

1. Clone this repository.
2. Install the required Python packages using pip:

```bash
pip install openai python-dotenv
```

## Usage

You can run the script from the command line with optional arguments:

```bash
python script.py --model text-davinci-003 --temperature 0.7 --max_tokens 256
```

You can also specify a prompt directly:

```bash
python script.py "Write a creative blog post about: "
```

## Environment Variables

The script can also read from a .env file or environment variables. Here are the variables it looks for:

- `OPENAI_API_KEY`: Your OpenAI API key.
- `MODEL`: The model to use (e.g., "text-davinci-003").
- `TEMPERATURE`: Sampling temperature.
- `MAX_TOKENS`: Maximum number of tokens to generate.
- `STOP_SEQUENCES`: Sequences where the API will stop generating further tokens.
- `TOP_P`: An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass.
- `FREQUENCY_PENALTY`: Number by which to penalize new tokens based on their existing frequency in the text so far.
- `PRESENCE_PENALTY`: Number by which to penalize new tokens based on whether they appear in the text so far.

## License

This project is licensed under the terms of the MIT license.
