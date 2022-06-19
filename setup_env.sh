#!/bin/bash

echo "Setting up bashrc"
cp "setup_files/bashrc" ~/.bashrc

echo "Setting up vim configs"
git clone https://github.com/zboothdev/vim-config.git ~/.vim
echo "so ~/.vim/vimrc.vim" > ".vimrc"
cp "setup_files/vimrc.vim" ~/.vim/
cp "setup_files/plugins-setup.vim" ~/.vim/
cp "setup_files/plugins.vim" ~/.vim/

echo "Setting up nvim"
mkdir -p ~/.config/nvim
cp "setup_files/init.vim" ~/.config/nvim/

echo "Setting up tmux"
cp "setup_files/tmux.conf" ~/.tmux.conf
