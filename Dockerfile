FROM nvidia/cudagl:11.4.2-base-ubuntu20.04

ENV DEBIAN_FRONTEND noninteractive

ARG VIRTUALGL_VERSION=3.0.1
ENV ROS_DISTRO=noetic

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
        locales \
    && echo "$LANG UTF-8" >> /etc/locale.gen \
    && locale-gen \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# =================================================================
# GNOME Desktop
# =================================================================
RUN apt-get update -y \
    && apt-get install -y \
        dbus \
        dbus-x11 \
        systemd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && dpkg-divert --local --rename --add /sbin/udevadm \
    && ln -s /bin/true /sbin/udevadm
RUN systemctl disable systemd-resolved
VOLUME ["/sys/fs/cgroup"]
STOPSIGNAL SIGRTMIN+3
CMD [ "/sbin/init" ]

RUN apt-get update -y \
    && apt-get install -y \
        ca-certificates \
        ubuntu-gnome-desktop \
    && apt-get remove gnome-initial-setup -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# =================================================================
# ROS
# =================================================================
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
RUN apt-get update && \
    apt-get install ros-${ROS_DISTRO}-desktop-full -y

# =================================================================
# VirtualGL
# =================================================================

ARG SOURCEFORGE=https://sourceforge.net/projects
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl wget git apt-utils python3-pip less lsof htop gedit gedit-plugins \
    libegl1-mesa mesa-utils \
    terminator \
    make cmake python x11-xkb-utils xauth xfonts-base xkb-data && \
    rm -rf /var/lib/apt/lists/* && \
    cd /tmp && \
    curl -fsSL \
        -O ${SOURCEFORGE}/virtualgl/files/${VIRTUALGL_VERSION}/virtualgl_${VIRTUALGL_VERSION}_amd64.deb && \
    dpkg -i *.deb && \
    rm -f /tmp/*.deb

ENV PATH ${PATH}:/opt/VirtualGL/bin


# =================================================================
# VNC Server
# =================================================================

# Install TigerVNC server
# NOTE tigervnc because of XKB extension: https://github.com/i3/i3/issues/1983
RUN apt-get update \
  && apt-get install -y tigervnc-common tigervnc-scraping-server tigervnc-standalone-server tigervnc-xorg-extension \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
# NOTE logout will stop tigervnc service -> need to manually start (gdm for graphical login is not working)

COPY tigervnc@.service /etc/systemd/system/tigervnc@.service
ENV DISPLAY=:2
RUN systemctl enable tigervnc@:2

# =================================================================


# ROS dependencies for Robotont   
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
        python3-catkin-tools \
        python3-rosdep \
        ros-${ROS_DISTRO}-joy \
        ros-${ROS_DISTRO}-teleop-twist-keyboard \
        ros-${ROS_DISTRO}-serial \
        ros-${ROS_DISTRO}-tf \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
        net-tools \
        iputils-ping \
        traceroute \
        vim \
        nano \
        gnome-tweaks \
        gnome-shell-extensions \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create unprivileged user
# NOTE user hardcoded in tigervnc.service
# NOTE alternative is to use libnss_switch and create user at runtime -> use entrypoint script
ARG UID=1000
ARG USER=kasutaja
RUN useradd ${USER} -u ${UID} -U -d /home/${USER} -m -s /bin/bash && \
    groupadd vglusers && \
    usermod -aG vglusers ${USER}
    
# RUN echo "$USER:password" | chpasswd
RUN apt-get update && apt-get install -y sudo && apt-get clean && rm -rf /var/lib/apt/lists/* && \
    echo "${USER} ALL=(ALL) NOPASSWD: ALL" > "/etc/sudoers.d/${USER}" && \
    chmod 440 "/etc/sudoers.d/${USER}"

ENV USER="${USER}" \
    HOME="/home/${USER}"
USER "${USER}"


WORKDIR "/home/${USER}"
# Set up VNC
RUN mkdir -p $HOME/.vnc
COPY xstartup $HOME/.vnc/xstartup
# RUN echo "password" | vncpasswd -f >> $HOME/.vnc/passwd && chmod 600 $HOME/.vnc/passwd

SHELL ["/bin/bash", "-c"]

ENV ROS_ROOT=/opt/ros/${ROS_DISTRO}
ENV ROS_PYTHON_VERSION=3

RUN mkdir -p $HOME/catkin_ws/src
WORKDIR $HOME/catkin_ws/src
COPY --chown=1000:1000 src .
COPY realsense-ros/realsense2_description realsense2_description
WORKDIR $HOME/catkin_ws
RUN source /opt/ros/${ROS_DISTRO}/setup.bash && \
    catkin init && \
    catkin build

RUN sudo apt update

# GNOME customized config
COPY user $HOME/.config/dconf/user
COPY img/wallpaper.png $HOME/Pictures/Wallpapers/

#RUN sudo chmod 777 "${HOME}/.config/dconf"
RUN sudo chown -R $USER:$USER $HOME

RUN echo 'source /opt/ros/noetic/setup.bash' >> $HOME/.bashrc
RUN echo 'source ${HOME}/catkin_ws/devel/setup.bash' >> $HOME/.bashrc

# switch back to root to start systemd
USER root

EXPOSE 5902

# RUN mkdir -p /root/.vnc & mkdir -p /root/.config/autostart
# COPY startup.desktop /root/.config/autostart/startup.desktop

# COPY xorg.conf /etc/X11/xorg.conf
COPY docker-entrypoint.sh /.docker-entrypoint.sh
COPY env.sh /.env.sh


# COPY custom.conf /etc/gdm3/custom.conf
# COPY xserverrc /etc/X11/xinit/xserverrc

ENTRYPOINT ["/.docker-entrypoint.sh"]
