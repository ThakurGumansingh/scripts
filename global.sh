#!/bin/bash
# Purpose: To install a specified npm package globally using master user.
# Author: Guman Singh | Cloudways
# Last Edited: 14/12/2023:01:25
# Usage: 

# Prompt user for the package name
echo "Please enter the package name:"
read -r global

# Save the package name to the variable $global

# Append PATH and NODE_PATH configurations to .bash_aliases
cd ~ && echo "export PATH='$PATH:/home/master/bin/npm'" >> .bash_aliases
cd ~ && echo "export NODE_PATH='$NODE_PATH:/home/master/bin/npm/lib/node_modules'" >> .bash_aliases

# Set npm prefix configuration
npm config set prefix "/home/master/bin/npm/lib/node_modules"

# Create an alias for the provided package in .bash_aliases
cd ~ && echo "alias $global='/home/master/bin/npm/lib/node_modules/bin/$global'" >> .bash_aliases

# Install the specified package globally
npm install "$global@latest" -g

# Check the version using the full path
version="$("/home/master/bin/npm/lib/node_modules/bin/$global" --version 2>&1)"

if [[ $version == *command* ]]; then
  # Package not installed
  echo -e "\e[91mError: $global could not be installed globally\e[0m"
else
  # Package installed, print version in green
  echo -e "\e[92m$global version $version installed globally successfully\e[0m"
fi
bash
