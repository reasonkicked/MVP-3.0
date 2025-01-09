#!/bin/bash

exec > >(tee -a /var/log/k8s-setup.log) 2>&1
# Exit script on any error
set -e

uname -mov

apt-get upgrade
apt-get update
apt-get -y install wget curl vim openssl git

git clone --depth 1 \
  https://github.com/kelseyhightower/kubernetes-the-hard-way.git

cd kubernetes-the-hard-way

pwd

cat downloads.txt

wget -q --show-progress \
  --https-only \
  --timestamping \
  -P downloads \
  -i downloads.txt

ls -loh downloads

#Install kubectl

{
  chmod +x downloads/kubectl
  cp downloads/kubectl /usr/local/bin/
}

kubectl version --client