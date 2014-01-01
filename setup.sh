#!/bin/sh

DIR=$(cd $(dirname $0); pwd)

# Install dotfiles
DOT_FILES=( .vimrc .gvimrc )
for file in ${DOT_FILES[@]}
do
    if [ ! -f $HOME/$file ]; then
        ln -s $DIR/$file $HOME/$file
    fi
done
