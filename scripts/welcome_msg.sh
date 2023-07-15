#!/bin/bash

export DISPLAY=:2

gnome-terminal -- bash -c 'cd ~ && source .scripts/print_message.sh; exec vglrun $SHELL'

