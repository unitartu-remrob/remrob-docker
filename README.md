

# A vnc-ros2-gnome image with HA enabled

## Main components

- GNOME Desktop
- ROS2 Jazzy Jalisco
- TigerVNC server
- VirtualGL

Inspired by:
- https://github.com/darkdragon-001/Dockerfile-Ubuntu-Gnome
- https://github.com/wwwshwww/novnc-ros-desktop
- https://github.com/willkessler/nvidia-docker-novnc
- https://github.com/Open-UAV/openuav-turbovnc

---
## Requirements

- Podman

&nbsp;

# Setup

### Building the image

`podman build -t remrob:ros2 --format docker --file Dockerfile.ros2 .`

### Running the container

```
podman run --rm
  --cgroupns=host \
  --tmpfs /run  --tmpfs /run/lock --tmpfs /tmp \
  --cap-add SYS_BOOT --cap-add SYS_ADMIN \
  -v /sys/fs/cgroup:/sys/fs/cgroup \
  --systemd=true \
  --name=robo-1 \
  -p 5902:5902 \
  --device nvidia.com/gpu=all \
  -v /tmp/.X11-unix/X1:/tmp/.X11-unix/X1 \
  -e PASSWORD=remrob \
  remrob:ros2
  ```

The VNC server is running on port 5902, connect to it with any VNC client you have (pw: remrob). The Nvidia GPU graphics are being tunneled through host's DISPLAY :1.


&nbsp;&nbsp;

# Acknowledgments

Completed with the support by IT Academy Programme of Education and Youth Board of Estonia.

Valminud Haridus- ja Noorteameti IT Akadeemia programmi toel.
