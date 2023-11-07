#!/bin/bash
# Purpose: To generate a report that can be downloaded and contains information about the traffic for all applications on the server.
# Author: Guman Singh | Cloudways
# Last Edited: 07/11/2023:11:12
# Usage: bash traffic_report.sh 5m ;The last param(5m) can be replaced by your desired timeframe that is 5m (m=minutes) or 1h (h=hours) or 10d (d=days) etc.

# Check if a day value was provided as a command-line argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <day_value>"
    exit 1
fi

dayd="$1"  # Assign the day value from the command line

# Get the current working directory
current_dir=$(pwd)

# Extract the database name from the directory path
dbname=$(echo "$current_dir" | grep -oP '(?<=applications/)[^/]+')

# Change to the applications directory
applications_dir="/home/master/applications"
cd "$applications_dir"

# Save the output to a report file in the current directory
report_file="$applications_dir/$dbname/public_html/traffic_report.csv"
for app in $(ls); do
    echo "$app"
    /usr/local/sbin/apm traffic -s "$app" -l "$dayd"
done > "$report_file"

# Change to the website directory
website_dir="$applications_dir/$dbname/public_html"
cd "$website_dir"

# Run the wp cli command to get the site URL
site_url=$(wp option get siteurl --path="$website_dir")

# Display the contents of the report file
cat "$report_file"

# Create a downloadable report link
download_link="$site_url/traffic_report.csv"
echo "Downloadable report link: $download_link"

# Return to the original directory
cd "$current_dir"
