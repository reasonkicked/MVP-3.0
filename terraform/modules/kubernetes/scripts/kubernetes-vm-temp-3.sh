#!/bin/bash

exec > >(tee -a /var/log/k8s-setup.log) 2>&1
set -e

echo "Starting Kubernetes setup..."

# Step 1: Disable swap
echo "Disabling swap..."
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

# Step 2: Update sysctl settings for Kubernetes networking
echo "Setting up sysctl for Kubernetes networking..."
cat <<EOF | sudo tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system

# Step 3: Install required dependencies
echo "Installing required dependencies..."
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl

# Step 4: Add Kubernetes apt repository
echo "Adding Kubernetes apt repository..."
sudo curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /usr/share/keyrings/kubernetes-apt-keyring.gpg
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb [signed-by=/usr/share/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /
EOF

# Step 5: Install kubeadm, kubelet, and kubectl
echo "Installing kubeadm, kubelet, and kubectl..."
sudo apt-get update -y
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Step 6: Install container runtime (containerd)
echo "Installing containerd..."
sudo apt-get install -y containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo systemctl restart containerd
sudo systemctl enable containerd

# Step 7: Initialize Kubernetes cluster
CONTROL_PLANE_IP=$(hostname -I | awk '{print $1}')
echo "Initializing Kubernetes cluster..."
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=${CONTROL_PLANE_IP}

# Step 8: Set up kubectl for the current user
echo "Setting up kubectl for the current user..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Step 9: Wait for API server readiness
echo "Waiting for API server to become ready..."
for i in {1..40}; do
    if kubectl get --raw='/healthz' &>/dev/null; then
        echo "API server is healthy."
        break
    fi
    echo "API server not ready, retrying in 5 seconds... ($i/40)"
    sleep 5
done

if ! kubectl get --raw='/healthz' &>/dev/null; then
    echo "API server did not become ready in time. Exiting."
    exit 1
fi

# Step 10: Deploy a pod network (Flannel)
echo "Deploying Flannel CNI..."
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml --validate=false || {
    echo "Failed to deploy Flannel CNI. Retrying..."
    sleep 10
    kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml --validate=false
}

# Step 11: Verify cluster setup
echo "Verifying Kubernetes setup..."
kubectl get nodes
kubectl get pods -A

echo "Kubernetes setup completed successfully!"
