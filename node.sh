#!/bin/bash
# Purpose: To download desired node version
# Author: Guman Singh | Cloudways
# Last Edited: 16/09/2023:8:09

# Function to print a message in green
print_green() {
  echo -e "\e[32m$1\e[0m"
}

# Step 1: Download and install NVM
curl -sL https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.0/install.sh -o install_nvm.sh
bash install_nvm.sh

# Step 2: Set up NVM environment variables
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Step 3: Reload the shell profile to ensure NVM is available
source ~/.bashrc ~/.bash_aliases
command -v nvm

# Step 4: Delete npm prefix configuration
npm config delete prefix

bash

# Step 5: Prompt user for Node.js version
read -p "Enter the Node.js version you want to install (e.g., 18.0): " version

# Step 6: Install the specified Node.js version
nvm install "$version"

# Step 7: Use the installed Node.js version
nvm use "$version"

bash

# Step 8: Verify the Node.js version
node -v

# Step 9: Display a message in green
print_green "Node $version has been installed."

bash

rm -rf ./node.sh
exit
