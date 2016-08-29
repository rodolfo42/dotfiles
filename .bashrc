#!/bin/bash

export DOTFILES_DIR=$(dirname $(readlink -n ~/.bashrc))

env_file=$DOTFILES_DIR/env.private

function dbg() {
  if ! [ -z "$DEBUG_DOTFILES" ]; then
    echo "DEBUG $@"
  fi
}

if [ -r "$env_file" ]; then
  dbg source $env_file
  source $env_file
fi

for F in $DOTFILES_DIR/init.d/*; do
  if [ -r "$F" ]; then
    dbg source $F
    source $F
  fi
done

unset dbg
