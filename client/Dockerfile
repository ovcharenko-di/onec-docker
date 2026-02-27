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

# Начало основной стадии сборки
FROM ubuntu:20.04 AS base

# Копируем скрипты и файлы установки
ARG ONEC_VERSION

# Аргумент и переменные окружения для install.sh
ARG nls_enabled=false
ENV nls=$nls_enabled
ENV installer_type=client

RUN set -xe \
  && chmod 777 -R /tmp \
  && echo "deb http://cz.archive.ubuntu.com/ubuntu bionic main universe" | tee -a /etc/apt/sources.list.d/bionic-cz-archive.list \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      libwebkitgtk-3.0-0 \
      libgtk-3-0 \
      libenchant1c2a \
      libharfbuzz-icu0 \
      libgstreamer1.0-0 \
      libgstreamer-plugins-base1.0-0 \
      gstreamer1.0-plugins-good \
      gstreamer1.0-plugins-bad libsecret-1-0 \
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

# create symlink to current 1c:enterprise directory
COPY ./scripts/create-symlink-to-current-1cv8.sh /create-symlink-to-current-1cv8.sh
RUN chmod +x /create-symlink-to-current-1cv8.sh \
  && /create-symlink-to-current-1cv8.sh \
  && rm /create-symlink-to-current-1cv8.sh

COPY ./client/configs/current/ /opt/1cv8/current/

FROM ubuntu:20.04
LABEL maintainer="Anton Kvashenkin <anton.jugatsu@gmail.com> (@jugatsu)"

ARG ONEC_UID=1000
ARG ONEC_GID=1000

COPY --from=base /opt /opt

RUN set -xe \
  && chmod 777 -R /tmp \
  && echo "deb http://cz.archive.ubuntu.com/ubuntu bionic main universe" | tee -a /etc/apt/sources.list.d/bionic-cz-archive.list \
  && apt-get update \
  && echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      locales \
      ca-certificates \
      libgtk2.0-0 \
      libwebkitgtk-3.0-0 \
      ttf-mscorefonts-installer \
      libfontconfig1 \
      libgsf-1-114 \
      libglib2.0-0 \
      libodbc1 \
      libmagickwand-6.q16-3 \
      dbus-x11 \
      libglu1-mesa \
  && rm -rf \
    /var/lib/apt/lists/* \
    /var/cache/debconf \
    # удаляем встроенную библиотеку, чтобы использовалась системная
    /opt/1cv8/current/libstdc++.so.6 \
  && localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8

ENV LANG ru_RU.UTF-8
ENV LANGUAGE ru_RU:ru
ENV LC_ALL ru_RU.UTF-8

# Create user for 1C
RUN groupadd -r grp1cv8 --gid=$ONEC_GID \
  && useradd -r -g grp1cv8 --uid=$ONEC_UID --home-dir=/home/usr1cv8 --shell=/bin/bash usr1cv8 \
  && mkdir -p /home/usr1cv8/.1cv8 \
  && chown -R usr1cv8:grp1cv8 /home/usr1cv8

VOLUME /home/usr1cv8/.1cv8/

CMD ["/opt/1C/v8.3/x86_64/1cv8"]
