#!/bin/bash

my_path=$1

echo "Symlinking tio config"
mkdir -p "${HOME}/.config/tio/"
ln -sfvi "${my_path}/tio_config" "${HOME}/.config/tio/config"
