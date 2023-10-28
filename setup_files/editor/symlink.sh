#!/bin/bash

my_path=$1

echo "Symlinking vim files"
echo "so ~/.vim/plugins.vim" > "${HOME}/.vimrc"
echo "so ~/.vim/vimrc.vim" >> "${HOME}/.vimrc"

mkdir -p ~/.vim/
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
for vim_file in $(find "${my_path}/vim/" -name "*.vim")
do
    dest="${HOME}/.vim/$(basename ${vim_file})"
    ln -sfv "${vim_file}" "${dest}"
done

echo "Creating nvim symlink"
ln -sfvd $my_path/nvim "${HOME}/.config/"
