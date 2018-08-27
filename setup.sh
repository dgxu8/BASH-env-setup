#!/bin/bash

echo "starting installation..."
echo "Install fonts-powerline"

dir=`pwd`

if command -v python &> /dev/null; then
    echo "python installed"
else
    echo "ERROR: python needs to me installed"
    exit 1
fi

if command -v pip &> /dev/null; then
    echo "pip installed"
else
    echo "ERROR: pip needs to be installed"
    exit 1
fi

### install mdv
pip install mdv --user

### install powerline-shell
pip install powerline-shell --user

### install powerline text
git clone https://github.com/powerline/fonts.git --depth=1

cd fonts
./install.sh
cd ../

### install fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
cd ~/.fzf 
./install
cd $dir

### install vim-plug
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim 
mkdir ~/.vim/plugged

### install tmux if not installed
if command -v tmux &> /dev/null; then
    echo "tmux installed"
else
    echo "Installing tmux"
    exit 1
fi

### copy .vimrc to ~/
cp -f .vimrc ~/

### install tmux themepack
git clone https://github.com/jimeh/tmux-themepack.git ~/.tmux-themepack
cp -f .tmux.conf ~/
tmux source-file ~/.tmux.conf

### append bashrc
cat .bashrc >> ~/.bashrc

echo "use :PlugInstall to install all vim plugins"
echo "finished setup"
