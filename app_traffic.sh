#!/bin/bash
# Purpose: To generate a report that can be downloaded and contains information about the traffic, MySQL queries, and PHP pages for the current application.
# Author: Guman Singh | Cloudways
# Last Edited: 07/11/2023:11:12
# Usage: curl -s https://raw.githubusercontent.com/ThakurGumansingh/scripts/main/app_traffic.sh | bash -s 1d
# The last param(5m) can be replaced by your desired timeframe that is 5m (m=minutes) or 1h (h=hours) or 10d (d=days) etc.

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

# Save the output to a report file in the current directory
report_file="$current_dir/traffic_report.csv"
echo "Traffic Report" > "$report_file"

# Run the traffic command and append the output to the report file
sudo apm traffic -s "$dbname" -l "$dayd" >> "$report_file"

# Add a header for MySQL queries report
echo "MySQL Queries Report" >> "$report_file"

# Run the MySQL command and append the output to the report file
sudo apm mysql -s "$dbname" -l "$dayd" >> "$report_file"

# Add a header for PHP pages report
echo "PHP Pages Report" >> "$report_file"

# Run the PHP command and append the output to the report file
sudo apm php -s "$dbname" -l "$dayd" >> "$report_file"

# Run the wp cli command to get the site URL
site_url=$(wp option get siteurl --allow-root --path="$current_dir")

# Display the contents of the report file
cat "$report_file"

# Create a downloadable report link
download_link="$site_url/traffic_report.csv"
echo "Downloadable report link: $download_link"
