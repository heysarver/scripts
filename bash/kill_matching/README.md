# kill_matching.sh

A script that kills -9 all processes containing a string except for the grep command used to search.

## Quick Install

Run the following command in your terminal:

```bash
curl -s https://raw.githubusercontent.com/heysarver/scripts/bash/kill_matching/kill_matching.sh >> ~/.bashrc && source ~/.bashrc
```

This command will download the `kill_matching.sh` script from the GitHub repository and append it to your `.bashrc` file. Then, it will source the `.bashrc` file to apply the changes.

## Detailed Install Steps

1. Download the `kill_matching.sh` script from the GitHub repository:

```bash
curl -s -O https://raw.githubusercontent.com/heysarver/scripts/bash/kill_matching/kill_matching.sh
```

2. Append the script to your `.bashrc` file:

```bash
echo "\n# kill_matching.sh\nsource $(pwd)/kill_matching.sh\n" >> ~/.bashrc
```

3. Source your `.bashrc` file to apply the changes:

```bash
source ~/.bashrc
```
