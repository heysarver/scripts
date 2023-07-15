import os
import argparse
import openai

openai.api_key = os.getenv('OPENAI_API_KEY', 'your-api-key')

def analyze_directory(include_files, path='.'):
    files = []
    folders = []

    for item in os.listdir(path):
        if os.path.isfile(os.path.join(path, item)) and include_files:
            files.append(item)
        elif os.path.isdir(os.path.join(path, item)):
            folders.append(item)

    return files, folders

parser = argparse.ArgumentParser(description='Analyze directory structure.')
parser.add_argument('-f', '--files', action='store_true', help='Include files in analysis.')
parser.add_argument('-p', '--path', type=str, default='.', help='Path to analyze.')
parser.add_argument('-m', '--model', type=str, default='gpt-3.5-turbo', help='OpenAI model to use.')

args = parser.parse_args()

files, folders = analyze_directory(args.files, args.path)

if args.files:
    message = f"I have the following files and folders: {', '.join(files+folders)}. How should I organize them?"
else:
    message = f"I have the following folders: {', '.join(folders)}. How should I organize them?"

response = openai.ChatCompletion.create(
  model=os.getenv('OPENAI_MODEL', args.model),
  messages=[
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": message}
    ]
)

print(response['choices'][0]['message']['content'])
