#!/bin/bash

echo "https://github.com/dennisgxu/BASH-env-setup.git"

echo ""
echo "=== Updating apt ==="
sudo apt update
sudo apt upgrade

echo ""
echo "=== Installing pip ==="
sudo apt install python3-pip

echo ""
echo "=== Upgrading pip ==="
sudo -H pip3 install pip --upgrade --force

echo ""
echo "\n=== Installing Base Python Packages ==="
sudo pip3 install pyyaml
