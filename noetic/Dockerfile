ARG BASE_IMAGE=ubuntu:focal
ARG IMAGE_TYPE=base

FROM ${BASE_IMAGE} AS noetic-base

# =================================================================
# Base layer
# =================================================================
ENV DEBIAN_FRONTEND=noninteractive

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
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
# VNC server
# ========================
# TigerVNC standalone server
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
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
        sudo \
        curl \
        wget \
        git \
        make cmake  \
        vim nano \
        gedit gedit-plugins \
        net-tools iputils-ping traceroute \
        gnome-tweaks gnome-shell-extensions \
        python3 python-is-python3 python3-pip \
        x11-xkb-utils xauth xfonts-base xkb-data \
        apt-utils \
        less \
        htop \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ========================
# ROS Noetic
# ========================
ENV ROS_DISTRO=noetic

RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
RUN apt-get update && \
    apt-get install ros-${ROS_DISTRO}-desktop-full -y

# =================================================================
# VirtualGL layer
# =================================================================
FROM noetic-base AS noetic-vgl

ARG VIRTUALGL_VERSION=3.1
ARG SOURCEFORGE=https://sourceforge.net/projects

RUN apt-get update && apt-get install -y --no-install-recommends \
    libegl1-mesa mesa-utils && \
    rm -rf /var/lib/apt/lists/* && \
    cd /tmp && \
    curl -fsSL \
        -O ${SOURCEFORGE}/virtualgl/files/${VIRTUALGL_VERSION}/virtualgl_${VIRTUALGL_VERSION}_amd64.deb && \
    dpkg -i *.deb && \
    rm -f /tmp/*.deb

ENV PATH ${PATH}:/opt/VirtualGL/bin

# =================================================================
FROM noetic-${IMAGE_TYPE} AS final
ARG IMAGE_TYPE

# Hide update notification:
RUN echo "Hidden=true" >> /etc/xdg/autostart/update-notifier.desktop

SHELL ["/bin/bash", "-c"]
# Create unprivileged user
# NOTE user hardcoded in tigervnc.service
ARG UID=1000
ARG USER=kasutaja
ARG PASSWD=remrob
RUN useradd ${USER} -u ${UID} -U -d /home/${USER} -m -s /bin/bash && \
    groupadd vglusers && \
    usermod -aG vglusers ${USER}

RUN echo "${USER}:${PASSWD}" | chpasswd
ENV USER="${USER}" \
    HOME="/home/${USER}"
WORKDIR "/home/${USER}"

ENV XDG_RUNTIME_DIR=/tmp/xdg-runtime-${UID}
RUN mkdir -p $XDG_RUNTIME_DIR && \
    chown -R $USER:$USER $XDG_RUNTIME_DIR && \
    chmod 700 $XDG_RUNTIME_DIR

RUN systemctl mask user@${UID}.service

# GNOME customized config
COPY noetic/config/user-${IMAGE_TYPE} $HOME/.config/dconf/user
COPY assets/wallpaper.png $HOME/Pictures/Wallpapers/

# Set up VNC
RUN mkdir -p $HOME/.vnc
COPY common/system/xstartup $HOME/.vnc/xstartup

RUN chown -R $USER:$USER $HOME

COPY common/scripts/env.sh /.env.sh
RUN echo "source /.env.sh" >> $HOME/.bashrc
RUN echo "XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR}" >> $HOME/.env

COPY noetic/docker-entrypoint.sh /.docker-entrypoint.sh

EXPOSE 5902

VOLUME ["/sys/fs/cgroup"]
STOPSIGNAL SIGRTMIN+3
CMD [ "/sbin/init" ]

ENTRYPOINT ["/.docker-entrypoint.sh"]
