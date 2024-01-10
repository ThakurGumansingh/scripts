#!/bin/bash
# Purpose: To download desired node version
# Author: Guman Singh | Cloudways
# Last Edited: 16/09/2023:8:09
# Usage: wget https://raw.githubusercontent.com/ThakurGumansingh/scripts/main/node.sh && bash node.sh

# Function to print a message in green
print_green() {
  echo -e "\e[32m$1\e[0m"
}

# Step 1: Download and install NVM
curl https://gist.githubusercontent.com/cloudways-haider/f7cb6627f6674c263624589d360e12b4/raw/9d0b2c78ace5b7b2dedb411e9d676129e34b470a/nvm_install.sh | bash
source ~/.bashrc ~/.bash_aliases

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

rm nvm_install.sh
rm -rf ./node.sh
exit
