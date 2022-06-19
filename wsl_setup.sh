#!/bin/bash

sudo apt install ubuntu-desktop
sudo apt install yad
sudo apt install gedit

echo "export LIBGL_ALWAYS_INDIRECT=1" | tee -a ~/.bashrc
echo "export export DISPLAY=localhost:0.0" | tee -a ~/.bashrc
