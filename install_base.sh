#!/bin/bash

echo "https://github.com/dennisgxu/BASH-env-setup.git"

echo ""
echo "=== Updating apt ==="
sudo apt update
sudo apt upgrade
sudo apt install ca-certificates curl gnupg

# Needed for gpg installs (like nodejs)
sudo mkdir -m 0755 -p /etc/apt/keyrings/

echo ""
echo "=== Installing pip ==="
sudo apt install python3-pip

echo ""
echo "=== Upgrading pip ==="
sudo -H pip3 install pip --upgrade --force

echo ""
echo "\n=== Installing Base Python Packages ==="
sudo pip3 install pyyaml
sudo pip3 install prompt_toolkit
