#!/bin/bash
export DISPLAY=:2;

run_in_new_terminal() {
    gnome-terminal -- bash -c "
        cd \$HOME &&
        . /etc/environment &&
        export VGL_DISPLAY=:1;
        source /opt/ros/noetic/setup.bash &&
        source $HOME/catkin_ws/devel/setup.bash &&
        vglrun $1;
    "
}

# run_in_new_terminal "roslaunch robotont_driver fake_driver.launch"
# run_in_new_terminal "rosrun teleop_twist_keyboard teleop_twist_keyboard.py"

run_in_new_terminal "roslaunch robotont_gazebo world_minimaze.launch"
sleep 0.2;
run_in_new_terminal "rosrun teleop_twist_keyboard teleop_twist_keyboard.py"
# xdotool windowclose $window_id;
# xdotool key q; xdotool key q; xdotool key q;
# xdotool key j;
# sleep 0.1;
# xdotool key i;
# sleep 0.1;
# xdotool key o;


sleep 12;

xdo close -a Gazebo


# window_id=$(xdotool search --name "^Gazebo$" | head -n 1);
# xdotool windowclose $window_id;
# sleep 4;

# kill $(pgrep gzclient | head -n 1);

# xdotool windowclose $(xdotool search --name "^Gazebo$" | head -n 1);
# xdotool windowkill $(xdotool search --name "^Gazebo$" | head -n 1);
# rosnode kill -a;

