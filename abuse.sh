#!/bin/bash
# Purpose: To check the abuse score of IP addresses extracted from access logs
# Author: Guman Singh | Cloudways
# Last Edited: 20/09/2023:08:53
# Usage: curl -s https://raw.githubusercontent.com/ThakurGumansingh/scripts/main/abuse.sh | bash

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

# Python script to check IP addresses against AbuseIPDB
python3 <<EOF
import requests
import json

# Replace 'YOUR_API_KEY' with your actual AbuseIPDB API key
api_key = '223f7a250fae2ca587bdb758583544bb687abf123b497f9f85bbc82623912420ecba150a630f8f06'

# Define the path to the text file containing IP addresses
file_path = 'ip_addresses.txt'

# Read IP addresses from the text file
with open(file_path, 'r') as file:
    ip_addresses = file.read().splitlines()

# Define the API endpoint URL
url = f'https://api.abuseipdb.com/api/v2/check'

# Set the API key as a header in the request
headers = {
    'Accept': 'application/json',
    'Key': api_key,
}

for ip_to_check in ip_addresses:
    # Set the IP address as a query parameter
    params = {
        'ipAddress': ip_to_check,
    }

    response = requests.get(url, headers=headers, params=params)

    # Check if the request was successful
    if response.status_code == 200:
        data = json.loads(response.text)
        if 'data' in data:
            abuse_confidence_score = data['data'].get('abuseConfidenceScore')
            if abuse_confidence_score is not None:
                if abuse_confidence_score > 50:
                    print(f'\033[31mThe IP address {ip_to_check} is blacklisted with a score of {abuse_confidence_score}.\033[0m')
                else:
                    print(f'\033[32mThe IP address {ip_to_check} is not blacklisted with a score of {abuse_confidence_score}.\033[0m')
            else:
                print(f'No abuse confidence score available for IP address {ip_to_check}')
        else:
            print('Error: {}'.format(data['message']))
    else:
        print('Error: Unable to connect to the AbuseIPDB API. Status code: {}'.format(response.status_code))
EOF
rm -rf "$output_dir/ip_addresses.txt"
exit

