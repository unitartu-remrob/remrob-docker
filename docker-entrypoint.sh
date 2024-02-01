#!/bin/bash

# Set vnc password
echo "$PASSWORD" | vncpasswd -f > $HOME/.vnc/passwd && chmod 600 $HOME/.vnc/passwd
chown $USER:$USER $HOME/.vnc/passwd

# Since this entrypoint is run as root, the environment variable passed in run or compose will not be available to the container user, that's why we write them out manually here

# Import docker-compose env into user domain
echo "ROS_MASTER=${ROS_MASTER}" > $HOME/.env
echo "VGL_DISPLAY=${VGL_DISPLAY}" >> $HOME/.env
echo "GIT_PAT=${GIT_PAT}" >> $HOME/.env
echo "ROBOT_CELL=${ROBOT_CELL}" >> $HOME/.env

# Source the env and set ROS_MASTER in user .bashrc accordingly
# -------------------------------------------------------------------
sed -i '/ROS_MASTER_URI/c\export ROS_MASTER_URI=http://${ROS_MASTER}:11311' $HOME/.bashrc

# Set primitive sudo restrictions, these don't really prevent anything, just basic emulation of a regular system for UX
echo "${USER} ALL=(ALL) NOPASSWD: ALL, !/bin/su, !/bin/bash, !/bin/sh" > "/etc/sudoers.d/${USER}"


chmod +x $HOME/.launch_camera.sh
chmod +x $HOME/.launch_pip.sh

sed -n '
1i[Default Applications]
/^video/{
s/Totem/vlc/
s/org\.gnome\.//p
}' /usr/share/applications/defaults.list > $HOME/.local/share/applications/defaults.list

exec "$@"

