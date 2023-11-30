#!/bin/bash

# Define variables
TARGET1_MGMT="remoteadmin@172.16.1.10"
TARGET2_MGMT="remoteadmin@172.16.1.11"
NMS_HOSTS_FILE="/etc/hosts"

# Function to execute commands on remote machine
execute_remote_command() {
    ssh "$1" "$2"
    if [ $? -ne 0 ]; then
        echo "Error executing command on $1"
        exit 1
    fi
}

# Task 1: Configure target1-mgmt
execute_remote_command "$TARGET1_MGMT" "sudo hostnamectl set-hostname loghost"
execute_remote_command "$TARGET1_MGMT" "sudo sed -i 's/172.16.1.10 target1/172.16.1.3 loghost/' /etc/hosts"
execute_remote_command "$TARGET1_MGMT" "sudo sed -i 's/172.16.1.10 target1/172.16.1.3 loghost/' /etc/hostname"
execute_remote_command "$TARGET1_MGMT" "sudo sed -i '/172.16.1.10/s/$/ webhost/' /etc/hosts"
execute_remote_command "$TARGET1_MGMT" "sudo apt-get update && sudo apt-get install -y ufw"
execute_remote_command "$TARGET1_MGMT" "sudo ufw allow from 172.16.1.0/24 to any port 514/udp"
execute_remote_command "$TARGET1_MGMT" "sudo sed -i '/imudp/s/^#//' /etc/rsyslog.conf"
execute_remote_command "$TARGET1_MGMT" "sudo systemctl restart rsyslog"

# Task 2: Configure target2-mgmt
execute_remote_command "$TARGET2_MGMT" "sudo hostnamectl set-hostname webhost"
execute_remote_command "$TARGET2_MGMT" "sudo sed -i 's/172.16.1.11 target2/172.16.1.4 webhost/' /etc/hosts"
execute_remote_command "$TARGET2_MGMT" "sudo sed -i 's/172.16.1.11 target2/172.16.1.4 webhost/' /etc/hostname"
execute_remote_command "$TARGET2_MGMT" "sudo sed -i '/172.16.1.11/s/$/ loghost/' /etc/hosts"
execute_remote_command "$TARGET2_MGMT" "sudo apt-get update && sudo apt-get install -y ufw apache2"
execute_remote_command "$TARGET2_MGMT" "sudo ufw allow 80/tcp"
execute_remote_command "$TARGET2_MGMT" "echo '*.* @loghost' | sudo tee -a /etc/rsyslog.conf"
execute_remote_command "$TARGET2_MGMT" "sudo systemctl restart rsyslog"

# Update NMS hosts file
echo "172.16.1.3 loghost" | sudo tee -a "$NMS_HOSTS_FILE"
echo "172.16.1.4 webhost" | sudo tee -a "$NMS_HOSTS_FILE"

# Verify configurations
firefox http://webhost &
sleep 5 # Give time for Firefox to open
ssh remoteadmin@loghost "grep webhost /var/log/syslog"
if [ $? -eq 0 ]; then
    echo "Configuration update succeeded."
else
    echo "Configuration update failed. Check the logs for details."
fi
