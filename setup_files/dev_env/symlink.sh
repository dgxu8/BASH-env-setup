#!/bin/bash

my_path=$1

echo "Symlinking bashrc"
ln -sfv "${my_path}/bashrc" "${HOME}/.bashrc"

echo "Symlinking autin"
mkdir -p "${HOME}/.config/atuin"
ln -sfv "${my_path}/atuin_config.toml" "${HOME}/.config/atuin/config.toml"

echo "Symlinking tmux"
ln -sfv "${my_path}/tmux.conf" "${HOME}/.tmux.conf"

echo "Creating wezterm symlink"
ln -sfvd $my_path/wezterm "${HOME}/.config/"

echo "Creating yazi symlink"
ln -sfvd $my_path/yazi "${HOME}/.config/"
