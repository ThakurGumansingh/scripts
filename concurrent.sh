#!/bin/bash
# Purpose: To check concurrent traffic at the interval of 10 seconds, there will be total 3 iterations
# Author: Guman Singh | Cloudways
# Last Edited: 13/12/2023:8:38

iterations=3
interval=3
CT=0

for ((i = 1; i <= iterations; i++)); do
    echo "Iteration: $i"
    current_value=$(awk '$2 ~ /:0050|:01BB/ && $4 ~ /01/ {count +=1;} END {print count}' /proc/net/tcp)
    
    if ((i == 1 || current_value > CT)); then
        CT=$current_value
    fi

    sleep $interval
done

echo "Maximum Concurrent Web Connections: $CT"
