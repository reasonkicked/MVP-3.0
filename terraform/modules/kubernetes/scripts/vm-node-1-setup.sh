#!/bin/bash

exec > >(tee -a /var/log/k8s-setup.log) 2>&1
# Exit script on any error
set -e

uname -mov

apt-get upgrade
apt-get update
apt-get -y install wget curl vim openssl git