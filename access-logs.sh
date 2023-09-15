#!/bin/bash
# Purpose: To get a downloadable access log file
# Author: Guman Singh | Cloudways
# Last Edited: 15/09/2023:8:48


# Get the current working directory
current_dir=$(pwd)

# Extract the database name from the directory path
dbname=$(echo "$current_dir" | grep -oP '(?<=applications/)[^/]+')

# Define the source and destination paths using the dbname variable
source_path="/home/master/applications/$dbname/logs"
destination_path="/home/master/applications/$dbname/public_html"

# Find the file with the specified pattern (e.g., apache_*.access.log)
log_file=$(find "$source_path" -type f -name "apache_*.access.log")

# Check if the log file exists
if [ -f "$log_file" ]; then
    # Copy the log file to the destination folder
    cp "$log_file" "$destination_path/"

    # Rename the copied file from .log to .txt
    mv "$destination_path/$(basename "$log_file")" "$destination_path/access.txt"

    echo "File copied and renamed to access.txt in $destination_path/"

    # Get the WordPress site URL
    site_url=$(wp option get siteurl)

    # Generate the downloadable link
    download_link="$site_url/access.txt"
    
    echo "Downloadable link: $download_link"
else
    echo "Log file not found in $source_path."
fi

rm -rf ./access-logs.sh
exit
