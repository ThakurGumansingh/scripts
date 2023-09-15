#!/bin/bash
# Purpose: To get a downloadable error log file
# Author: Guman Singh | Cloudways

# Get the current working directory
current_dir=$(pwd)

# Extract the database name from the directory path
dbname=$(echo "$current_dir" | grep -oP '(?<=applications/)[^/]+')

# Define the source and destination paths using the dbname variable
source_path="/home/master/applications/$dbname/logs"
destination_path="/home/master/applications/$dbname/public_html"

# Find the error log file with the specified pattern (e.g., apache_*.error.log)
error_log_file=$(find "$source_path" -type f -name "apache_*.error.log")

# Check if the error log file exists
if [ -f "$error_log_file" ]; then
    # Copy the error log file to the destination folder
    cp "$error_log_file" "$destination_path/"

    # Rename the copied error log file from .log to .txt
    mv "$destination_path/$(basename "$error_log_file")" "$destination_path/error.txt"

    echo "File copied and renamed to error.txt in $destination_path/"

    # Get the WordPress site URL
    site_url=$(wp option get siteurl)

    # Generate the downloadable error log link
    error_log_link="$site_url/error.txt"

    echo "Downloadable error log link: $error_log_link"
else
    echo "Error log file not found in $source_path."
fi
rm -rf ./error-log.sh
