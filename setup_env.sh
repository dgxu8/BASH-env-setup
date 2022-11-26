#!/bin/bash

setup_dir=`pwd`/setup_files

echo "Setting up bashrc"
ln -sf $setup_dir/bashrc ~/.bashrc

echo "Setting up vim configs"
git clone https://github.com/zboothdev/vim-config.git ~/.vim
echo "so ~/.vim/vimrc.vim" > ".vimrc"
ln -sf $setup_dir/vimrc.vim ~/.vim/vimrc.vim
ln -sf $setup_dir/plugins-setup.vim ~/.vim/plugins-setup.vim
ln -sf $setup_dir/plugins.vim ~/.vim/plugins.vim

echo "Setting up nvim"
mkdir -p ~/.config/nvim
ln -sf $setup_dir/init.vim ~/.config/nvim/init.vim
ln -sf $setup_dir/plugins.lua ~/.config/nvim/lua/plugins.lua

echo "Setting up lazygit"
ln -sf $setup_dir/lazygit_config.yml ~/.config/lazygit/config.yml

echo "Setting up tmux"
ln -sf $setup_dir/tmux.conf ~/.tmux.conf

# Note: We want to install it manually so we can rebind the save to prompt first
echo "Installing tmux resurrect"
git clone https://github.com/tmux-plugins/tmux-resurrect ~/.tmux/tmux-resurrect
