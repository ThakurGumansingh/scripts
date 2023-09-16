#!/bin/bash
# Purpose: To check CPU usage, disk usage, swap memory and which services are consuming more CPU
# Author: Guman Singh | Cloudways
# Last Edited: 16/09/2023:09:14

# Get the top 10 processes by CPU usage
echo "Top 10 processes by CPU usage:"
ps aux --sort=-%cpu | head -11 | awk '{print $11, $3}' | column -t

# Get the average CPU load
echo -e "\nAverage CPU load:"
uptime

# Get memory usage, including swap
echo -e "\nMemory and Swap usage:"
free -m

# Get disk usage
echo -e "\nDisk usage:"
df -h

rm -rf ./cpu.sh
exit
