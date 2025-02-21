ARG BASE_IMAGE=ubuntu:noble
ARG IMAGE_TYPE=base

FROM ${BASE_IMAGE} AS jazzy-base

# =================================================================
# Base layer
# =================================================================
ENV DEBIAN_FRONTEND=noninteractive

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
        locales \
    && echo "$LANG UTF-8" >> /etc/locale.gen \
    && locale-gen \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ========================
# Systemd & dbus
# ========================
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

# ========================
# GNOME desktop
# ========================
RUN apt-get update -y \
    && apt-get install -y \
        ca-certificates \
        ubuntu-gnome-desktop \
    && apt-get remove gnome-initial-setup -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ========================
# VNC Server
# ========================
# Install TigerVNC standalone server
RUN apt-get update \
  && apt-get install -y tigervnc-common tigervnc-scraping-server tigervnc-standalone-server tigervnc-xorg-extension \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY common/services/tigervnc@.service /etc/systemd/system/tigervnc@.service
ENV DISPLAY=:2
RUN systemctl enable tigervnc@:2

# ========================
# Applications
# ========================
# Snapd Firefox has problems running in a container, so install from Mozilla PPA
RUN add-apt-repository ppa:mozillateam/ppa \
    && echo 'Package: *\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1001' | tee /etc/apt/preferences.d/mozilla \
    && apt-get update -y \
    && apt-get install -y --allow-downgrades firefox \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
        sudo \
        wget \
        curl \
        git \
        make cmake \
        vim nano \
        gedit gedit-plugins \
        net-tools iputils-ping traceroute \
        libxfont-dev \
        gnome-tweaks gnome-shell-extensions \
        python3 python-is-python3 python3-pip python3-venv \
        x11-xkb-utils xauth xfonts-base xkb-data \
        apt-utils \
        less \
        htop \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ========================
# ROS2 Jazzy
# ========================
ARG ROS_DISTRO=jazzy

RUN add-apt-repository universe \
    && curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-${ROS_DISTRO}-desktop \
    ros-${ROS_DISTRO}-rviz2 \
    ros-${ROS_DISTRO}-ros-gz \
    && rm -rf /var/lib/apt/lists/*

# build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    python3-setuptools \
    python3-rosdep \
    python3-colcon-common-extensions \
    && rm -rf /var/lib/apt/lists/*

RUN rosdep init

# =================================================================
# VirtualGL layer
# =================================================================
FROM jazzy-base AS jazzy-vgl

ARG VIRTUALGL_VERSION=3.1
ARG SOURCEFORGE=https://sourceforge.net/projects

# Install libegl1-mesa from Jammy (required by VirtualGL, but not available on Noble)
RUN apt-get update && apt-get install -y --no-install-recommends \
    libegl1 && \
    curl -fsSL http://archive.ubuntu.com/ubuntu/pool/universe/m/mesa/libegl1-mesa_22.0.1-1ubuntu2_amd64.deb \
    -o /tmp/libegl1-mesa_22.0.1-1ubuntu2_amd64.deb \
    && dpkg -i /tmp/libegl1-mesa_22.0.1-1ubuntu2_amd64.deb \
    && rm -f /tmp/libegl1-mesa_22.0.1-1ubuntu2_amd64.deb

RUN apt-get update && apt-get install -y --no-install-recommends \
    mesa-utils libglu1-mesa libxtst6 libxv1 && \
    rm -rf /var/lib/apt/lists/* && \
    cd /tmp && \
    curl -fsSL \
        -O ${SOURCEFORGE}/virtualgl/files/${VIRTUALGL_VERSION}/virtualgl_${VIRTUALGL_VERSION}_amd64.deb && \
    dpkg -i *.deb && \
    rm -f /tmp/*.deb

ENV PATH=${PATH}:/opt/VirtualGL/bin

# =================================================================
FROM jazzy-${IMAGE_TYPE} AS final
ARG IMAGE_TYPE

# Hide update notification:
RUN echo "Hidden=true" >> /etc/xdg/autostart/update-notifier.desktop

SHELL ["/bin/bash", "-c"]
# Create unprivileged user
# NOTE user hardcoded in tigervnc.service
ARG UID=2000
ARG USER=kasutaja
ARG PASSWD=remrob
RUN useradd ${USER} -u ${UID} -U -d /home/${USER} -m -s /bin/bash

RUN echo "${USER} ALL=(ALL) NOPASSWD: ALL, !/bin/su, !/bin/bash, !/bin/sh" > "/etc/sudoers.d/${USER}"
RUN echo "${USER}:${PASSWD}" | chpasswd
ENV USER="${USER}" \
    HOME="/home/${USER}"
WORKDIR "${HOME}"

ENV XDG_RUNTIME_DIR=/tmp/xdg-runtime-${UID}
RUN mkdir -p $XDG_RUNTIME_DIR && \
    chown -R $USER:$USER $XDG_RUNTIME_DIR && \
    chmod 700 $XDG_RUNTIME_DIR

RUN systemctl mask user@${UID}.service

# **************************************
# remrob.ut.ee dependencies  
# **************************************
RUN rm -rf /etc/localtime
RUN ln -s /usr/share/zoneinfo/Europe/Tallinn /etc/localtime

# screen recording
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
        kazam \
        vlc \
        xdotool \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
COPY common/system/kazam.desktop /usr/share/applications/kazam.desktop
COPY common/system/kazam.conf $HOME/.config/kazam/kazam.conf

# install chrome for webrtc
RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && dpkg -i google-chrome-stable_current_amd64.deb \
    && rm google-chrome-stable_current_amd64.deb

ARG SCRIPTS=$HOME/.scripts
RUN mkdir $SCRIPTS

# Camera shortcut
COPY assets/camera.png $HOME/Pictures/camera.png
COPY common/system/cam.desktop $HOME/.local/share/applications/cam.desktop
COPY common/scripts/launch_camera.sh $SCRIPTS/launch_camera.sh

# Welcome message
COPY common/scripts/welcome_msg.sh $SCRIPTS/welcome_msg.sh
COPY common/scripts/print_message.sh $SCRIPTS/print_message.sh
COPY common/services/terminal_launch.service /etc/systemd/system/terminal_launch.service

RUN systemctl enable terminal_launch.service
RUN chown $USER:$USER $SCRIPTS/launch_camera.sh && \
    chmod +x $SCRIPTS/launch_camera.sh

# **************************************

# GNOME customized config
COPY jazzy/config/user-${IMAGE_TYPE} $HOME/.config/dconf/user
COPY assets/forest_mist.jpg $HOME/Pictures/Wallpapers/

# Set up VNC
RUN mkdir -p $HOME/.vnc
COPY common/system/xstartup $HOME/.vnc/xstartup

RUN chown -R $USER:$USER $HOME

COPY common/scripts/env.sh /.env.sh
RUN echo "source /.env.sh" >> $HOME/.bashrc
RUN echo "XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR}" >> $HOME/.env

COPY jazzy/docker-entrypoint.sh /.docker-entrypoint.sh

EXPOSE 5902

VOLUME ["/sys/fs/cgroup"]
STOPSIGNAL SIGRTMIN+3
CMD [ "/sbin/init" ]

ENTRYPOINT ["/.docker-entrypoint.sh"]