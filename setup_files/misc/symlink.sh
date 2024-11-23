#!/bin/bash

my_path=$1

echo "Symlinking pylint"
ln -sfv "${my_path}/pylintrc" "${HOME}/.pylintrc"

echo "Symlinking tio config"
ln -sfv "${my_path}/tio_config" "${HOME}/.config/tio/config"
