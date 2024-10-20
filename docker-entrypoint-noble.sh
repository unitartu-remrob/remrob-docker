#!/bin/bash

# Set vnc password
echo "$PASSWORD" | vncpasswd -f > $HOME/.vnc/passwd && chmod 600 $HOME/.vnc/passwd
chown $USER:$USER $HOME/.vnc/passwd

echo "${USER} ALL=(ALL) NOPASSWD: ALL, !/bin/su, !/bin/bash, !/bin/sh" > "/etc/sudoers.d/${USER}"

echo "VGL_DISPLAY=:2" >> $HOME/.env
echo "__GLX_VENDOR_LIBRARY_NAME=nvidia" >> $HOME/.env
echo "__NV_PRIME_RENDER_OFFLOAD=1" >> $HOME/.env

echo "source /opt/ros/jazzy/setup.bash" >> $HOME/.bashrc
echo "source $HOME/ros2_ws/install/local_setup.bash" >> $HOME/.bashrc

exec "$@"