#!/bin/bash

my_path=$1

echo "Symlinking localrc"
ln -sfv "${my_path}/wslrc" "${HOME}/.localrc"
