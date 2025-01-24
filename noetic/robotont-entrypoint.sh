#!/bin/bash

# merge the entrypoint script from the base image
. /.docker-entrypoint.sh

echo "ROS_MASTER=${ROS_MASTER}" > $HOME/.env
echo "GIT_PAT=${GIT_PAT}" >> $HOME/.env
echo "ROBOT_CELL=${ROBOT_CELL}" >> $HOME/.env

sed -i '/ROS_MASTER_URI/c\export ROS_MASTER_URI=http://${ROS_MASTER}:11311' $HOME/.bashrc


# check if ROBOT_CELL is set (for simulation the camrea shortcut should be removed)
# if [[ -v $ROBOT_CELL ]]
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

exec "$@"