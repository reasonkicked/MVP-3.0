#!/bin/bash

set -e
# Redirect stdout and stderr to a log file
exec > >(tee -a /var/log/k8s-setup.log) 2>&1

echo "Updating system and installing dependencies..."
# Update and install dependencies
sudo apt-get update -y
