# Используем базовый образ для скачивания
ARG DOCKER_REGISTRY_URL
ARG BASE_IMAGE
ARG BASE_TAG
FROM ${DOCKER_REGISTRY_URL}${DOCKER_REGISTRY_URL:+/}${BASE_IMAGE}:${BASE_TAG} AS downloader

# Копирование скрипта скачивания и локальных дистрибутивов
COPY ./scripts/download_yard.sh /download.sh
COPY ./distr /distr
RUN chmod +x /download.sh

# Скачивание дистрибутива 1С с использованием вынесенного скрипта
ARG ONEC_USERNAME
ARG ONEC_PASSWORD
ARG ONEC_VERSION

WORKDIR /tmp

# Установка необходимых пакетов и генерация локали
RUN apt-get update \
  && apt-get install -y \
    locales \
    p7zip-rar \
    p7zip-full \
  && rm -rf /var/lib/apt/lists/* \
  && locale-gen ru_RU.UTF-8 \
  && localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8

# Установка переменных окружения для корректной работы локали
ENV LANG ru_RU.UTF-8
ENV LANGUAGE ru_RU:ru
ENV LC_ALL ru_RU.UTF-8

RUN /download.sh "$ONEC_USERNAME" "$ONEC_PASSWORD" "$ONEC_VERSION" "client"

FROM ubuntu:24.04 AS base

ARG ONEC_VERSION

# Аргумент и переменные окружения для install.sh
ARG nls_enabled=false
ENV nls=$nls_enabled
ENV installer_type=client

# Установка gnupg и wget
RUN set -e \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    gnupg \
    wget \
    ca-certificates \
  && mkdir -p -m 0755 /etc/apt/keyrings \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Добавление репо bionic для libenchant1c2a
RUN set -e \
  && wget -qO- 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3B4FE6ACC0B21F32' | \
  gpg --dearmor -o /etc/apt/keyrings/ubuntu-archive-bionic.gpg \
  && echo "deb [signed-by=/etc/apt/keyrings/ubuntu-archive-bionic.gpg arch=amd64] \
    http://archive.ubuntu.com/ubuntu bionic main universe" | \
    tee /etc/apt/sources.list.d/bionic-archive.list > /dev/null

RUN set -e \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    libenchant1c2a \
    libharfbuzz-icu0 \
    libgstreamer1.0-0 \
    libgstreamer-plugins-base1.0-0 \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    libsecret-1-0 \
    libsoup2.4-1 \
    libsqlite3-0 \
    libgl1 \
    libegl1 \
    libxrender1 \
    libxfixes3 \
    libxslt1.1 \
    geoclue-2.0

COPY ./scripts/install_new.sh /install.sh
COPY --from=downloader /tmp/ /tmp/
WORKDIR /tmp/downloads/Platform83/${ONEC_VERSION}

SHELL ["/bin/bash", "-c"]
RUN ls . \
  && chmod +x /install.sh \
  && /install.sh

# Создание симлинка к каталогу текущей версии платформы
COPY ./scripts/create-symlink-to-current-1cv8.sh /create-symlink-to-current-1cv8.sh
RUN chmod +x /create-symlink-to-current-1cv8.sh \
  && /create-symlink-to-current-1cv8.sh \
  && rm /create-symlink-to-current-1cv8.sh

COPY ./client/configs/current/ /opt/1cv8/current/

FROM ubuntu:24.04
LABEL maintainer="Dima Ovcharenko <d.ovcharenko90@gmail.com> (@ovcharenko_di)"

COPY --from=base /opt /opt

# Установка gnupg и wget
RUN set -e \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    gnupg \
    wget \
    ca-certificates \
  && mkdir -p -m 0755 /etc/apt/keyrings \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Добавление репо bionic для libwebkitgtk-3.0-0
RUN set -e \
  && wget -qO- 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x3B4FE6ACC0B21F32' | \
  gpg --dearmor -o /etc/apt/keyrings/ubuntu-archive-bionic.gpg \
  && echo "deb [signed-by=/etc/apt/keyrings/ubuntu-archive-bionic.gpg arch=amd64] \
    http://archive.ubuntu.com/ubuntu bionic main universe" | \
    tee /etc/apt/sources.list.d/bionic-archive.list > /dev/null

# Установка пакетов и генерация локали
RUN set -e \
  && echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections \
  && DEBIAN_FRONTEND=noninteractive apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    locales \
    libgtk2.0-0t64 \
    libwebkitgtk-3.0-0 \
    ttf-mscorefonts-installer \
    libfontconfig1 \
    libgsf-1-114 \
    dbus-x11 \
    libglu1-mesa \
    libcups2t64 \
  && locale-gen ru_RU.UTF-8 \
  && localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8 \
  && rm -rf \
    /var/lib/apt/lists/* \
    /var/cache/debconf \
    /tmp/*.deb \
  && find /opt/1cv8 -name libstdc++.so.6 -delete 2>/dev/null || true \
  && find /opt/1cv8 -name libgcc_s.so.1 -delete 2>/dev/null || true

ENV LANG ru_RU.UTF-8
ENV LANGUAGE ru_RU:ru
ENV LC_ALL ru_RU.UTF-8

# Создание пользователя и группы
ARG ONEC_UID=1001
ARG ONEC_GID=1001

RUN groupadd -r grp1cv8 --gid=$ONEC_GID \
  && useradd -r -g grp1cv8 --uid=$ONEC_UID --home-dir=/home/usr1cv8 --shell=/bin/bash usr1cv8 \
  && mkdir -p /home/usr1cv8/.1cv8 \
  && chown -R usr1cv8:grp1cv8 /home/usr1cv8

VOLUME /home/usr1cv8/.1cv8/

CMD ["/opt/1C/v8.3/x86_64/1cv8"]
