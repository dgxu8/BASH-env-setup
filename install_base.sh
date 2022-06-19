#!/bin/bash

echo "https://github.com/dennisgxu/BASH-env-setup.git"

sudo apt update
sudo apt upgrade

# apt installs
sudo apt install ripgrep
sudo apt install fd-find
# Symlinke fdfind to fd
sudo ln -s /usr/bin/fdfind /usr/bin/fd

sudo apt install python3-pip
sudo apt install exuberant-ctags
sudo apt install git-gui

echo "Installing RUST"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
#mkdir ~/.cargo
#cp cargo_env ~/.cargo/env

echo "Installing cargo things"
cargo install --locked code-minimap

echo "Installing rando packages"
mkdir -p ~/Downloads/setup
cd ~/Downloads/setup

echo "Installing nvim"
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.deb
sudo apt install ./nvim-linux64.deb
nvim --version
sudo apt install python3-neovim

echo "Installing tmux"
echo "Download from latest release at:"
echo "https://github.com/tmux/tmux/releases/latest"
echo "Run curl -LO {download https} to download it"
cp "setup_files/tmux_install.sh" ~/Downloads/setup
echo "Run ./tmux_install.sh afterwards"

echo "Installing git-prompt.sh"
git clone https://github.com/git/git.git --no-checkout git_completion --depth 1
cd git_completion
git sparse-checkout init --cone
git sparse-checkout set contrib/completion
git checkout
cp contrib/completion/git-prompt.sh ~/.git-prompt.sh
cd ..

echo "Installing fuzzyfind"
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

echo "Installing packer.nvim"
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim

echo "Installing tpm"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

echo "Setting up vim configs"
git clone https://github.com/zboothdev/vim-config.git ~/.vim
echo "so ~/.vim/vimrc.vim" > ".vimrc"

echo "Setting up nvim"
mkdir -p ~/.config/nvim
cp init.vim ~/.config/nvim/
