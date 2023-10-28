#!/bin/bash

my_path=$1

echo "Symlinking pylint"
ln -sfv "${my_path}/pylintrc" "${HOME}/.pylintrc"
