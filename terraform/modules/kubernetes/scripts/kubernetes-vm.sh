#!/bin/bash

set -e

# Redirect stdout and stderr to a log file
exec > >(tee -a /var/log/k8s-setup.log) 2>&1

echo "Step 1: Disable swap and make it persistent..."
