#!/bin/bash
set -e

# Redirect stdout and stderr to a log file
exec > >(tee -a /var/log/k8s-setup.log) 2>&1

echo "Starting Kubernetes setup..."

# Update and install prerequisites
apt-get update -y
apt-get upgrade -y
apt-get install -y apt-transport-https ca-certificates curl software-properties-common

## Install Docker
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

# Add Docker’s official GPG key
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up the Docker stable repository
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package list to include Docker's repository
sudo apt-get update -y

# Install Docker CE
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Enable and start Docker
sudo systemctl enable docker
sudo systemctl start docker
#
# Install kubeadm, kubelet, and kubectl
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
add-apt-repository "deb https://apt.kubernetes.io/ kubernetes-xenial main"
apt-get update -y
apt-get install -y kubelet kubeadm kubectl

# Initialize Kubernetes cluster
kubeadm init --pod-network-cidr=192.168.0.0/16
#
## Set up kubectl for the admin user
#mkdir -p /home/adminuser/.kube
#cp -i /etc/kubernetes/admin.conf /home/adminuser/.kube/config
#chown adminuser:adminuser /home/adminuser/.kube/config
#
## Install a pod network (e.g., Calico)
#su - adminuser -c "kubectl apply -f https://docs.projectcalico.org/v3.25/manifests/calico.yaml"
#
## Allow scheduling pods on the control plane node
#su - adminuser -c "kubectl taint nodes --all node-role.kubernetes.io/control-plane-"
