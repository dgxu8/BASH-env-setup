#!/bin/bash

setup_dir=`pwd`

for script in $(find -name "symlink.sh")
do
    script_path=$(dirname -- "${setup_dir}${script:1}")
    eval "$script $script_path"
done
