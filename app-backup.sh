#!/bin/bash

# Get the current working directory
current_dir=$(pwd)

# Extract the database name from the directory path
dbname=$(echo "$current_dir" | grep -oP '(?<=applications/)[^/]+')

# Check if the database name was successfully extracted
if [ -z "$dbname" ]; then
    echo "Error: Could not determine the database name from the current directory."
    exit 1
fi

# Prompt for the database password
read -s -p "Enter the MySQL password for the '$dbname' user: " db_password

# Define the backup file name for the database backup
backup_file_db="/home/master/applications/$dbname/public_html/database_backup.sql"

# Create the database backup using mysqldump
mysqldump -u "$dbname" -p"$db_password" "$dbname" > "$backup_file_db"

# Check the mysqldump exit status for errors
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

rm -rf ./app-backup.sh
exit;
