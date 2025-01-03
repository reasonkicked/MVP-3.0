#!/bin/bash
set -e

# Redirect stdout and stderr to a log file
exec > >(tee -a /var/log/k8s-setup.log) 2>&1



# Update and install prerequisites
apt-get update -y
apt-get upgrade -y

echo "Debug..."