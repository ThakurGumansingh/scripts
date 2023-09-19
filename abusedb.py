import requests

# Replace 'YOUR_API_KEY' with your actual AbuseIPDB API key
api_key = '74b5d908b351ab27ae6643b48371e0e526ba7ec8e1e8fd19528c55a1f249c923b80f9a0b7ef7fb5a'

# Replace 'IP_TO_CHECK' with the IP address you want to check
ip_to_check = '159.69.189.48'

# Define the API endpoint URL
url = 'https://api.abuseipdb.com/api/v2/check'

# Set the API key as a header in the request
headers = {
    'Key': api_key,
}

# Set the IP address as a query parameter
params = {
    'ipAddress': ip_to_check,
}

# Send the GET request to the API
response = requests.get(url, headers=headers, params=params)

# Check if the request was successful
if response.status_code == 200:
    data = response.json()
    if 'data' in data:
        if "in our database" in data['data'].get('reportReason', '').lower():
            print('The IP address {} is listed as abusive on AbuseIPDB.'.format(ip_to_check))
        else:
            print('The IP address {} was not found in the AbuseIPDB database.'.format(ip_to_check))
    else:
        print('Error: {}'.format(data['message']))
else:
    print('Error: Unable to connect to the AbuseIPDB API. Status code: {}'.format(response.status_code))
