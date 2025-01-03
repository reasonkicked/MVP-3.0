#!/bin/bash

set -e

# Redirect stdout and stderr to a log file
exec > >(tee -a /var/log/k8s-setup.log) 2>&1

echo "Step 1: Disable swap and make it persistent..."
# Disable swap
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

echo "Step 2: Load necessary kernel modules..."
# Load kernel modules
sudo modprobe overlay
sudo modprobe br_netfilter

# Persist kernel modules
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

echo "Step 3: Configure sysctl for Kubernetes networking..."
# Configure sysctl for Kubernetes networking
cat <<EOF | sudo tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Apply sysctl settings
sudo sysctl --system

echo "Step 4: Install containerd..."
# Install containerd dependencies
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Add Docker GPG key and repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install containerd
sudo apt-get update
sudo apt-get install -y containerd.io

# Configure containerd
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo systemctl restart containerd
sudo systemctl enable containerd

echo "Step 5: Install Kubernetes components..."
# Add Kubernetes GPG key and repository
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install kubeadm, kubelet, and kubectl
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo "Step 6: Initialize Kubernetes control plane (if this is the master node)..."
if [[ $1 == "init" ]]; then
    sudo kubeadm init --pod-network-cidr=10.244.0.0/16

    echo "Step 7: Configure kubectl for the current user..."
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

    echo "Step 8: Install Flannel CNI plugin..."
    kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

    echo "Kubernetes control plane setup is complete!"
fi

echo "Step 9: Join worker node to the cluster (if this is a worker node)..."
if [[ $1 == "join" ]]; then
    if [[ -z $2 || -z $3 ]]; then
        echo "Error: Provide the control plane's IP and token as arguments!"
        echo "Usage: $0 join <CONTROL_PLANE_IP> <TOKEN> <DISCOVERY_TOKEN_CA_CERT_HASH>"
        exit 1
    fi

    sudo kubeadm join $2:6443 --token $3 --discovery-token-ca-cert-hash $4
    echo "Worker node has successfully joined the cluster!"
fi

echo "Unattended Kubernetes setup is complete!"
