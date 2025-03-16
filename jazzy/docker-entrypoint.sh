#!/bin/bash

# Set vnc password
echo "$PASSWORD" | vncpasswd -f > $HOME/.vnc/passwd && chmod 600 $HOME/.vnc/passwd
chown $USER:$USER $HOME/.vnc/passwd

echo "${USER} ALL=(ALL) NOPASSWD: ALL, !/bin/su, !/bin/bash, !/bin/sh" > "/etc/sudoers.d/${USER}"

if [ -d $HOME/ros2_ws ]; then
    chown -R 2000:2000 $HOME/ros2_ws
fi

if [ -d /opt/VirtualGL ]; then
    echo "VGL_DISPLAY=${VGL_DISPLAY}" >> $HOME/.env
    echo "__GLX_VENDOR_LIBRARY_NAME=nvidia" >> $HOME/.env
    echo "__NV_PRIME_RENDER_OFFLOAD=1" >> $HOME/.env 

    # sudo and VirtualGL compatibility: https://groups.google.com/g/virtualgl-users/c/It-4AmVw6qA (Hide error outputs)
    echo "alias ping='env -u LD_PRELOAD ping'" >> $HOME/.bashrc
    echo "alias sudo='env -u LD_PRELOAD sudo'" >> $HOME/.bashrc
fi

# source ROS overlay
echo "source /opt/ros/jazzy/setup.bash" >> $HOME/.bashrc

exec "$@"