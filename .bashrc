#!/bin/bash

DIR=`dirname "$(readlink -n "$0")"`

for F in $DIR/init.d/*; do
  if [ -r "$F" ]; then
    source $F
  fi
done
