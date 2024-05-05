# SSH Shortcut Creator

This script allows you to create, update, and delete shortcuts for SSH connections on macOS. It utilizes `dockutil` for managing Dock items and generates an application shortcut that initiates an SSH connection through iTerm.

## Prerequisites

- macOS operating system
- iTerm2 installed
- `dockutil` command-line utility
- Homebrew (for installing `dockutil` if not present)

## Installation

Before using the script, ensure `dockutil` is installed. If it is not, the script will attempt to install it using Homebrew.

## Usage

```
./ssh_shortcut_creator.sh -h <hostname> [-u <username>] [-i <icon path>] [-d] [-s]
```

### Options

- `-h <hostname>`: Specify the hostname for the SSH connection. This parameter is required.
- `-u <username>`: Specify the username for the SSH connection. This is optional.
- `-i <icon path>`: Specify a custom icon for the shortcut. The path must point to a `.icns` file. This is optional.
- `-d`: Delete the specified shortcut. This option cannot be used with others to create or update shortcuts.
- `-s`: Add the shortcut to the Dock. This is optional.

### Examples

- **Creating a Shortcut**: To create a shortcut for an SSH connection to `ssh_host` with the username `user`, run:

  ```
  ./ssh_shortcut_creator.sh -h ssh_host -u user -s
  ```

- **Adding a Custom Icon**: To add a custom icon to the shortcut, specify the icon path with `-i`:

  ```
  ./ssh_shortcut_creator.sh -h ssh_host -u user -i /path/to/icon.icns
  ```

- **Adding to the Dock**: To directly add the shortcut to the Dock, use `-s`:

  ```
  ./ssh_shortcut_creator.sh -h ssh_host -u user -s
  ```

- **Deleting a Shortcut**: To delete a previously created shortcut for `ssh_host`, use:

  ```
  ./ssh_shortcut_creator.sh -h ssh_host -d
  ```

## Notes

- The script requires permission to execute. You might need to run `chmod +x ssh_shortcut_creator.sh` to make it executable.
- Custom icons must be in `.icns` format to be applied correctly.

## License

This script is provided "as is", without warranty of any kind. Use at your own risk. JFTI License ❤️
