#!/bin/bash

# Retrieve system information
HOSTNAME=$(hostname)
OS=$(lsb_release -d | awk -F"\t" '{print $2}')
UPTIME=$(uptime -p)

# Gather hardware information
CPU_MODEL=$(cat /proc/cpuinfo | grep "model name" | uniq | awk -F": " '{print $2}')
CPU_SPEED=$(lscpu | grep "MHz" | awk '{print $3}')
RAM_SIZE=$(free -h | awk '/Mem/ {print $2}')
DISK_SPACE=$(df -h | awk '$NF=="/" {printf "Disk: %d/%dGB (%s)\n", $3, $2, $5}')
VIDEO_CARD=$(lspci | grep -i "VGA" | awk -F": " '{print $2}')

# Collect network information
FQDN=$(hostname -f)
HOST_ADDRESS=$(hostname -I | awk '{print $1}')
GATEWAY_IP=$(ip route | awk '/default/ {print $3}')
DNS_SERVER=$(cat /etc/resolv.conf | grep "nameserver" | awk '{print $2}')
INTERFACES=$(ip -o link show | awk -F': ' '{print $2}')
NETWORK_CARD=$(lspci | grep -i "network" | awk -F": " '{print $2}')
IP_CIDR=$(ip -o -4 addr show $NETWORK_INTERFACE | awk '/inet / {print $4}')

# Retrieve system status
USERS=$(who | awk '{print $1}' | sort | uniq | tr '\n' ',' | sed 's/,$//')
DISK_USAGE=$(df -h | awk '/^\/dev/ {print $6" "$4}')
PROCESS_COUNT=$(ps aux | wc -l)
LOAD_AVERAGES=$(uptime | awk -F'average: ' '{print $2}')
MEMORY_INFO=$(free -m)
LISTENING_PORTS=$(ss -tuln | awk '{print $5}' | cut -d ':' -f2 | grep -E "^[0-9]" | sort -n | uniq | tr '\n' ', ' | sed 's/,$//')
UFW_RULES=$(sudo ufw status numbered | awk '{print $1" "$2" "$3}')

# Generate the system report
echo ""
echo "System Report generated by $(whoami), $(date)"
echo ""
echo "System Information"
echo "------------------"
echo "Hostname: $HOSTNAME"
echo "OS: $OS"
echo "Uptime: $UPTIME"
echo ""
echo "Hardware Information"
echo "--------------------"
echo "CPU: $CPU_MODEL"
echo "Speed: $CPU_SPEED MHz"
echo "RAM: $RAM_SIZE"
echo "$DISK_SPACE"
echo "Video: $VIDEO_CARD"
echo ""
echo "Network Information"
echo "-------------------"
echo "FQDN: $FQDN"
echo "Host Address: $HOST_ADDRESS"
echo "Gateway IP: $GATEWAY_IP"
echo "DNS Server: $DNS_SERVER"
echo ""
echo "Interfaces Names"
echo "$INTERFACES"
echo ""
echo "Network Card: $NETWORK_CARD"
echo "IP Address: $IP_CIDR"
echo ""
echo "System Status"
echo "-------------"
echo "Users Logged In: ${USERS%,}"
echo "Disk Space: $DISK_USAGE"
echo "Process Count: $PROCESS_COUNT"
echo "Load Averages: $LOAD_AVERAGES"
echo "Memory Allocation:"
echo "$MEMORY_INFO"
echo "Listening Network Ports: $LISTENING_PORTS"
echo "UFW Rules: $UFW_RULES"
echo ""

# End of Report
