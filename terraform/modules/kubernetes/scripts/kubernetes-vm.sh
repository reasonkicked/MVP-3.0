#!/bin/bash
set -e

# Update and install prerequisites
apt-get update -y
apt-get upgrade -y
#apt-get install -y apt-transport-https ca-certificates curl software-properties-common
#
## Install Docker
#curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
#add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
#apt-get update -y
#apt-get install -y docker-ce
#
## Enable Docker service
#systemctl enable docker
#systemctl start docker
#
## Install kubeadm, kubelet, and kubectl
#curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
#add-apt-repository "deb https://apt.kubernetes.io/ kubernetes-xenial main"
#apt-get update -y
#apt-get install -y kubelet kubeadm kubectl
#
## Initialize Kubernetes cluster
#kubeadm init --pod-network-cidr=192.168.0.0/16
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
