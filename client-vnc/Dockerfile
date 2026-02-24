ARG DOCKER_REGISTRY_URL
ARG ONEC_VERSION
FROM ${DOCKER_REGISTRY_URL:+"$DOCKER_REGISTRY_URL/"}onec-client:${ONEC_VERSION} AS base

FROM debian:bookworm-slim

ARG ONEC_VERSION

ARG ONEC_UID=1000
ARG ONEC_GID=1000

COPY --from=base /opt /opt

RUN apt-get update \
  && apt-mark hold iptables \
  && env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    dbus-x11 \
    psmisc \
    xdg-utils \
    x11-xserver-utils \
    x11-utils \
    xvfb \
  && env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    xfce4 \
    xfce4-goodies \
  && sed -i 's%<property name="ThemeName" type="string" value="Xfce"/>%<property name="ThemeName" type="string" value="Raleigh"/>%' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    dirmngr \
    gnupg \
  && echo "deb http://http.debian.net/debian/ bookworm main contrib non-free" > /etc/apt/sources.list \
  && echo "deb http://http.debian.net/debian/ bookworm-backports main" >> /etc/apt/sources.list \
  && echo "deb http://http.debian.net/debian/ bookworm-proposed-updates main contrib non-free" >> /etc/apt/sources.list \
  && echo "deb http://security.debian.org/debian-security/ bookworm-security main contrib non-free" >> /etc/apt/sources.list \
  && echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      ca-certificates \
      git \
      locales \
      ttf-mscorefonts-installer \
      libfontconfig1 \
      libgsf-1-114 \
      libglib2.0-0 \
      libgtk2.0-0 \
      libodbc1 \
      libtcmalloc-minimal4 \
      libmagickwand-6.q16-6 \
      libwebkit2gtk-4.0-37 \
      at-spi2-core \
      procps \
      x11vnc \
      iproute2 \
      libglu1-mesa \
      xz-utils \
  # Install libpng12-0 from debian-snapshot
  && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 7638D0442B90D010 8B48AD6246925553 \
  && echo "deb http://snapshot.debian.org/archive/debian/20160413T160058Z/ unstable main" > /etc/apt/sources.list.d/debian-snapshot.list \
  && apt-get -o Acquire::AllowInsecureRepositories=true -o Acquire::Check-Valid-Until=false update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-unauthenticated --no-install-recommends \
      usrmerge \  
      libpng12-0 \
  && rm -rf  /etc/apt/sources.list.d/debian-snapshot.list \
  && apt-get update \
  # Install libwebkitgtk from stretch
  && echo "deb http://archive.debian.org/debian/ stretch main contrib non-free" > /etc/apt/sources.list.d/stretch.list \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    libwebkitgtk-3.0-0 \
  && rm -rf  /etc/apt/sources.list.d/stretch.list \
  && apt-get update \
  && rm -rf  \
    /var/lib/apt/lists/* \
    /var/cache/debconf \
  && localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8
ENV LANG=ru_RU.UTF-8

# remove DST Root CA X3 cert if it exists
COPY ./scripts/remove-dst-root-ca-x3.sh /remove-dst-root-ca-x3.sh
RUN chmod +x /remove-dst-root-ca-x3.sh \
  && /remove-dst-root-ca-x3.sh \
  && rm /remove-dst-root-ca-x3.sh

# Create user for 1C
RUN groupadd -r grp1cv8 --gid=$ONEC_GID \
  && useradd -r -g grp1cv8 --uid=$ONEC_UID --home-dir=/home/usr1cv8 --shell=/sbin/nologin usr1cv8 \
  && mkdir -p /home/usr1cv8/.1cv8 \
  && chown -R usr1cv8:grp1cv8 /home/usr1cv8

# Install s6-overlay v3
ARG S6_OVERLAY_VERSION=3.2.2.0
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz \
  && rm -f /tmp/s6-overlay-*.tar.xz

COPY ./configs/client-vnc/rootfs-v3/ /

ENV DISPLAY=:0
ENV DISPLAY_WIDTH=1440
ENV DISPLAY_HEIGHT=900

EXPOSE 5900

ENTRYPOINT ["/init"]
