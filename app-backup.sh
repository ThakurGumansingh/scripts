#!/bin/bash

# Purpose: Debug server load
# Author: Guman Singh | Cloudways
# Last Edited: 16/09/2023:19:38
# Get the current working directory
current_dir=$(pwd)

# Extract the database name from the directory path
dbname=$(echo "$current_dir" | grep -oP '(?<=applications/)[^/]+')

# Check if the database name was successfully extracted
if [ -z "$dbname" ]; then
    echo "Error: Could not determine the database name from the current directory."
    exit 1
fi

# Define the backup file name for the database backup
backup_file_db="/home/master/applications/$dbname/public_html/database_backup.sql"

# Run the wp cli command to export the database
wp db export "$backup_file_db" --path="/home/master/applications/$dbname/public_html"

# Check the exit status for errors
if [ $? -eq 0 ]; then
    echo "Database backup of '$dbname' created at '$backup_file_db'"
else
    echo "Error: Database backup failed."
    exit 1
fi

# Define the backup directory and file name for the directory backup
backup_dir="/home/master/applications/$dbname/public_html"
backup_file_dir="/home/master/applications/$dbname/public_html/backup.tar.gz"

# Create a zip file containing the database backup and directory backup
tar -czvf "$backup_file_dir" -C "$backup_dir" . "$backup_file_db"

echo "Backup of '$dbname' created at '$backup_file_dir'"

# Run the wp cli command to get the site URL
site_url=$(wp option get siteurl --path="/home/master/applications/$dbname/public_html")

# Create a downloadable link
download_link="$site_url/backup.tar.gz"

echo "Downloadable backup link: $download_link"

rm -rf ./app-backup.sh
exit
