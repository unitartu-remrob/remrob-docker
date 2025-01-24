#!/bin/bash

export DISPLAY=:2

gnome-terminal -- bash -c '
  cd $HOME &&
  source .scripts/print_message.sh &&
  . /etc/environment;
  exec vglrun $SHELL
'

