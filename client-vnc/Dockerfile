ARG DOCKER_REGISTRY_URL
ARG ONEC_VERSION
FROM ${DOCKER_REGISTRY_URL}${DOCKER_REGISTRY_URL:+/}onec-client:${ONEC_VERSION}

LABEL maintainer="Dima Ovcharenko <d.ovcharenko90@gmail.com>, Korus Consulting LLC"

RUN apt-get update \
  
  && apt-mark hold iptables \
  && env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    # X11 и VNC
    x11-xserver-utils \
    x11-utils \
    xvfb \
    x11vnc \
    # Desktop environment
    xfce4 \
    xfce4-goodies \
    # Утилиты
    psmisc \
    xdg-utils \
  # Исправление темы xfce на совместимую
  && sed -i 's%<property name="ThemeName" type="string" value="Xfce"/>%<property name="ThemeName" type="string" value="Raleigh"/>%' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml \
  && rm -rf  \
   /var/lib/apt/lists/* \
   /var/cache/debconf

# Install s6-overlay v3
ARG S6_OVERLAY_VERSION=3.2.2.0
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz \
  && rm -f /tmp/s6-overlay-*.tar.xz

COPY ./client-vnc/configs/rootfs-v3/ /

ENV DISPLAY=:0
ENV DISPLAY_WIDTH=1440
ENV DISPLAY_HEIGHT=900

EXPOSE 5900

ENTRYPOINT ["/init"]
