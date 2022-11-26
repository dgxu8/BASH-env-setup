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
sudo apt install clang
sudo apt install libclang-10-dev
sudo apt install cmake

echo "Installing pip stuff"
sudo apt install python3-pip
pip3 install pyright

echo "Installing RUST"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
sudo apt install cargo

echo "Installing cargo things"
cargo install --locked code-minimap

echo "Installing rando packages"
mkdir -p ~/Downloads/setup
cd ~/Downloads/setup

echo "Installing lazygit"
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[0-35.]+')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
sudo tar xf lazygit.tar.gz -C /usr/local/bin lazygit
lazygit --version

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
echo "You will beed to do a :PackerCompile in nvim to install things"
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
 ~/.local/share/nvim/site/pack/packer/start/packer.nvim

echo "Installing tpm"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

echo "Installing ccls"
git clone --depth=1 --recursive https://github.com/MaskRay/ccls
cd ccls

# Download "Pre-Built Binaries" from https://releases.llvm.org/download.html
# and unpack to /path/to/clang+llvm-xxx.
# Do not unpack to a temporary directory, as the clang resource directory is hard-coded
# into ccls at compile time!
# See https://github.com/MaskRay/ccls/wiki/FAQ#verify-the-clang-resource-directory-is-correct
cmake -H. -BRelease -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH=/usr/lib/llvm-10 \
    -DLLVM_INCLUDE_DIR=/usr/lib/llvm-10/include \
    -DLLVM_BUILD_INCLUDE_DIR=/usr/include/llvm-10/
cmake --build Release
cd Release
sudo make install
cd ../..
