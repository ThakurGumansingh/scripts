# Purpose: To check what is consuming more inodes
# Author: Guman Singh | Cloudways
# Last Edited: 16/09/2023:8:48

{ find / -xdev -printf '%h\n' | sort | uniq -c | sort -rn; } 2>/dev/null | head
