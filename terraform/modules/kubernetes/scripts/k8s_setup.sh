#!/bin/bash

# Exit script on any error
set -e

# Disable swap
echo "Disabling swap..."
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Load kernel modules
echo "Loading necessary kernel modules..."
sudo modprobe overlay
sudo modprobe br_netfilter

# Configure sysctl
echo "Setting up sysctl parameters for Kubernetes..."
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system

# Update system and install prerequisites
echo "Updating system and installing prerequisites..."
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
echo "Installing Docker GPG key and setting up repository..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install and configure containerd
echo "Installing and configuring containerd..."
sudo apt-get update
sudo apt-get install -y containerd.io
sudo containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo systemctl restart containerd
sudo systemctl enable containerd

# Add Kubernetes repository and install kubeadm, kubelet, kubectl
echo "Setting up Kubernetes repository and installing tools..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Initialize Kubernetes cluster
CONTROL_PLANE_IP=$(hostname -I | awk '{print $1}')
echo "Initializing Kubernetes control plane..."
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=${CONTROL_PLANE_IP}

# Configure kubectl for the current user
echo "Setting up kubectl for the current user..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Deploy Flannel CNI
echo "Deploying Flannel CNI..."
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# Generate join command for worker nodes
TOKEN=$(kubeadm token create)
DISCOVERY_TOKEN_CA_CERT_HASH=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | awk '{print $2}')
echo "Join command: kubeadm join ${CONTROL_PLANE_IP}:6443 --token ${TOKEN} --discovery-token-ca-cert-hash sha256:${DISCOVERY_TOKEN_CA_CERT_HASH}"

# Verify setup
echo "Verifying setup..."
kubectl get pods -A
