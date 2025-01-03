#!/bin/bash

set -e
# Redirect stdout and stderr to a log file
exec > >(tee -a /var/log/k8s-setup.log) 2>&1

echo "Updating system and installing dependencies..."
# Update and install dependencies
sudo apt-get update -y
sudo apt upgrade -y

#sudo apt install docker.io -y
#
#sudo systemctl enable docker
#sudo systemctl status docker
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
