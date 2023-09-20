#!/bin/bash
# Purpose: To check the abuse score of IP addresses extracted from access logs
# Author: Guman Singh | Cloudways
# Last Edited: 20/09/2023:08:53

# Bash script to extract IP addresses and save them to a text file
curl -s https://raw.githubusercontent.com/ThakurGumansingh/scripts/main/extract.sh | bash

# Python script to check IP addresses against AbuseIPDB
python3 <<EOF
import requests
import json

# Replace 'YOUR_API_KEY' with your actual AbuseIPDB API key
api_key = '74b5d908b351ab27ae6643b48371e0e526ba7ec8e1e8fd19528c55a1f249c923b80f9a0b7ef7fb5a'

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
rm -f ./ip_addresses.txt
exit

