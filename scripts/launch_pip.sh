#!/bin/bash

#google-chrome --disable-fre --no-default-browser-check --no-first-run "http://192.168.200.201:8000/webrtcstreamer.html?video=Remrob%20field%20%23${ROBOT_CELL}&options=rtptransport%3Dtcp%26timeout%3D60"

# xdotool search "Google Chrome" windowactivate --sync key --clearmodifiers alt+p windowminimize

site="http://192.168.200.201:8000/webrtcstreamer.html?video=Remrob%20field%20%23${ROBOT_CELL}&options=rtptransport%3Dtcp%26timeout%3D60"

google-chrome --disable-fre --no-default-browser-check --no-first-run $site &

sleep 4

chrome_window=$(xdotool search --name "Google Chrome");
# echo $chrome_window

xdotool windowactivate --sync $chrome_window \
   key --clearmodifiers alt+p \
   windowminimize $chrome_window
   # windowactivate $chrome_window # deactivate

sleep 0.4

pip=$(xdotool search --name "Picture in picture" | tail -1);
xdotool windowsize $pip 500 400 windowmove $pip 1300 600

roslaunch robotont_gazebo world_minimaze.launch