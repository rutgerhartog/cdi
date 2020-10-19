FROM debian:latest

ARG build_date="not set"
ARG VNC_USER="user"
ARG VNC_USER_SHELL="/bin/bash"

LABEL maintainer="rutgerhartog"
LABEL org.label-schema.name="debian-desktop"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.docker.cmd="docker run -d -p 6080:6080"
LABEL org.label-schema.description="A containerized desktop with VNC, based on Debian"


ENV VNC_PASSWORD ""
ENV SCREEN_RESOLUTION "1920x1200"


# Create user
RUN adduser --disabled-password --gecos "" --uid 1337 \
 --shell ${VNC_USER_SHELL} ${VNC_USER} \
 && mkdir -p /home/${VNC_USER}/.config \
 && mkdir -p /home/${VNC_USER}/.ssh 


# Copy stuff
COPY configuration/dotfiles /container/.config
COPY configuration/backgrounds /usr/share/backgrounds
COPY scripts /usr/local/bin

# Install packages necessary to perform updates through HTTPS instead of HTTP
RUN apt-get clean && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https ca-certificates

# Use an updated sources list for apt
COPY sources.list /etc/apt/sources.list

# Install packages
RUN apt-get clean && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  apt-transport-https \
  apt-utils \
  ca-certificates \
  curl \
  git \
  gnupg2 \
  lsb-release \
  nano \
  net-tools \
  procps \
  python \
  tigervnc-standalone-server \
  unzip \
  wget \
  xfce4 \
  xfce4-goodies

# Install noVNC and websockify
RUN git clone https://github.com/novnc/noVNC /container/noVNC/ \
  && git clone https://github.com/novnc/websockify /container/noVNC/utils/websockify

# Install icon themes
RUN git clone https://github.com/vinceliuice/Layan-gtk-theme /container/layan \
  && git clone https://github.com/vinceliuice/Tela-icon-theme /container/tela \
  && ./container/layan/install.sh \
  && ./container/tela/install.sh

# Cleanup: make scripts executable and remove clutter from install
RUN chmod -R 755 /usr/local/bin \
  && update-ca-certificates \
  && mv /tmp/.config/xfce4 "/home/${VNC_USER}/.config/xfce4" \
  && chown -R "${VNC_USER}" "/home/${VNC_USER}" \
  && chown -R "${VNC_USER}" /container/noVNC \
  && ln -s /container/noVNC/utils/launch.sh /usr/local/bin/novnc \
  && rm -rf /tmp/.config

# Only in dev mode: allow VNC_USER to sudo
RUN if [ "${#DEV_MODE}" ! -eq 0 ]; then apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y sudo \
  && echo "${VNC_USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers; fi

# Drop privileges and run
USER 1337
WORKDIR /home/${VNC_USER}
EXPOSE 6080
CMD ["init"]
