#!/bin/bash
# Purpose: To generate a report that can be downloaded and contains information about the traffic for all applications on the server.
# Author: Guman Singh | Cloudways
# Last Edited: 07/11/2023:11:12

# Get the current working directory
current_dir=$(pwd)

# Extract the database name from the directory path
dbname=$(echo "$current_dir" | grep -oP '(?<=applications/)[^/]+')

# Change to the applications directory
applications_dir="/home/master/applications"
cd "$applications_dir"

# Save the output to a report file in the current directory
report_file="$applications_dir/$dbname/public_html/report.txt"
for app in $(ls); do
    echo "$app"
    /usr/local/sbin/apm traffic -s "$app" -l 1d
done > "$report_file"

# Change to the website directory
website_dir="$applications_dir/$dbname/public_html"
cd "$website_dir"

# Run the wp cli command to get the site URL
site_url=$(wp option get siteurl --path="$website_dir")

# Display the contents of the report file
cat "$report_file"

# Create a downloadable report link
download_link="$site_url/report.txt"
echo "Downloadable report link: $download_link"

# Return to the original directory
cd "$current_dir"
