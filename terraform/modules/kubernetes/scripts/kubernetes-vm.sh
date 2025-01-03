#!/bin/bash

set -e
# Redirect stdout and stderr to a log file
exec > >(tee -a /var/log/k8s-setup.log) 2>&1

echo "Updating system and installing dependencies..."
# Update and install dependencies
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

echo "Adding Docker's official GPG key and repository..."
# Add Docker's official GPG key and repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Installing Docker..."
# Install Docker
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo systemctl enable docker
sudo systemctl start docker

echo "Adding Kubernetes GPG key and repository..."
# Fetch the correct GPG key for Kubernetes repository
sudo curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/kubernetes-archive-keyring.gpg
# Add the Kubernetes repository
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

echo "Installing Kubernetes tools..."
# Install Kubernetes tools
sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo "Disabling swap..."
# Disable swap (required by Kubernetes)
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

echo "Initializing Kubernetes cluster..."
# Initialize Kubernetes cluster
sudo kubeadm init --pod-network-cidr=192.168.0.0/16

echo "Setting up kubeconfig for the admin user..."
# Set up kubeconfig for the admin user
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "Installing Calico for pod networking..."
# Install a pod network (Calico)
kubectl apply -f https://docs.projectcalico.org/v3.25/manifests/calico.yaml

echo "Allowing scheduling on master node (optional, single-node cluster)..."
# Allow scheduling pods on the master node (optional, if single-node cluster)
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
kubectl taint nodes --all node-role.kubernetes.io/master-

echo "Kubernetes setup is complete. Use 'kubectl get nodes' to check node status."
