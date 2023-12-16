#!/bin/bash
# Purpose: To generate a report that can be downloaded and contains information about the traffic stats, slow MySQL queries, slow PHP pages, disk space, WP crons, AJAX requests and concurrent traffic for all applications on the server.
# Author: Guman Singh | Cloudways
# Last Edited: 14/12/2023:12:12
# Usage: curl -s https://raw.githubusercontent.com/ThakurGumansingh/scripts/main/server_report.sh | bash -s 1d
# The last param(5m) can be replaced by your desired timeframe that is 5m (m=minutes) or 1h (h=hours) or 10d (d=days) etc.

# Define colors
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
PINK=$(tput setaf 5)
BLUE=$(tput setaf 6)
RESET=$(tput sgr0)

iterations=3
interval=3
CT=0

# Get the number of cores
echo "${YELLOW}Checking Concurrent Traffic"
cores=$(lscpu | grep '^CPU(s):' | awk '{print $2}')
echo "${RESET}"

# Check if a day value was provided as a command-line argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <day_value>"
    exit 1
fi

dayd="$1"  # Assign the day value from the command line

# Get the current working directory
current_dir=$(pwd)

# Extract the database name from the directory path
dbname=$(echo "${GREEN}$current_dir" | grep -oP '(?<=applications/)[^/]+')
echo "${RESET}"

# Change to the applications directory
applications_dir="/home/master/applications"
cd "$applications_dir"


# Save the output to a report file in the current directory
report_file="$applications_dir/$dbname/public_html/server_report.csv"
for app in $(ls); do
    echo "${GREEN}Application: $app" >> "$report_file"
    echo "${RESET}"
    
    # Traffic report
    echo -e "${BLUE}Traffic Report" >> "$report_file"
    /usr/local/sbin/apm traffic -s "$app" -l "$dayd" >> "$report_file"
    echo "${RESET}"
    
    # MySQL queries report
    echo -e "${YELLOW}\nMySQL Queries Report" >> "$report_file"
    sudo apm mysql -s "$app" -l "$dayd" >> "$report_file"

    # PHP Pages report
    echo "${RESET}"
    echo -e "${PINK}PHP Pages Report" >> "$report_file"
    sudo apm php -s "$app" -l "$dayd" >> "$report_file"

    echo "" >> "$report_file"  # Add a newline between application reports
done
    echo "${RESET}"

    # Add disk space report
    echo -e "\nDisk Space Report:" >> "$report_file"
    {
  printf "\n$(tput setaf 3)DISK USAGE:$(tput setaf 7)\n"
  df -h /dev/vda1 2>/dev/null

  printf "\n%s\n" "$(tput setaf 3)/ $(tput setaf 7)"
  du -shc /* 2>/dev/null | sort -rh | head -n 5

  printf "\n%s\n" "$(tput setaf 3)/var $(tput setaf 7)"
  du -d2 -hc /var/* 2>/dev/null | sort -rh | head -n 5

  printf "\n%s\n" "$(tput setaf 3)/home $(tput setaf 7)"
  (cd /home/master/applications && du -shc ../* 2>/dev/null | sort -rh | head -n 5)

  printf "\n%s\n" "$(tput setaf 3)/home/master/applications $(tput setaf 7)"
  (cd /home/master/applications && du -shc ./* 2>/dev/null | sort -rh)

  printf "\n%s\n" "$(tput setaf 3)Application usage details: $(tput setaf 7)"
  for dir in *; do
    (cd "$dir" && printf "%s\n" "$(tput setaf 4)$dir$(tput setaf 7)" && sudo apm -s "$dir" -d && du -h -d2 * 2>/dev/null | sort -hr | head -n 4)
  done
} >> "$report_file"


echo "Maximum Concurrent Web Connections: $CT" >> "$report_file"

# Check conditions based on the number of cores and print colorized output
if ((cores == 2 && CT > 40)); then
    echo -e "\e[91mServer has more concurrent traffic than the limit for 2 cores.\e[0m" >> "$report_file"  # Red color
elif ((cores == 4 && CT > 85)); then
    echo -e "\e[91mServer has more concurrent traffic than the limit for 4 cores.\e[0m" >> "$report_file"  # Red color
elif ((cores == 8 && CT > 165)); then
    echo -e "\e[91mServer has more concurrent traffic than the limit for 8 cores.\e[0m" >> "$report_file"  # Red color
elif ((cores == 32 && CT > 325)); then
    echo -e "\e[91mServer has more concurrent traffic than the limit for 32 cores.\e[0m" >> "$report_file"  # Red color
elif ((cores == 64 && CT > 645)); then
    echo -e "\e[91mServer has more concurrent traffic than the limit for 64 cores.\e[0m" >> "$report_file"  # Red color
else
    echo -e "\e[92mServer is within the concurrent traffic limits for its core count.\e[0m" >> "$report_file"  # Green color
    # Add additional logic here for the 'else' condition
    # For example: echo "Additional message" >> "$report_file"
fi

# Change to the website directory
website_dir="$applications_dir/$dbname/public_html"
cd "$website_dir"

# Run the wp cli command to get the site URL
site_url=$(wp option get siteurl --path="$website_dir")

# Display the contents of the report file
cat "$report_file"

# Create a downloadable report link
download_link="$site_url/server_report.csv"
echo "Downloadable report link: $download_link"

# Return to the original directory
cd "$current_dir"
