# remove_git_commit.sh

Remove a specific commit from a git branch.

## Usage

```bash
remove_git_commit.sh [commit_hash] [branch_name]
```

Where:

- `commit_hash` is the hash of the commit you want to remove.
- `branch_name` is the name of the branch where the commit is.

## Installation

1. Download the script and place it in a directory of your choice.

2. Make the script executable:

```bash
chmod +x remove_git_commit.sh
```

3. Add an alias to your `.bashrc` or `.zshrc` file:

For bash:

```bash
echo "alias remove_git_commit='path/to/remove_git_commit.sh'" >> ~/.bashrc
source ~/.bashrc
```

For zsh:

```bash
echo "alias remove_git_commit='path/to/remove_git_commit.sh'" >> ~/.zshrc
source ~/.zshrc
```

Replace `path/to/remove_git_commit.sh` with the actual path to the script.

4. Alternatively, you can add the script's directory to your `$PATH`:

```bash
echo 'export PATH=$PATH:/path/to/script/' >> ~/.bashrc
source ~/.bashrc
```

Replace `/path/to/script/` with the actual path to the script's directory.

Now you can use the `remove_git_commit` command from anywhere in your terminal.
