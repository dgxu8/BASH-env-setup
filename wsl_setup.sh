#!/bin/bash

setup_dir=`pwd`/setup_files

sudo apt install ubuntu-desktop
sudo apt install yad
sudo apt install gedit

ln -sf $setup_dir/wslrc ~/.localrc

source ~/.bashrc

sudo update-alternatives --config editor

# Used so the '+' and '*' registers link the window's clipboard
echo "Installing win32yank.exe"
curl -sLo/tmp/win32yank.zip https://github.com/equalsraf/win32yank/releases/download/v0.0.4/win32yank-x64.zip
unzip -p /tmp/win32yank.zip win32yank.exe > /tmp/win32yank.exe
chmod +x /tmp/win32yank.exe
sudo mv /tmp/win32yank.exe /usr/local/bin/
