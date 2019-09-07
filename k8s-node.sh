#!/bin/bash -x
echo "This script is written to work with Ubuntu 16.04"
sleep 3
echo
echo "Disable swap until next reboot"
echo "swapoff should not needed on azure VM"
#sudo swapoff -a

echo "Update the VM image"
sudo apt-get update && sudo apt-get upgrade -y
echo
echo "Install Docker"
sleep 3

# get ubuntu version
# lsb_release -a

# Ubuntu 18.04.2 LTS
# sudo apt-get install -y \
#     apt-transport-https \
#     ca-certificates \
#     curl \
#     gnupg-agent \
#     software-properties-common
# 
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# 
# sudo add-apt-repository \
#    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
#    $(lsb_release -cs) \
#    stable"
# 
# sudo apt-get install -y docker-ce=18.06.1~ce~3-0~ubuntu 

# Ubuntu 16.04.6 LTS
#sudo apt-get install -y --allow-downgrades docker.io=18.06.1-0ubuntu1.2~16.04.1
sudo apt-get install -y docker.io

echo
echo "Install kubeadm and kubectl"
sleep 3

sudo sh -c "echo 'deb http://apt.kubernetes.io/ kubernetes-xenial main' >> /etc/apt/sources.list.d/kubernetes.list"

sudo sh -c "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -"

sudo apt-get update

sudo apt-get install -y kubeadm=1.15.1-00 kubelet=1.15.1-00 kubectl=1.15.1-00

echo "k8s node configuration Done"





