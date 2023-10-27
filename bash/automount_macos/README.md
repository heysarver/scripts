# Automount Script Installation Guide for MacOS

This guide will help you install and set up the `automount.sh` script on your MacOS system.

## Prerequisites

- MacOS system
- Basic knowledge of terminal commands

## Installation Steps

1. **Download the Script**

   Download the `automount.sh` and `com.user.automount.plist` files and place them in a directory of your choice.

2. **Make the Script Executable**

   Open Terminal and navigate to the directory where you placed the files. Run the following command to make the script executable:

   ```bash
   chmod +x automount.sh
   ```

3. **Create a Credentials File**

   Create a `credentials.txt` file in the same directory as the script. This file should contain four lines:

   - Line 1: Your username
   - Line 2: Your password
   - Line 3: Your server URL (without the leading `smb://` and without any trailing slashes)
   - Line 4: The folder path on the server (without any leading or trailing slashes)

   For example:

   ```
   myusername
   mypassword
   my.server.com
   myfolder
   ```

   **Note:** Be sure to replace `myusername`, `mypassword`, `my.server.com`, and `myfolder` with your actual username, password, server URL, and folder path.

4. **Update the .plist File**

   Open the `com.user.automount.plist` file in a text editor. Replace `/path/to/automount.sh` with the actual path to the `automount.sh` script on your system.

5. **Load the .plist File**

   Back in Terminal, run the following command to load the .plist file:

   ```bash
   launchctl load com.user.automount.plist
   ```

   This will set up the script to run at system startup.

## Troubleshooting

If the script is not working as expected, you can check the `/tmp/filename.stdout` and `/tmp/filename.stderr` files for any error messages.

## Conclusion

You have now installed and set up the `automount.sh` script on your MacOS system. This script will automatically mount the specified folder from the server at system startup and periodically check to ensure it remains mounted.
