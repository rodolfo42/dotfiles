#!/bin/bash

export DOTFILES_DIR=$(dirname $(readlink -n ~/.bashrc))

for F in $DOTFILES_DIR/init.d/*; do
  if [ -r "$F" ]; then
    source $F
  fi
done
