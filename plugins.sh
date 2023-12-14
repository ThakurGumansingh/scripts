#!/bin/bash
# Purpose: Identify the problematic WordPress plugin.
# Usage: Press Enter to deactivate, Esc to activate all, Backspace to skip
# Author: Guman Singh | Cloudways
# Last Edited: 09/12/2023:11:17
# Usage: curl -s https://raw.githubusercontent.com/ThakurGumansingh/scripts/main/plugins.sh | bash 

# ANSI color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Run the command to list active plugins and save their names to a file
wp plugin list --status=active --format=csv | awk -F, '!/^$/ && !/^name/ {print $1}' > plugin.txt
cp plugin.txt plugin-bak.txt

# Read the list of plugins from the file
plugins=$(cat plugin.txt)

# Deactivate plugins one by one
for plugin in $plugins; do
    # Ask the user whether to deactivate the current plugin
    echo -e "Deactivate $plugin?"
    echo -e "(Press Enter to deactivate, Esc to activate all, Backspace to skip)"
    read -n 1 key

    # If the user presses the Esc key, activate all plugins
    if [ "$key" == $'\e' ]; then
        wp plugin activate $(<plugin-bak.txt)
        echo -e "${YELLOW}All plugins have been activated.${NC}"
        exit
    # If the user presses the Backspace key, skip deactivation
    elif [ "$key" == $'\177' ]; then
        echo -e "${RED}Skipping deactivation of $plugin.${NC}"
    else
        # Deactivate the current plugin
        wp plugin deactivate $plugin

        # Print a message indicating that the plugin has been deactivated in green
        echo -e "${GREEN}Plugin $plugin deactivated.${NC}"

        # Wait for user input to proceed to the next plugin
        echo -e "Press Enter to continue..."
        read -n 1 -s
    fi
done

# If the loop completes, print a message indicating that all plugins have been deactivated in yellow
echo -e "${YELLOW}All plugins have been deactivated, enter Esc button to activate them${NC}"
read -n 1 key
if [ "$key" == $'\e' ]; then
    wp plugin activate $(<plugin-bak.txt)
    echo -e "${YELLOW}All plugins have been activated.${NC}"
    exit
fi
