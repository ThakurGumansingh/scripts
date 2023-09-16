#!/bin/bash
# Purpose: To check concurrent traffic at the interval of 10 seconds, there will be total 3 iterations
# Author: Guman Singh | Cloudways
# Last Edited: 16/09/2023:8:38

iterations=3
interval=10

for ((i = 1; i <= iterations; i++)); do
    echo "Iteration: $i"
    awk '$2 ~ /:0050|:01BB/ && $4 ~ /01/ {count +=1;} END {print "Concurrent Web Connections: ",count}' /proc/net/tcp
    sleep $interval
done
