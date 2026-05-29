ARG DOCKER_REGISTRY_URL
ARG BASE_IMAGE
ARG BASE_TAG

# BASE_IMAGE - слой client (без vnc)
FROM ${DOCKER_REGISTRY_URL}${DOCKER_REGISTRY_URL:+/}${BASE_IMAGE}:${BASE_TAG}

LABEL maintainer="Nikita Gryzlov <NikGryzlov@1bit.com>, FirstBit"

USER root

# Версия SonarScanner CLI. Используется дистрибутив с встроенной JRE,
# поэтому слой jdk поверх client не требуется.
ARG SONAR_SCANNER_VERSION=5.0.1.3006
ARG SONAR_SCANNER_ARCH=linux

ENV SONAR_SCANNER_HOME=/opt/sonar-scanner

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates \
    unzip \
    wget \
  && wget -q -O /tmp/sonar-scanner.zip \
    "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}-${SONAR_SCANNER_ARCH}.zip" \
  && unzip -q /tmp/sonar-scanner.zip -d /opt \
  && mv "/opt/sonar-scanner-${SONAR_SCANNER_VERSION}-${SONAR_SCANNER_ARCH}" "${SONAR_SCANNER_HOME}" \
  && rm -f /tmp/sonar-scanner.zip \
  && apt-get purge -y --auto-remove unzip wget \
  && rm -rf \
    /var/lib/apt/lists/* \
    /var/cache/debconf \
    /tmp/* \
    /var/tmp/*

ENV PATH="${SONAR_SCANNER_HOME}/bin:${PATH}"

# Использовать встроенную в дистрибутив JRE
ENV SONAR_SCANNER_OPTS=""

USER usr1cv8

WORKDIR /usr/src

CMD ["sonar-scanner"]
