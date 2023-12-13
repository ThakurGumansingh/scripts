#!/bin/bash
# Purpose: To check concurrent traffic at the interval of 3 seconds, there will be total 3 iterations
# Author: Guman Singh | Cloudways
# Last Edited: 13/12/2023:8:38

iterations=3
interval=3
CT=0

# Get the number of cores
cores=$(lscpu | grep '^CPU(s):' | awk '{print $2}')

for ((i = 1; i <= iterations; i++)); do
    echo "Iteration: $i"
    current_value=$(awk '$2 ~ /:0050|:01BB/ && $4 ~ /01/ {count +=1;} END {print count}' /proc/net/tcp)
    
    if ((i == 1 || current_value > CT)); then
        CT=$current_value
    fi

    sleep $interval
done

echo "Maximum Concurrent Web Connections: $CT"

# Check conditions based on the number of cores and print colorized output
if ((cores == 2 && CT > 40)); then
    echo -e "\e[91mServer has more concurrent traffic than the limit for 2 cores.\e[0m"  # Red color
elif ((cores == 4 && CT > 85)); then
    echo -e "\e[91mServer has more concurrent traffic than the limit for 4 cores.\e[0m"  # Red color
elif ((cores == 8 && CT > 165)); then
    echo -e "\e[91mServer has more concurrent traffic than the limit for 8 cores.\e[0m"  # Red color
elif ((cores == 32 && CT > 325)); then
    echo -e "\e[91mServer has more concurrent traffic than the limit for 32 cores.\e[0m"  # Red color
elif ((cores == 64 && CT > 645)); then
    echo -e "\e[91mServer has more concurrent traffic than the limit for 64 cores.\e[0m"  # Red color
else
    echo -e "\e[92mServer is within the concurrent traffic limits for its core count.\e[0m"  # Green color
fi
