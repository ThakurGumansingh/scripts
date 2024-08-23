#!/bin/bash
# Purpose: To block the IPs exceeding the number of connections and threshold limit.
# Author: Guman Singh | Cloudways
# Last Edited: 23/08/2024:14:34
# Usage: 

#!/bin/bash

# Get the current working directory
echo "Getting current working directory..."
current_dir=$(pwd)
echo "Current directory: $current_dir"

# Extract the database name from the directory path
echo "Extracting database name from directory path..."
dbname=$(echo "$current_dir" | grep -oP '(?<=applications/)[^/]+')
echo "Database name: $dbname"

# Define the path to the .htaccess file
htaccess_path="$current_dir/.htaccess"
echo "Path to .htaccess file: $htaccess_path"

# Define the path to the log file
logfile="$current_dir/ddos.log"
echo "Path to log file: $logfile"

# Create a backup of .htaccess if it doesn't already exist
backup_path="$htaccess_path-bak"
if [[ ! -f $backup_path ]]; then
    echo "Creating backup of .htaccess..."
    cp "$htaccess_path" "$backup_path"
    echo "Backup created at $backup_path."
else
    echo "Backup already exists at $backup_path. Skipping backup."
fi

# Function to update .htaccess
update_htaccess() {
    local ip=$1
    echo "Updating .htaccess to block IP: $ip"

    # Check if .htaccess exists
    if [[ ! -f $htaccess_path ]]; then
        echo "No .htaccess file found at $htaccess_path. Please check the path."
        exit 1
    fi

    # Check if the IP is already blocked
    if grep -q "deny from $ip" "$htaccess_path"; then
        echo "IP $ip is already blocked in .htaccess."
        return
    fi

    # Add rules to .htaccess
    if grep -q "order deny,allow" "$htaccess_path"; then
        echo "Rule section exists. Adding deny rule..."

        # Add deny rule after the order deny,allow line
        awk -v ip="$ip" '
            /order deny,allow/ {
                print
                print "deny from " ip
                next
            }
            { print }
        ' "$htaccess_path" > "$htaccess_path.tmp" && mv "$htaccess_path.tmp" "$htaccess_path"
    else
        echo "Rule section not found. Adding section and deny rule..."
        sed -i "1s/^/# Limit logins and admin by IP\n<Limit GET POST PUT>\norder deny,allow\ndeny from $ip\nallow from all\n<\/Limit>\n/" "$htaccess_path"
    fi

    # Display the updated contents of .htaccess for debugging
    echo "Updated .htaccess contents:"
    cat "$htaccess_path"
}

# Function to log blocked IPs
log_blocked_ip() {
    local ip=$1
    echo "Logging blocked IP: $ip"

    # Create the log file if it doesn't exist
    if [[ ! -f $logfile ]]; then
        echo "Creating new log file..."
        touch "$logfile"
    fi

    echo "$(date) Blocked IP: $ip" >> "$logfile"
    echo "Logged IP $ip to $logfile"
}

# Monitoring loop to check and block IPs
echo "Starting connection monitoring..."
while true; do
    # Get a list of IPs with active connections using netstat
    for ip in $(netstat -ntu | awk '{print $5}' | cut -d: -f1 | sort | uniq); do
        # Count the number of connections from the current IP
        noconns=$(netstat -ntu | grep "$ip" | wc -l)
        echo "IP $ip has $noconns connections."

        # Check if the number of connections exceeds the threshold (e.g., 10)
        if [[ "$noconns" -gt 10 ]]; then
            echo "IP $ip exceeds connection threshold. Blocking..."
            update_htaccess "$ip"
            log_blocked_ip "$ip"
        fi
    done
    # Wait for 60 seconds before checking again
    sleep 60
done
