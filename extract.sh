#!/bin/bash
# Purpose: To get a txt file of extracted IP addresses from acecss logs
# Author: Guman Singh | Cloudways
# Last Edited: 20/09/2023:8:48
# Usage: curl -s https://raw.githubusercontent.com/ThakurGumansingh/scripts/main/extract.sh | bash 

# Get the current working directory
current_dir=$(pwd)

# Extract the database name from the directory path
dbname=$(echo "$current_dir" | grep -oP '(?<=applications/)[^/]+')

# Define the source and destination paths
logs_dir="/home/master/applications/$dbname/logs"
output_dir="/home/master/applications/$dbname/public_html"

# Use find to locate log files and extract unique IP addresses
find "$logs_dir" -type f -name "apache_*.access.log" -exec grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' {} \; | sort -u > "$output_dir/ip_addresses.txt"

echo "Unique IP addresses saved in ip_addresses.txt"

rm -rf ./extract.sh
