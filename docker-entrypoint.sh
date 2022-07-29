#!/bin/bash


# Set vnc password
echo "$PASSWORD" | vncpasswd -f >> $HOME/.vnc/passwd && chmod 600 $HOME/.vnc/passwd
chown $USER:$USER $HOME/.vnc/passwd


# Since this entrypoint is run as root, the environment variable passed in run or compose will not be available to the container user, that's why we write them out manually here

# Import docker-compose env into user domain
echo "ROS_MASTER=${ROS_MASTER}" >> $HOME/.env
echo "VGL_DISPLAY=${VGL_DISPLAY}" >> $HOME/.env

# Source the env and set ROS_MASTER in user .bashrc accordingly
# -------------------------------------------------------------------
# echo 'vglrun /bin/bash' >> $HOME/.bashrc # Enable VirtualGL on every instance
echo 'source /.env.sh' >> $HOME/.bashrc # This will source the env file with every new terminal instance
echo 'export ROS_MASTER_URI=http://${ROS_MASTER}:11311' >> $HOME/.bashrc

exec "$@"

