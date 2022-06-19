#!/bin/bash

setup_dir=`pwd`/setup_files

sudo apt install ubuntu-desktop
sudo apt install yad
sudo apt install gedit

ln -sf $setup_dir/wslrc ~/.wslrc

source ~/.bashrc

sudo update-alternatives --config editor
