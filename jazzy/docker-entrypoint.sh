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

# **************************************
# remrob.ut.ee settings
# **************************************
echo "GIT_PAT=${GIT_PAT}" >> $HOME/.env
echo "ROBOT_CELL=${ROBOT_CELL}" >> $HOME/.env
echo "ROS_DOMAIN_ID=${ROS_DOMAIN_ID}" >> $HOME/.env

# check if ROBOT_CELL is set (for simulation the camrea shortcut should be removed)
if [[ $ROBOT_CELL == "" ]]; then
	rm $HOME/.local/share/applications/cam.desktop
fi

# set VLC as default video player
sed -n '
1i[Default Applications]
/^video/{
s/Totem/vlc/
s/org\.gnome\.//p
}' /usr/share/applications/defaults.list > $HOME/.local/share/applications/defaults.list

# **************************************

exec "$@"