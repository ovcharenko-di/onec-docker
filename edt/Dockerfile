# Используем базовый образ для скачивания
ARG DOWNLOADER_REGISTRY_URL
ARG DOWNLOADER_IMAGE
ARG DOWNLOADER_TAG
ARG COVERAGE41C_VERSION=2.7.2

ARG BASE_IMAGE=eclipse-temurin
ARG BASE_TAG=11
ARG DOCKER_REGISTRY_URL=library

FROM ${DOWNLOADER_REGISTRY_URL}/${DOWNLOADER_IMAGE}:${DOWNLOADER_TAG} as downloader

# Копирование скрипта скачивания и локальных дистрибутивов
COPY ./scripts/download_yard.sh /download.sh
COPY ./distr /distr
RUN chmod +x /download.sh

# Скачивание дистрибутива 1С с использованием вынесенного скрипта
ARG ONEC_USERNAME
ARG ONEC_PASSWORD
ARG EDT_VERSION=2021.3

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

RUN /download.sh "$ONEC_USERNAME" "$ONEC_PASSWORD" "$EDT_VERSION" "edt"

FROM ${DOCKER_REGISTRY_URL}/${BASE_IMAGE}:${BASE_TAG}

LABEL maintainer="Nikita Gryzlov <NikGryzlov@1bit.com>, FirstBit"

WORKDIR /tmp

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    # downloader dependencies
    curl \
    # edt dependencies
    libgtk-3-0 \
    locales \
  && rm -rf  \
    /var/lib/apt/lists/* \
    /var/cache/debconf \
    /tmp/* \
  && localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8

ARG EDT_VERSION=2021.3
ARG downloads=downloads/DevelopmentTools10/${EDT_VERSION}

ENV LANG ru_RU.UTF-8

# Install EDT
COPY --from=downloader /tmp/${downloads} /tmp/${downloads}

ADD https://github.com/1c-syntax/Coverage41C/releases/download/v${COVERAGE41C_VERSION}/Coverage41C-${COVERAGE41C_VERSION}.tar /tmp/

RUN "tar xf /tmp/Coverage41C-${COVERAGE41C_VERSION}.tar -C /opt/ \
  && rm -rf /tmp/Coverage41C-${COVERAGE41C_VERSION}.tar"
 
WORKDIR /tmp/${downloads}

RUN chmod +x ./1ce-installer-cli \
  && ./1ce-installer-cli install all --ignore-hardware-checks --ignore-signature-warnings\
  && rm -rf /tmp/* \
  && mv $(dirname $(find /opt/1C/1CE -name ring)) /opt/1C/1CE/components/1c-enterprise-ring

ENV PATH="/opt/Coverage41C-${COVERAGE41C_VERSION}/bin:/opt/1C/1CE/components/1c-enterprise-ring:$PATH"
