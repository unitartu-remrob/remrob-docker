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
# RUN yes | unminimize
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
        net-tools \
        iputils-ping \
        traceroute \
        vim \
        nano \
        gnome-tweaks \
        gnome-shell-extensions \
        sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Screen recording
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
        ffmpeg \
        gir1.2-appindicator3-0.1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ROS dependencies for Robotont   
RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
        python3-catkin-tools \
        python3-rosdep \
        ros-${ROS_DISTRO}-joy \
        ros-${ROS_DISTRO}-teleop-twist-keyboard \
        ros-${ROS_DISTRO}-serial \
        ros-${ROS_DISTRO}-tf

# Hide update notification:
# =================================================================
RUN echo "Hidden=true" >> /etc/xdg/autostart/update-notifier.desktop

# Create unprivileged user
# NOTE user hardcoded in tigervnc.service
# NOTE alternative is to use libnss_switch and create user at runtime -> use entrypoint script
ARG UID=1000
ARG USER=kasutaja
ARG PASSWD=remrob
RUN useradd ${USER} -u ${UID} -U -d /home/${USER} -m -s /bin/bash && \
    groupadd vglusers && \
    usermod -aG vglusers ${USER}

RUN echo "${USER}:${PASSWD}" | chpasswd
ENV USER="${USER}" \
    HOME="/home/${USER}"
USER "${USER}"
WORKDIR "/home/${USER}"

# Set up VNC
RUN mkdir -p $HOME/.vnc
COPY xstartup $HOME/.vnc/xstartup
# RUN echo "password" | vncpasswd -f >> $HOME/.vnc/passwd && chmod 600 $HOME/.vnc/passwd

# =================================================================
# Screen recording applet
# =================================================================
COPY remrob-recorder/video_recorder.py ${HOME}/.local/share/applications/video_recorder.py
# RUN (crontab -l 2>/dev/null; echo "@reboot python3 ${HOME}/.local/share/applications/video_recorder.py --saving_path=/home/kasutaja &") | crontab -
# COPY remrob-recorder ${HOME}/.local/share/applications/remrob-recorder
# RUN mkdir -p ${HOME}/.config/systemd/user
# COPY recorderd/screen_recorder.service ${HOME}/.config/systemd/user/screen_recorder.service
# COPY recorderd/xsession.target ${HOME}/.config/systemd/user/xsession.target
# COPY recorderd/xsessionrc ${HOME}/.xsessionrc
# #RUN echo $PASSWD sudo -S systemctl enable screen_recorder
# #RUN echo $PASSWD sudo -S systemctl daemon-reload
# RUN systemctl --user enable screen_recorder.service
# =================================================================



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

# GNOME customized config
COPY user $HOME/.config/dconf/user
COPY img/wallpaper.png $HOME/Pictures/Wallpapers/

#RUN sudo chmod 777 "${HOME}/.config/dconf"
#RUN echo $PASSWD sudo -S chown -R $USER:$USER $HOME

# sudo and VirtualGL compatibility: https://groups.google.com/g/virtualgl-users/c/It-4AmVw6qA (Hide error outputs)
RUN echo "alias sudo='env -u LD_PRELOAD sudo'" >> $HOME/.bashrc
RUN echo "alias ping='env -u LD_PRELOAD ping'" >> $HOME/.bashrc
# This will source the env file with every new terminal instance
RUN echo "source /.env.sh" >> $HOME/.bashrc

# Bash aliases

# Git pushing scripts:
RUN mkdir -p $HOME/.git_scripts
COPY git_mod/* $HOME/.git_scripts/

RUN touch "${HOME}/.bash_aliases"
RUN echo "alias submit_code='source ${HOME}/.git_scripts/inside_push.sh'" >> ${HOME}/.bash_aliases
RUN echo "alias undo_changes='source ${HOME}/.git_scripts/inside_reclone.sh'" >> ${HOME}/.bash_aliases

RUN echo "source /opt/ros/noetic/setup.bash" >> $HOME/.bashrc
RUN echo "source ${HOME}/catkin_ws/devel/setup.bash" >> $HOME/.bashrc
RUN echo "export ROS_MASTER_URI=http://localhost:11311" >> $HOME/.bashrc

# switch back to root to start systemd
USER root
RUN chown -R $USER:$USER $HOME

EXPOSE 5902

# RUN mkdir -p /root/.vnc & mkdir -p /root/.config/autostart
# COPY startup.desktop /root/.config/autostart/startup.desktop

# COPY xorg.conf /etc/X11/xorg.conf
COPY docker-entrypoint.sh /.docker-entrypoint.sh
COPY env.sh /.env.sh

# COPY custom.conf /etc/gdm3/custom.conf
# COPY xserverrc /etc/X11/xinit/xserverrc

ENTRYPOINT ["/.docker-entrypoint.sh"]
