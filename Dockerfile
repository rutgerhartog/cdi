FROM debian:latest

ARG BUILD_DATE="not set"
ARG VNC_USER="user"
ARG VNC_USER_SHELL="/bin/bash"

LABEL maintainer="rutgerhartog"
LABEL org.label-schema.name="cdi"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.docker.cmd="docker run -d -p 6080:6080"
LABEL org.label-schema.description="A containerised desktop, based on Debian and accessible through your web browser"


ENV VNC_PASSWORD ""
ENV VNC_ONLY "false"
ENV SCREEN_RESOLUTION "1920x1200"
ENV VNC_USER=${VNC_USER}

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
  sudo \
  tigervnc-standalone-server \
  unzip \
  wget \
  xfce4 \
  xfce4-goodies

# Install noVNC and websockify
RUN git clone https://github.com/novnc/noVNC /container/noVNC/ \
  && git clone https://github.com/novnc/websockify /container/noVNC/utils/websockify \
  && ln -s /container/noVNC/utils/launch.sh /usr/local/bin/novnc

# Install icon themes
RUN git clone https://github.com/vinceliuice/Layan-gtk-theme /container/layan \
  && git clone https://github.com/vinceliuice/Tela-icon-theme /container/tela \
  && ./container/layan/install.sh \
  && ./container/tela/install.sh

# Cleanup: make scripts executable and remove clutter from install
RUN chmod -R 755 /usr/local/bin \
  && update-ca-certificates \
  && chown -R "${VNC_USER}" "/home/${VNC_USER}" \
  && chown -R "${VNC_USER}" /container/noVNC

# Drop privileges and run
USER 1337
WORKDIR /home/${VNC_USER}
EXPOSE 6080
CMD ["init"]
