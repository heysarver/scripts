# wget_download.sh

This script is a simple utility for downloading files from the internet. It was originally designed for downloading models from civitai.com, but it can be used with any URL that points to a file.

## Usage

```bash
./wget_download.sh <url>
```

Replace `<url>` with the URL of the link you want to download.

## Install
You can add aliases to your `.zshrc` (or `.bashrc`) file to make this script even easier to use. Here are a couple of examples:

```bash
alias download_file='./wget_download.sh'
alias download_model='./wget_download.sh'
```

With these aliases, you can download a file just by typing `download_file <url>` or `download_model <url>` in your terminal.

Remember to source your `.zshrc` file after adding:

```bash
source ~/.zshrc
```

## Dependencies
- wget
