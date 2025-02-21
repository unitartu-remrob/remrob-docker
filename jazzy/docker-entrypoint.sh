#!/bin/bash

# Set vnc password
echo "$PASSWORD" | vncpasswd -f > $HOME/.vnc/passwd && chmod 600 $HOME/.vnc/passwd
chown $USER:$USER $HOME/.vnc/passwd

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