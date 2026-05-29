ARG DOCKER_REGISTRY_URL
ARG BASE_IMAGE
ARG BASE_TAG

# BASE_IMAGE - слой client с установленным JDK (client + jdk)
FROM ${DOCKER_REGISTRY_URL}${DOCKER_REGISTRY_URL:+/}${BASE_IMAGE}:${BASE_TAG}

LABEL maintainer="Nikita Fedkin <nixel2007@gmail.com>, FirstBit"

USER root

# Версия SonarScanner CLI. Java предоставляется слоем jdk.
# SonarScanner CLI 8.x требует Java 21+, слой jdk собирается с JDK 25 (см. build-sonar-scanner.sh).
ARG SONAR_SCANNER_VERSION=8.1.0.6389

ENV SONAR_SCANNER_HOME=/opt/sonar-scanner

# ca-certificates и wget уже присутствуют в слоях client/jdk
RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    unzip \
  && wget -q -O /tmp/sonar-scanner.zip \
    "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}.zip" \
  && unzip -q /tmp/sonar-scanner.zip -d /opt \
  && mv "/opt/sonar-scanner-${SONAR_SCANNER_VERSION}" "${SONAR_SCANNER_HOME}" \
  && rm -f /tmp/sonar-scanner.zip \
  && apt-get purge -y --auto-remove unzip \
  && rm -rf \
    /var/lib/apt/lists/* \
    /var/cache/debconf \
    /tmp/* \
    /var/tmp/*

ENV PATH="${SONAR_SCANNER_HOME}/bin:${PATH}"

# Java берётся из слоя jdk, поэтому отключаем автоскачивание JRE с сервера
ENV SONAR_SCANNER_SKIP_JRE_PROVISIONING=true

USER usr1cv8

WORKDIR /usr/src

CMD ["sonar-scanner"]
