#!/bin/bash

# Get the current username
current_user=$(whoami)

# Check if the current user is the master user
if [ "$current_user" = "master" ]; then
    # Add npm bin directory to PATH
    echo "export PATH='$PATH:/home/master/bin/npm'" >> ~/.bash_aliases

    # Add NODE_PATH configuration
    echo "export NODE_PATH='$NODE_PATH:/home/master/bin/npm/lib/node_modules'" >> ~/.bash_aliases

    # Configure npm prefix
    npm config set prefix "/home/master/bin/npm/lib/node_modules"

    # Install pm2 globally
    npm install pm2@latest -g

    # Add pm2 alias to .bash_aliases
    echo "alias pm2='/home/master/bin/npm/lib/node_modules/bin/pm2'" >> ~/.bash_aliases

    # Run pm2 startup
    pm2 startup

    # Start npm using pm2
    pm2 start npm -- start

    echo "Setup completed for the master user."
else
    # Display a prompt for platformops users to switch to master user
    echo "You are currently logged in as '$current_user'."
    read -p "Switch to the master user (master) and run the script? (y/n): " switch_user
    master=$(awk -F: '{print $1}' /etc/passwd | grep master)
    if [ "$switch_user" = "y" ]; then
        su - "$master"
    else
        echo "Setup not completed. You can manually switch to the master user and run the script."
    fi
fi
