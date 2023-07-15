#!/bin/bash

export DISPLAY=:2

gnome-terminal -- bash -c 'echo ----; exec $SHELL'