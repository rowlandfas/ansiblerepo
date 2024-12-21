#!/bin/bash
#update instance and install ansible
apt-get update -y
apt-get install software-properties-common -y
add-apt-repository --yes --update ppa:ansible/ansible
apt-get install ansible -y
sudo hostnamectl set-hostname ansible