ARG DOCKER_REGISTRY_URL
ARG BASE_IMAGE=debian
ARG BASE_TAG=bookworm-slim

FROM ${DOCKER_REGISTRY_URL:+"$DOCKER_REGISTRY_URL/"}${BASE_IMAGE}:${BASE_TAG}

LABEL maintainer="Nikita Gryzlov <NikGryzlov@1bit.com>, FirstBit"

# Установка JDK требует root (например, когда базовый слой client завершается USER usr1cv8)
USER root

# Install OpenJDK
ARG OPENJDK_VERSION=17

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      apt-transport-https \
      ca-certificates \
      git \
      gnupg \
      dirmngr \
      locales \
      software-properties-common \
      wget \
  && update-ca-certificates \
  && mkdir -p /etc/apt/keyrings \
  && echo "Acquire::https::packages.adoptium.net::Verify-Peer \"false\";" | tee /etc/apt/apt.conf.d/adoptium-no-check-cert \
  && wget --no-check-certificate -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor -o /etc/apt/keyrings/adoptium.gpg \
  && echo "deb [signed-by=/etc/apt/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list \
  && apt update \
  && apt install -y temurin-${OPENJDK_VERSION}-jdk \
  && rm -f /etc/apt/apt.conf.d/adoptium-no-check-cert \
  && localedef -i ru_RU -c -f UTF-8 -A /usr/share/locale/locale.alias ru_RU.UTF-8

# remove DST Root CA X3 cert if it exists
COPY ./scripts/remove-dst-root-ca-x3.sh /remove-dst-root-ca-x3.sh
RUN chmod +x /remove-dst-root-ca-x3.sh \
  && /remove-dst-root-ca-x3.sh \
  && rm /remove-dst-root-ca-x3.sh

ENV LANG ru_RU.UTF-8
