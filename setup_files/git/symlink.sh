#!/bin/bash

my_path=$1

echo "Symlinking lazygit"
mkdir -p "${HOME}/.config/lazygit"
ln -sfv "${my_path}/lazygit_config.yaml" "${HOME}/.config/lazygit/config.yml"

echo "Copying gitconfig"
cp "${my_path}/gitconfig" "${HOME}/.gitconfig"
