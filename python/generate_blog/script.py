import os
import argparse
import openai
from dotenv import load_dotenv

# Load .env file if it exists
load_dotenv()

# Load your OpenAI API Key from an environment variable or .env file
openai_api_key = os.getenv('OPENAI_API_KEY')
if not openai_api_key:
    raise ValueError("Please set the OPENAI_API_KEY environment variable or define it in a .env file.")

# Parse command line arguments
parser = argparse.ArgumentParser(description='Generate blog copy with OpenAI Chat.')
parser.add_argument('--model', type=str, help='The model to use (e.g., "text-davinci-003")', default=os.getenv('MODEL', 'text-davinci-003'))
parser.add_argument('--temperature', type=float, help='Sampling temperature', default=float(os.getenv('TEMPERATURE', 0.7)))
parser.add_argument('--max_tokens', type=int, help='Maximum number of tokens to generate.', default=int(os.getenv('MAX_TOKENS', 256)))
parser.add_argument('--stop_sequences', nargs="*", type=str, help='Sequences where the API will stop generating further tokens.', default=os.getenv('STOP_SEQUENCES', '').split(','))
parser.add_argument('--top_p', type=float, help='An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass.', default=float(os.getenv('TOP_P', 1.0)))
parser.add_argument('--frequency_penalty', type=float, help='Number by which to penalize new tokens based on their existing frequency in the text so far.', default=float(os.getenv('FREQUENCY_PENALTY', 0.0)))
parser.add_argument('--presence_penalty', type=float, help='Number by which to penalize new tokens based on whether they appear in the text so far.', default=float(os.getenv('PRESENCE_PENALTY', 0.0)))

# We assume that user may provide prompt directly as a positional argument
parser.add_argument('prompt', type=str, nargs='?', default='Write a creative blog post about: ', help='Prompt for the AI to start generating text.')
args = parser.parse_args()

# Setup OpenAI parameters using arguments/environment variables
openai_params = {
    "model": args.model,
    "temperature": args.temperature,
    "max_tokens": args.max_tokens,
    'stop': args.stop_sequences if args.stop_sequences[0] else None,
    "top_p": args.top_p,
    "frequency_penalty": args.frequency_penalty,
    "presence_penalty": args.presence_penalty,
}

def generate_blog_copy(prompt):
    # Initialize OpenAI GPT model with provided parameters
    try:
        response = openai.ChatCompletion.create(
            messages=[{"role": "system", "content": f"You are an AI instructed to write a summary."},
                      {"role": "user", "content": prompt}],
            **openai_params
        )
    except openai.error.OpenAIError as e:
        raise e

    return response.choices[0].message['content']

if __name__ == "__main__":
    # Make sure we have all required configurations set.
    if not openai_api_key:
        print("ERROR: Please define OPENAI_API_KEY as an environment variable or in a .env file.")
        exit(1)

    # Set OpenAI key in the client library
    openai.api_key = openai_api_key

    blog_copy = generate_blog_copy(args.prompt)

    print(blog_copy)
